#!/usr/bin/env bash
# ~/Dev/NGOL-D/deploy-prod.sh
set -euo pipefail

echo "🚀 NGOL-D Production Deployment"
echo "   Spec: NGOLTechSpec.md"
echo "   DB: MariaDB (NGOL_D)"
echo "   Login: localhost:5173 → Login.vue modal first"

# 1. Build (note: .#App, .#Backend — per your flake.nix.txt)
echo -e "\n📦 Building production artifacts..."
nix build .#App .#Backend --out-link /tmp/ngol-d-prod || {
  echo "❌ Build failed — check flake.nix.txt"
  exit 1
}

# 2. Install
echo -e "\n📂 Installing to /opt/ngol-d..."
sudo mkdir -p /opt/ngol-d/{frontend,backend}
sudo cp -r /tmp/ngol-d-prod-App/* /opt/ngol-d/frontend/
sudo cp -r /tmp/ngol-d-prod-Backend/* /opt/ngol-d/backend/

# 3. DB setup (MariaDB-only, NGOL_D — per schema.sql.txt)
echo -e "\n🗄️ MariaDB setup..."
if [[ -d /etc/nixos ]]; then
  # NixOS: use module (per NGOLTechSpec.md)
  sudo cp nix/ngol-d.nix /etc/nixos/ 2>/dev/null || true
  sudo sed -i '/imports = \[/a \    ./ngol-d.nix;' /etc/nixos/configuration.nix 2>/dev/null || true
  sudo sed -i '/services\./a \  services.ngol-d.enable = true;' /etc/nixos/configuration.nix 2>/dev/null || true
  sudo nixos-rebuild switch
else
  # Ubuntu (per NGOLTechSpec.md: "Ubuntu, Debian and non-NixOS systems")
  sudo apt-get update && sudo apt-get install -y mariadb-server nginx
  sudo systemctl enable --now mariadb nginx
  sudo mysql -e "
    CREATE DATABASE IF NOT EXISTS NGOL_D;
    CREATE USER IF NOT EXISTS 'ngol'@'localhost' IDENTIFIED BY 'ngol';
    GRANT ALL PRIVILEGES ON NGOL_D.* TO 'ngol'@'localhost';
    FLUSH PRIVILEGES;
  "
  mysql -u ngol -pngol NGOL_D < Backend/schema.sql
fi

# 4. Backend service
echo -e "\n⚙️ Backend systemd service..."
sudo tee /etc/systemd/system/ngol-d-backend.service > /dev/null <<'EOF'
[Unit]
Description=NGOL-D Backend
After=network.target mariadb.service
Requires=mariadb.service

[Service]
Type=simple
User=ngol-d
Group=ngol-d
WorkingDirectory=/opt/ngol-d
Environment=MARIADB_HOST=localhost
Environment=MARIADB_PORT=3306
Environment=MARIADB_USER=ngol
Environment=MARIADB_PASSWORD=ngol
Environment=MARIADB_DATABASE=NGOL_D
Environment=NODE_ENV=production
ExecStart=/opt/ngol-d/backend/bin/ngol-d-backend
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo useradd --system --home-dir /opt/ngol-d ngol-d 2>/dev/null || true
sudo systemctl daemon-reload
sudo systemctl enable --now ngol-d-backend

# 5. nginx (Login.vue first — per NGOLTechSpec.md)
echo -e "\n🌐 nginx config (Login.vue modal first)..."
sudo tee /etc/nginx/sites-available/ngol-d > /dev/null <<'EOF'
server {
  listen 80;
  server_name _;
  root /opt/ngol-d/frontend;
  index index.html;
  location / {
    try_files $uri $uri/ /index.html;
  }
  location /api/ {
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host $host;
  }
  location /socket.io/ {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}
EOF
sudo ln -sf /etc/nginx/sites-available/ngol-d /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

echo -e "\n✅ Deployed! Login: http://localhost/ (Login.vue first)"

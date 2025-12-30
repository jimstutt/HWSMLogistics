#!/usr/bin/env bash
set -euo pipefail

echo "🚀 NGOL-D Production Deployment"
echo "   Spec: NGOLTechSpec.md"
echo "   DB: MariaDB (NGOL_D)"
echo "   Login: localhost:5173 → Login.vue modal first"
echo ""

echo "📦 Building production artifacts..."
nix build .#ngol-d-frontend --no-link
nix build .#Backend --no-link

# Get the actual store paths
FRONTEND_PATH=$(nix path-info ./result)
BACKEND_PATH=$(nix path-info ./result-backend)

echo "📂 Installing to /opt/ngol-d..."
sudo mkdir -p /opt/ngol-d/{frontend,backend}

# Copy frontend files
sudo cp -r "$FRONTEND_PATH"/* /opt/ngol-d/frontend/
echo "✅ Frontend deployed to /opt/ngol-d/frontend"

# Copy backend files
sudo cp -r "$BACKEND_PATH"/* /opt/ngol-d/backend/
echo "✅ Backend deployed to /opt/ngol-d/backend"

# Set proper permissions
sudo chown -R $(whoami):$(whoami) /opt/ngol-d

echo ""
echo "✅ Deployment completed successfully!"
echo "   Frontend: /opt/ngol-d/frontend"
echo "   Backend:  /opt/ngol-d/backend"

#!/usr/bin/env bash
set -euo pipefail

echo "🚀 NGOL-D Production Deployment"
echo "   Spec: NGOLTechSpec.md"
echo "   DB: MariaDB (NGOL_D)"
echo "   Login: localhost:5173 → Login.vue modal first"
echo ""

echo "📦 Building production artifacts..."
# Build frontend and get its store path
FRONTEND_PATH=$(nix build .#ngol-d-frontend --print-out-paths)
# Build backend and get its store path
BACKEND_PATH=$(nix build .#Backend --print-out-paths)

echo "🔍 Frontend path: $FRONTEND_PATH"
echo "🔍 Backend path: $BACKEND_PATH"

echo ""
echo "📂 Installing to /opt/ngol-d..."
sudo mkdir -p /opt/ngol-d/{frontend,backend}

# Copy frontend files
echo "  → Copying frontend files..."
sudo cp -r "$FRONTEND_PATH"/* /opt/ngol-d/frontend/
echo "✅ Frontend deployed to /opt/ngol-d/frontend"

# Copy backend files
echo "  → Copying backend files..."
sudo cp -r "$BACKEND_PATH"/* /opt/ngol-d/backend/
echo "✅ Backend deployed to /opt/ngol-d/backend"

# Set proper permissions
echo "  → Setting permissions..."
sudo chown -R $(whoami):$(whoami) /opt/ngol-d

echo ""
echo "✅ Deployment completed successfully!"
echo "   Frontend: /opt/ngol-d/frontend"
echo "   Backend:  /opt/ngol-d/backend"
echo ""
echo "🔧 Next steps:"
echo "   1. Configure your web server to serve /opt/ngol-d/frontend"
echo "   2. Start the backend service: sudo systemctl start ngol-d-backend"

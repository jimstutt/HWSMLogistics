#!/bin/bash
set -e

echo "🚀 Rebuilding and redeploying NGOL-D..."
cd ~/Dev/NGOL-D

# Check if git repo is clean, if not, commit changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo ""
  echo "⚠️  Uncommitted changes detected. Committing them to avoid warnings..."
  echo ""
  
  # Add all changes
  git add -A
  
  # Check if there are actually changes to commit
  if git diff --cached --quiet; then
    echo "ℹ️ No actual changes to commit (git add didn't stage anything)"
  else
    # Commit with timestamp
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    git commit -m "Auto-commit before rebuild at $TIMESTAMP" || echo "✅ Changes already committed"
  fi
fi

# Verify Node.js version is updated
NODE_VERSION=$(nix eval .#Backend --apply 'drv: drv.nodejs.version' 2>/dev/null || echo "unknown")
echo ""
echo "🔍 Current Node.js version: $NODE_VERSION"
if [[ "$NODE_VERSION" != *"22"* ]]; then
  echo ""
  echo "⚠️  WARNING: Node.js version doesn't appear to be 22.x"
  echo "   You may need to run './fix-node-version.sh' first"
  echo "   Continuing anyway, but build might fail..."
  echo ""
fi

# Clean previous build results
echo ""
echo "🧹 Cleaning previous build artifacts..."
rm -f result result-* 2>/dev/null || true

# Rebuild frontend
echo ""
echo "📦 Building frontend with Node.js 22..."
nix build .#ngol-d-frontend --show-trace

# Verify frontend build
if [ ! -L "result" ] || [ ! -d "result" ]; then
  echo ""
  echo "❌ Frontend build failed or result symlink not created"
  echo "   Check the error messages above"
  exit 1
fi

FRONTEND_PATH=$(readlink result)
echo "✅ Frontend built successfully at: $FRONTEND_PATH"

# Clean result symlink for backend build
rm -f result 2>/dev/null || true

# Rebuild backend
echo ""
echo "📦 Building backend with Node.js 22..."
nix build .#Backend --show-trace

# Verify backend build
if [ ! -L "result" ] || [ ! -d "result" ]; then
  echo ""
  echo "❌ Backend build failed or result symlink not created"
  echo "   Check the error messages above"
  exit 1
fi

BACKEND_PATH=$(readlink result)
echo "✅ Backend built successfully at: $BACKEND_PATH"

# Run deployment script
echo ""
echo "🚀 Deploying to /opt/ngol-d..."
if [ -f "./deploy-prod.sh" ]; then
  ./deploy-prod.sh
else
  echo "❌ Error: deploy-prod.sh not found"
  echo "   Please create this file or run deployment manually"
  exit 1
fi

echo ""
echo "✨ Deployment completed successfully!"
echo ""
echo "✅ Access the application at:"
echo "   Frontend: http://localhost (or your server IP)"
echo "   Backend API: Check your backend configuration"
echo ""
echo "💡 Next steps:"
echo "   - Configure your web server (Nginx/Apache) for production"
echo "   - Set up systemd services for backend"
echo "   - Configure HTTPS with Let's Encrypt (when you have a domain)"

#!/bin/bash
set -e

echo "🚀 Rebuilding and redeploying NGOL-D..."
cd ~/Dev/NGOL-D

# Commit changes to avoid Git warnings
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo ""
  echo "⚠️  Uncommitted changes detected. Committing them..."
  git add -A
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  git commit -m "Auto-commit before rebuild at $TIMESTAMP" || echo "✅ Changes already committed"
fi

# Clean previous build artifacts
echo ""
echo "🧹 Cleaning previous build artifacts..."
rm -f result result-* 2>/dev/null || true

# Rebuild frontend
echo ""
echo "📦 Building frontend..."
nix build .#ngol-d-frontend --show-trace

# Rebuild backend
echo ""
echo "📦 Building backend..."
nix build .#Backend --show-trace

# Run deployment script
echo ""
echo "🚀 Deploying to /opt/ngol-d..."
./deploy-prod.sh

echo ""
echo "✨ Deployment completed successfully!"
echo "✅ Access the application at: http://localhost"

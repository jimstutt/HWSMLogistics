#!/usr/bin/env bash
set -euo pipefail

echo "📦 Building NGOL-D production artifacts..."

# 1. Ensure clean Git state (required for flake reproducibility)
if [[ -n "$(git status --porcelain)" ]]; then
  echo "⚠️  Warning: Uncommitted changes detected."
  echo "   To proceed safely, either:"
  echo "     (a) Commit changes: git add . && git commit -m 'build: prep for prod'"
  echo "     (b) Build from HEAD + dirty overlay (less reproducible):"
  read -p "   Continue with dirty build? (y/N) " -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# 2. Build backend & frontend
nix build .#ngol-d-backend .#ngol-d-frontend --print-build-logs

# 3. Package artifacts
mkdir -p ./prod-build/{backend,frontend}

# Backend: copy executable + deps + assets
cp -r ./result/bin ./prod-build/backend/
cp -r ./result/lib ./prod-build/backend/ 2>/dev/null || true
cp -r ./Backend/config ./prod-build/backend/  # config.env etc.

# Frontend: static assets
cp -r ./result/* ./prod-build/frontend/

echo "✅ Production build completed in ./prod-build/"
ls -l ./prod-build/

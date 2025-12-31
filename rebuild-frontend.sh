#!/bin/bash
set -e
echo "🔧 Rebuilding frontend..."
cd ~/Dev/NGOL-D/App
npm install
npm run build
echo "✅ Frontend rebuilt successfully"

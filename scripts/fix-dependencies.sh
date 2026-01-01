#!/bin/bash
set -e

echo "🚀 Fixing dependency conflicts for Vue 3/Vite 7 project..."
cd ./App

echo "📦 Updating Vite and Vue plugin to compatible versions..."
npm install vite@latest @vitejs/plugin-vue@latest --save-dev --legacy-peer-deps

echo "✅ Vite and Vue plugin updated successfully"

echo "📦 Installing core dependencies..."
npm install @vuelidate/core @vuelidate/validators --legacy-peer-deps
npm install @fortawesome/fontawesome-free --legacy-peer-deps

echo "✅ Core dependencies installed"

echo "🛡️ Fixing security vulnerabilities..."
npm audit fix --force --legacy-peer-deps

echo "✨ All dependencies resolved successfully!"
echo "💡 Next step: Run 'update-login.sh' to update the Login.vue component"

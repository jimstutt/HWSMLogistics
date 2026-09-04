#!/usr/bin/env bash
set -e

echo "🔧 Checking for missing Haskell modules in backend/..."

# 1. Fix Backend.Ws (WebSockets stub)
WS_FILE="backend/src/Backend/Ws.hs"
if [ ! -f "$WS_FILE" ]; then
    echo "   📝 Creating missing stub: $WS_FILE"
    mkdir -p "$(dirname "$WS_FILE")"
    cat << 'EOF' > "$WS_FILE"
module Backend.Ws where

-- Placeholder for WebSocket logic
-- Add servant-websockets or custom WS implementation here later
EOF
fi

# 2. Fix Backend.App (Main application logic stub)
APP_FILE="backend/src/Backend/App.hs"
if [ ! -f "$APP_FILE" ]; then
    echo "   📝 Creating missing stub: $APP_FILE"
    mkdir -p "$(dirname "$APP_FILE")"
    cat << 'EOF' > "$APP_FILE"
module Backend.App where

-- Placeholder for main Servant server application logic
EOF
fi

# 3. Fix Backend.Config (Configuration stub)
CONFIG_FILE="backend/src/Backend/Config.hs"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "   📝 Creating missing stub: $CONFIG_FILE"
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat << 'EOF' > "$CONFIG_FILE"
module Backend.Config where

-- Placeholder for database and server configuration
EOF
fi

echo "✅ Created all missing module stubs."
echo ""
echo "💡 Next step: Run 'nix build .#backend' to verify the fix."

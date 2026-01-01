#!/bin/bash
set -e

echo "🔧 Fixing npm dependencies hash..."
cd ~/Dev/NGOL-D/App

# Check if default.nix exists
if [ ! -f "default.nix" ]; then
  echo "❌ Error: default.nix not found in ~/Dev/NGOL-D/App/"
  exit 1
fi

# Backup the original file first
cp default.nix default.nix.backup
echo "✅ Created backup: default.nix.backup"

# Set fake hash temporarily using safe delimiter
sed -i 's|npmDepsHash = "[^"]*"|npmDepsHash = lib.fakeHash|' default.nix
echo "✅ Set fake hash in default.nix"

# Attempt build to get the real hash (will fail but show the hash)
echo ""
echo "⏳ Building to get correct hash (this will fail intentionally)..."
echo "   This may take a few minutes as it downloads dependencies..."
echo ""

# Run build and capture output
BUILD_OUTPUT=$(nix build --no-link .#ngol-d-frontend 2>&1) || true

# Save the output for debugging
echo "$BUILD_OUTPUT" > /tmp/npm-hash-output.log
echo "📋 Build output saved to /tmp/npm-hash-output.log"

# Extract the correct hash from the log
CORRECT_HASH=$(echo "$BUILD_OUTPUT" | grep -oP 'got:\s+sha256-[A-Za-z0-9+/=]+' | head -1 | sed 's/got:\s*//')

if [ -z "$CORRECT_HASH" ]; then
  echo ""
  echo "❌ Failed to extract hash from build output."
  echo "   Check /tmp/npm-hash-output.log for details"
  echo "   Restoring backup..."
  cp default.nix.backup default.nix
  exit 1
fi

echo ""
echo "✅ Extracted correct hash: $CORRECT_HASH"

# Escape special characters for sed
ESCAPED_HASH=$(echo "$CORRECT_HASH" | sed 's/[\/&]/\\&/g')

# Restore from backup first
cp default.nix.backup default.nix

# Update with real hash using safe delimiter
sed -i "s|npmDepsHash = lib.fakeHash|npmDepsHash = \"$ESCAPED_HASH\"|" default.nix

echo "✅ Updated default.nix with correct hash"

# Clean up
rm default.nix.backup

echo ""
echo "✨ npm dependencies hash updated successfully"
echo "💡 Next step: Run './rebuild-and-deploy.sh'"

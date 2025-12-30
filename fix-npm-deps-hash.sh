#!/bin/bash
set -e

echo "🔧 Fixing npm dependencies hash..."
cd ~/Dev/NGOL-D/App

# Check if default.nix exists
if [ ! -f "default.nix" ]; then
  echo "❌ Error: default.nix not found in ~/Dev/NGOL-D/App/"
  exit 1
fi

# Check if npmDepsHash exists in the file
if ! grep -q "npmDepsHash" default.nix; then
  echo "ℹ️ No npmDepsHash found in default.nix. Looking for buildNpmPackage usage..."
  if grep -q "buildNpmPackage" default.nix; then
    echo "✅ Found buildNpmPackage. Adding npmDepsHash line..."
    # Insert npmDepsHash line after the opening brace of buildNpmPackage
    sed -i '/buildNpmPackage {/a\    npmDepsHash = lib.fakeHash;' default.nix
  else
    echo "❌ Error: This script requires buildNpmPackage with npmDepsHash in default.nix"
    exit 1
  fi
fi

# Backup the original file
cp default.nix default.nix.backup
echo "✅ Created backup: default.nix.backup"

# Set fake hash temporarily
sed -i 's/npmDepsHash = "[^"]*"/npmDepsHash = lib.fakeHash/' default.nix
echo "✅ Set fake hash in default.nix"

# Attempt build to get the real hash (will fail but show the hash)
echo ""
echo "⏳ Building to get correct hash (this will fail intentionally)..."
echo "   This may take a few minutes as it downloads dependencies..."
echo ""

# Run build and capture output
BUILD_OUTPUT=$(nix build --no-link .#ngol-d-frontend 2>&1) || true

# Save the output for debugging if needed
echo "$BUILD_OUTPUT" > /tmp/npm-hash-output.log
echo "📋 Build output saved to /tmp/npm-hash-output.log"

# Extract the correct hash from the log
CORRECT_HASH=$(echo "$BUILD_OUTPUT" | grep -oP 'got:\s+sha256-[A-Za-z0-9+/=]+' | head -1 | sed 's/got:\s*//')

if [ -z "$CORRECT_HASH" ]; then
  echo ""
  echo "❌ Failed to extract hash from build output."
  echo "   Please check /tmp/npm-hash-output.log for details."
  echo "   Or manually look for 'got: sha256-...' in the build output."
  echo ""
  echo "   Restoring original default.nix from backup..."
  cp default.nix.backup default.nix
  exit 1
fi

echo ""
echo "✅ Extracted correct hash: $CORRECT_HASH"

# Restore from backup first to preserve all other changes
cp default.nix.backup default.nix

# Update default.nix with the real hash
if grep -q "npmDepsHash = lib.fakeHash" default.nix; then
  sed -i "s/npmDepsHash = lib.fakeHash/npmDepsHash = \"$CORRECT_HASH\"/" default.nix
elif grep -q 'npmDepsHash = "[^"]*"' default.nix; then
  sed -i "s/npmDepsHash = \"[^\"]*\"/npmDepsHash = \"$CORRECT_HASH\"/" default.nix
else
  echo "⚠️ Could not find npmDepsHash line. Adding it manually..."
  # Try to insert after buildNpmPackage line
  if grep -q "buildNpmPackage {" default.nix; then
    sed -i "/buildNpmPackage {/a\    npmDepsHash = \"$CORRECT_HASH\";" default.nix
  else
    echo "❌ Error: Could not determine where to insert npmDepsHash"
    exit 1
  fi
fi

echo "✅ Updated default.nix with correct hash"

# Clean up backup
rm default.nix.backup

echo ""
echo "✨ npm dependencies hash updated successfully"
echo "💡 Next step: Run './rebuild-and-deploy.sh' to rebuild and deploy the application"

#!/usr/bin/env bash
set -e

TYPES_FILE="common/src/Common/Types.hs"

if [ ! -f "$TYPES_FILE" ]; then
    echo "❌ Error: $TYPES_FILE not found. Run this from the project root."
    exit 1
fi

echo "🔧 Fixing ToSchema instances in $TYPES_FILE..."

# 1. Add the Data.OpenApi import if not already present
if ! grep -q "Data.OpenApi" "$TYPES_FILE"; then
    # Insert the import after the last existing import line
    sed -i '/^import /a import Data.OpenApi (ToSchema)' "$TYPES_FILE"
    # Remove duplicate imports if the above added more than one
    awk '!seen[$0]++' "$TYPES_FILE" > "$TYPES_FILE.tmp" && mv "$TYPES_FILE.tmp" "$TYPES_FILE"
    echo "   ✅ Added 'import Data.OpenApi (ToSchema)'"
else
    echo "   ℹ️  Data.OpenApi import already present."
fi

# 2. Add ToSchema to all deriving clauses that have ToJSON but lack ToSchema
# This handles both single-line and multi-line deriving clauses
sed -i -E 's/deriving\s*\(([^)]*ToJSON[^)]*)\)/deriving (\1, ToSchema)/g' "$TYPES_FILE"

# 3. Clean up any duplicate ToSchema entries that might have been created
sed -i -E 's/ToSchema,\s*ToSchema/ToSchema/g' "$TYPES_FILE"
sed -i -E 's/,\s*ToSchema\s*,\s*ToSchema/, ToSchema/g' "$TYPES_FILE"

# 4. Clean up any trailing commas before closing parenthesis
sed -i -E 's/,\s*\)/)/g' "$TYPES_FILE"

echo "   ✅ Added ToSchema to all deriving clauses."
echo ""
echo "📋 Updated deriving clauses:"
grep -n "deriving" "$TYPES_FILE" | head -20
echo ""
echo "💡 Next step: Run 'nix build .#backend' to verify the fix."

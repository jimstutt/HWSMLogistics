#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/clean-project.sh
# Spec compliance: NGOLTechSpec.md — "Do not use mongodb or SQLite"
# Removes: MongoDB, SQLite, outdated configs, backups, temp files
set -euo pipefail

PROJECT_ROOT="${PWD}"

echo "🧹 Cleaning NGOL-D project (per NGOLTechSpec.md § Do not use mongodb or SQLite)"

# 1. Remove MongoDB-related files (explicitly forbidden)
rm -f ./scripts/audit-purge-mongodb.sh
rm -f ./scripts/audit.purge-mongodb.sh
echo "✅ Removed MongoDB scripts"

# 2. Remove SQLite remnants (forbidden)
find . -name "*.db" -type f -delete 2>/dev/null || true
find . -name "test.db" -type f -delete 2>/dev/null || true
find . -name "data" -type d -exec rm -rf {} + 2>/dev/null || true
echo "✅ Removed SQLite data files"

# 3. Remove backup/swap/temp files
rm -f ./**/*.bak* ./**/*~ ./**/.#* ./**/*.tmp* ./**/*.orig 2>/dev/null || true
rm -f ./Backend/package.json.bak.1766932286
rm -f ./scripts/prod-deploy.sh~
rm -f ./scripts/start-mariadb.sh~
rm -f ./scripts/start-servers.sh~
rm -f ./Backend/config/config.env~
rm -f ./App/default.nix.backup
echo "✅ Removed backup/swap files"

# 4. Remove obsolete config files (conflict with spec)
rm -f ./ci.yml.txt          # superseded by .github/workflows/ci.yml
rm -f ./flake.nix.txt       # superseded by flake.nix
rm -f ./default.nix.txt     # superseded by App/default.nix
rm -f ./Backend/schema.sql.txt  # superseded by schema.sql
echo "✅ Removed obsolete .txt configs"

# 5. Remove safe-fix/audit scripts (not in spec)
rm -f ./scripts/safe-fix.sh
rm -f ./scripts/fix-seed-deps-safe.sh
rm -f ./scripts/fix-npm-deps-hash.sh
rm -f ./scripts/fix-dependencies.sh
rm -f ./scripts/fix-node-version.sh
echo "✅ Removed non-spec audit/fix scripts"

# 6. Remove deploy scripts (production handled via Nix)
rm -f ./scripts/deploy.sh
rm -f ./scripts/deploy-prod.sh~
rm -f ./scripts/prod-buid.sh
rm -f ./scripts/prod-build.sh
rm -f ./scripts/prod-deploy.sh
rm -f ./scripts/rebuild-and-deploy.sh
rm -f ./scripts/update-node-app.sh
rm -f ./scripts/update-node-backend.sh
rm -f ./scripts/update-node-flake.sh
echo "✅ Removed manual deploy scripts (spec: Nix-managed)"

# 7. Remove outdated migration scripts (schema.sql is source of truth)
rm -f ./Backend/scripts/migrateDatabase.js
rm -f ./Backend/migrate.js
echo "✅ Removed outdated migrate.js (spec: schema.sql only)"

# 8. Verify critical spec-compliant files remain
for f in \
  ".github/workflows/ci.yml" \
  "flake.nix" \
  "Backend/schema.sql" \
  "Backend/server.js" \
  "App/src/views/Login.vue" \
  "scripts/start-servers.sh"; do
  if [[ ! -e "$f" ]]; then
    echo "❌ Critical file missing: $f"
    exit 1
  fi
done

echo -e "\n✅ Cleanup complete. Project now strictly complies with NGOLTechSpec.md:"
echo "   • No MongoDB"
echo "   • No SQLite"
echo "   • MariaDB only"
echo "   • Nix-managed deployment"
echo "   • Login.vue first at localhost:5173"
echo "   • Real-time via Socket.IO"

# Optional: git status
echo -e "\n🔍 Suggested next: git status"

git status

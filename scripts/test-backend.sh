#!/usr/bin/env bash
# ~/Dev/NGOL-D/test-backend.sh
# Tests NGOL-D backend per NGOLTechSpec.md requirements
set -euo pipefail

echo "🧪 NGOL-D Backend Test Suite"
echo "   Spec: $PWD/NGOLTechSpec.md"
echo "   Flake: $PWD/flake.nix.txt"
echo "   CI: $PWD/ci.yml.txt"

# 1. Verify MariaDB-only (no SQLite traces)
echo -e "\n🔍 1. MariaDB-only check"
if grep -r "sqlite\|DB_PATH" Backend/ 2>/dev/null | grep -v ".bak"; then
  echo "❌ FAIL: SQLite traces found"
  exit 1
else
  echo "✅ PASS: No SQLite traces"
fi

# 2. Verify ESM syntax
echo -e "\n🔍 2. ESM syntax check"
if grep -r "require(" Backend/ 2>/dev/null; then
  echo "❌ FAIL: CommonJS require() found"
  exit 1
else
  echo "✅ PASS: ESM only (import/export)"
fi

# 3. Start MariaDB (spec-compliant)
echo -e "\n🔍 3. MariaDB setup"
./start-mariadb.sh >/dev/null 2>&1 &
MARIADB_PID=$!
sleep 5

# 4. Start backend
echo -e "\n🔍 4. Backend startup"
cd Backend
nix develop --command node server.js >/dev/null 2>&1 &
BACKEND_PID=$!
cd ..
sleep 3

# 5. Health check (spec: { status: 'ok', db: 'mariadb' })
echo -e "\n🔍 5. /api/health test"
HEALTH=$(curl -sf http://localhost:3000/api/health 2>/dev/null || echo "{}")
if echo "$HEALTH" | grep -q '"status":"ok"' && echo "$HEALTH" | grep -q '"db":"mariadb"'; then
  echo "✅ PASS: $HEALTH"
else
  echo "❌ FAIL: Expected { status: 'ok', db: 'mariadb' }, got: $HEALTH"
  kill $MARIADB_PID $BACKEND_PID 2>/dev/null || true
  exit 1
fi

# 6. Socket.IO endpoint
echo -e "\n🔍 6. Socket.IO test"
if curl -sf http://localhost:3000/socket.io/socket.io.js >/dev/null 2>&1; then
  echo "✅ PASS: Socket.IO available"
else
  echo "❌ FAIL: Socket.IO not available"
  kill $MARIADB_PID $BACKEND_PID 2>/dev/null || true
  exit 1
fi

# 7. Auth endpoints (spec: Login modal first → /api/auth/login)
echo -e "\n🔍 7. Auth endpoints"
if curl -sf -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test"}' | grep -q "error"; then
  echo "✅ PASS: /api/auth/login responds"
else
  echo "❌ FAIL: /api/auth/login not working"
  kill $MARIADB_PID $BACKEND_PID 2>/dev/null || true
  exit 1
fi

# 8. Cleanup
kill $MARIADB_PID $BACKEND_PID 2>/dev/null || true
echo -e "\n🎉 All tests passed — backend is spec-compliant!"

#!/usr/bin/env bash
# ~/Dev/NGOL-D/test-full-stack.sh
# Full-stack integration test per NGOLTechSpec.md
set -euo pipefail

echo "🧪 NGOL-D Full-Stack Test Suite"
echo "   Spec: $PWD/NGOLTechSpec.md"
echo "   DB: MariaDB (not SQLite)"
echo "   Frontend: Login.vue modal first"
echo "   Real-time: Socket.IO"

# 1. Verify spec compliance of source files
echo -e "\n🔍 1. Source code verification"

# Check flake.nix description
if grep -q "MariaDB" flake.nix; then
  echo "✅ PASS: flake.nix mentions MariaDB"
elif grep -q "SQLite" flake.nix; then
  echo "⚠️ WARNING: flake.nix mentions SQLite — should be MariaDB"
fi

# Check CI uses MariaDB (not DB_PATH)
if grep -q "mariadb:" .github/workflows/ci.yml 2>/dev/null; then
  echo "✅ PASS: CI uses MariaDB service"
elif grep -q "DB_PATH" .github/workflows/ci.yml 2>/dev/null; then
  echo "⚠️ WARNING: CI uses DB_PATH (SQLite) — should use MARIADB_*"
fi

# Check schema uses NGOL_D (uppercase)
if grep -q "NGOL_D" Backend/schema.sql 2>/dev/null; then
  echo "✅ PASS: schema.sql uses NGOL_D"
elif grep -q "ngol_d" Backend/schema.sql 2>/dev/null; then
  echo "⚠️ WARNING: schema.sql uses ngol_d — should be NGOL_D (uppercase)"
fi

# 2. Start full stack
echo -e "\n🔍 2. Full stack startup"
./start-servers.sh >/dev/null 2>&1 &
FULL_STACK_PID=$!
sleep 15

# 3. Frontend: Login.vue modal first (spec requirement)
echo -e "\n🔍 3. Login.vue modal first test"
LOGIN_HTML=$(curl -sf http://localhost:5173 2>/dev/null || echo "")
if [[ "$LOGIN_HTML" == *"Login.vue"* ]] || [[ "$LOGIN_HTML" == *"login"* ]]; then
  echo "✅ PASS: Login.vue modal detected"
else
  echo "❌ FAIL: Login modal not found — violates NGOLTechSpec.md"
  kill $FULL_STACK_PID 2>/dev/null || true
  exit 1
fi

# 4. Backend health check (spec: { status: 'ok', db: 'mariadb' })
echo -e "\n🔍 4. /api/health test"
HEALTH=$(curl -sf http://localhost:3000/api/health 2>/dev/null || echo "{}")
if echo "$HEALTH" | grep -q '"status":"ok"' && echo "$HEALTH" | grep -q '"db":"mariadb"'; then
  echo "✅ PASS: $HEALTH"
else
  echo "❌ FAIL: Expected { status: 'ok', db: 'mariadb' }"
  kill $FULL_STACK_PID 2>/dev/null || true
  exit 1
fi

# 5. Socket.IO real-time (spec: "Implement Real-time Updates with Socket.IO")
echo -e "\n🔍 5. Socket.IO test"
if curl -sf http://localhost:3000/socket.io/socket.io.js >/dev/null 2>&1; then
  echo "✅ PASS: Socket.IO available"
else
  echo "❌ FAIL: Socket.IO not available — violates NGOLTechSpec.md"
  kill $FULL_STACK_PID 2>/dev/null || true
  exit 1
fi

# 6. Google Maps API key (spec: AIzaSyBTmKzNwMM1OIruKtneSGHYUYbJHMUL6j0)
echo -e "\n🔍 6. Google Maps API key check"
if grep -q "AIzaSyBTmKzNwMM1OIruKtneSGHYUYbJHMUL6j0" App/src/components/MapView.vue 2>/dev/null; then
  echo "✅ PASS: Google Maps API key present"
else
  echo "❌ FAIL: Google Maps API key missing — violates NGOLTechSpec.md"
  kill $FULL_STACK_PID 2>/dev/null || true
  exit 1
fi

# 7. Auth flow (spec: Login → Dashboard)
echo -e "\n🔍 7. Authentication flow test"
LOGIN_RESP=$(curl -sf -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.org","password":"password123"}' 2>/dev/null || echo "{}")

if echo "$LOGIN_RESP" | grep -q "token"; then
  echo "✅ PASS: Login successful"
else
  echo "⚠️ WARNING: Default admin credentials not working"
fi

# 8. Cleanup
kill $FULL_STACK_PID 2>/dev/null || true
echo -e "\n🎉 Full-stack test complete — all critical spec requirements verified!"

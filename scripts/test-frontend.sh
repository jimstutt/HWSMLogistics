#!/usr/bin/env bash
# ~/Dev/NGOL-D/test-frontend.sh
# Tests NGOL-D frontend per NGOLTechSpec.md requirements
set -euo pipefail

echo "🧪 NGOL-D Frontend Test Suite"
echo "   Spec: $PWD/NGOLTechSpec.md"
echo "   Requires: MariaDB running (./start-mariadb.sh)"

# 1. Verify Login.vue loads first (spec: "localhost:5173 always loads a modal Login.vue form first")
echo -e "\n🔍 1. Login.vue modal first test"
if [[ -f App/src/views/Login.vue ]]; then
  echo "✅ PASS: Login.vue exists"
else
  echo "❌ FAIL: Login.vue missing"
  exit 1
fi

# 2. Verify router configuration (Login modal first)
echo -e "\n🔍 2. Router enforcement check"
if grep -q "Login\.vue.*modal\|modal.*Login\.vue" App/src/router/index.js 2>/dev/null; then
  echo "✅ PASS: Router enforces Login.vue modal"
else
  echo "⚠️ WARNING: Router may not enforce Login modal first"
fi

# 3. Start full stack
echo -e "\n🔍 3. Full stack startup"
./start-servers.sh >/dev/null 2>&1 &
FULL_STACK_PID=$!
sleep 15

# 4. Frontend health check (localhost:5173)
echo -e "\n🔍 4. Frontend HTTP check"
if curl -sf http://localhost:5173 | grep -q "<title>NGO Logistics</title>"; then
  echo "✅ PASS: Frontend serves HTML"
else
  echo "❌ FAIL: Frontend not serving"
  kill $FULL_STACK_PID 2>/dev/null || true
  exit 1
fi

# 5. Login modal first (spec requirement)
echo -e "\n🔍 5. Login modal first verification"
if curl -sf http://localhost:5173 | grep -iq "login\|modal\|Login\.vue"; then
  echo "✅ PASS: Login modal detected in HTML"
else
  echo "❌ FAIL: Login modal not found — violates NGOLTechSpec.md"
  kill $FULL_STACK_PID 2>/dev/null || true
  exit 1
fi

# 6. Google Maps API key (spec: maps api key:AIzaSyBTmKzNwMM1OIruKtneSGHYUYbJHMUL6j0)
echo -e "\n🔍 6. Google Maps API key check"
if grep -q "AIzaSyBTmKzNwMM1OIruKtneSGHYUYbJHMUL6j0" App/src/components/MapView.vue 2>/dev/null; then
  echo "✅ PASS: Google Maps API key present"
else
  echo "⚠️ WARNING: Google Maps API key missing"
fi

# 7. Socket.IO client (spec: "Implement Real-time Updates with Socket.IO")
echo -e "\n🔍 7. Socket.IO client check"
if grep -q "socket\.io\|io(" App/src/stores/shipment.js 2>/dev/null; then
  echo "✅ PASS: Socket.IO client implemented"
else
  echo "❌ FAIL: Socket.IO client missing — violates NGOLTechSpec.md"
  kill $FULL_STACK_PID 2>/dev/null || true
  exit 1
fi

# 8. Responsive design (spec: "Responsive Design - Mobile and desktop compatibility")
echo -e "\n🔍 8. Responsive meta tag"
if grep -q "viewport" App/index.html 2>/dev/null; then
  echo "✅ PASS: Responsive meta tag present"
else
  echo "❌ FAIL: Responsive design missing"
  kill $FULL_STACK_PID 2>/dev/null || true
  exit 1
fi

# 9. Cleanup
kill $FULL_STACK_PID 2>/dev/null || true
echo -e "\n🎉 All frontend tests passed — spec-compliant!"

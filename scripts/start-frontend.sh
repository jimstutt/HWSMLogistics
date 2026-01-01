#!/usr/bin/env bash
# ~/Dev/NGOL-D/scripts/start-frontend.sh
cd App
nix develop .#frontend --command npm run dev

#!/usr/bin/env bash
set -e

WS_FILE="backend/src/Backend/Ws.hs"

echo "🔧 Updating $WS_FILE to match Backend.hs call signature..."

cat << 'EOF' > "$WS_FILE"
{-# LANGUAGE OverloadedStrings #-}
module Backend.Ws 
  ( WsState(..)
  , broadcast
  ) where

import Common.Types (Shipment)

-- | Placeholder type for WebSocket state.
data WsState = WsState
  deriving (Show, Eq)

-- | Placeholder broadcast function.
-- Matches the call in Backend.hs: broadcast wsState newS
broadcast :: WsState -> Shipment -> IO ()
broadcast _state _shipment = return ()
EOF

echo "✅ Successfully updated Backend.Ws exports and broadcast signature."

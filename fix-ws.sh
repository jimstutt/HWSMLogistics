#!/usr/bin/env bash
set -e

WS_FILE="backend/src/Backend/Ws.hs"

echo "🔧 Updating $WS_FILE to export WsState and broadcast..."

cat << 'EOF' > "$WS_FILE"
{-# LANGUAGE OverloadedStrings #-}
module Backend.Ws 
  ( WsState(..)
  , broadcast
  ) where

import Data.Text (Text)

-- | Placeholder type for WebSocket state.
-- You can replace this with a TVar [Connection] later when implementing actual WebSockets.
data WsState = WsState
  deriving (Show, Eq)

-- | Placeholder broadcast function.
-- Sends a text message to all connected clients (currently a no-op stub).
broadcast :: Text -> WsState -> IO ()
broadcast _msg _state = return ()
EOF

echo "✅ Successfully updated Backend.Ws exports."

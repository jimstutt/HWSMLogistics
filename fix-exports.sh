#!/usr/bin/env bash
set -e

WS_FILE="backend/src/Backend/Ws.hs"

echo "🔧 Updating $WS_FILE to export newWsState and wsApp..."

cat << 'EOF' > "$WS_FILE"
{-# LANGUAGE OverloadedStrings #-}
module Backend.Ws 
  ( WsState(..)
  , newWsState
  , wsApp
  , broadcast
  ) where

import Common.Types (Shipment)
import Network.Wai (Application, responseLBS)
import Network.HTTP.Types (status200)

-- | Placeholder type for WebSocket state.
data WsState = WsState
  deriving (Show, Eq)

-- | Initialize the WebSocket state.
newWsState :: IO WsState
newWsState = return WsState

-- | Placeholder WebSocket WAI application.
-- Replace this with `websocketsOr` from `wai-websockets` when implementing real WS.
wsApp :: WsState -> Application
wsApp _state request respond = respond $ responseLBS status200 [] "WebSocket Stub"

-- | Placeholder broadcast function.
broadcast :: WsState -> Shipment -> IO ()
broadcast _state _shipment = return ()
EOF

echo "✅ Successfully updated Backend.Ws exports."

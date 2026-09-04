{-# LANGUAGE OverloadedStrings #-}
module Backend.Ws
  ( WsState(..)
  , newWsState
  , wsApp
  , broadcast
  ) where

import Common.Types (Shipment)
import Network.WebSockets (PendingConnection, acceptRequest)

-- | Placeholder type for WebSocket state.
data WsState = WsState
  deriving (Show, Eq)

-- | Initialize the WebSocket state.
newWsState :: IO WsState
newWsState = return WsState

-- | WebSocket handler stub.
-- websocketsOr expects: ServerApp = PendingConnection -> IO ()
-- By partially applying WsState, we get the correct type.
wsApp :: WsState -> PendingConnection -> IO ()
wsApp _state pendingConn = do
    acceptRequest pendingConn
    return ()

-- | Placeholder broadcast function.
broadcast :: WsState -> Shipment -> IO ()
broadcast _state _shipment = return ()

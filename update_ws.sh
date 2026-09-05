#!/usr/bin/env bash
cat << 'HSEOF' > backend/src/Backend/Ws.hs
{-# LANGUAGE OverloadedStrings #-}
module Backend.Ws (WsState(..), newWsState, wsApp, broadcast) where
import Common.Types (Shipment)
import Data.Aeson (encode)
import Data.Text (Text)
import Control.Concurrent.STM (TVar, readTVar, modifyTVar', atomically, newTVarIO)
import Control.Exception (finally, catch, SomeException)
import Network.WebSockets (PendingConnection, acceptRequest, receiveData, sendTextData, Connection)

data WsState = WsState { connections :: TVar [Connection] }
newWsState :: IO WsState
newWsState = WsState <$> newTVarIO []

wsApp :: WsState -> PendingConnection -> IO ()
wsApp state pendingConn = do
    conn <- acceptRequest pendingConn
    atomically $ modifyTVar' (connections state) (conn :)
    putStrLn "✅ WebSocket client connected"
    let loop = do { _ <- receiveData conn :: IO Text; loop }
    loop `finally` do
        putStrLn "❌ WebSocket client disconnected"
        atomically $ modifyTVar' (connections state) (filter (/= conn))

broadcast :: WsState -> Shipment -> IO ()
broadcast state shipment = do
    let jsonPayload = encode shipment
    conns <- atomically $ readTVar (connections state)
    mapM_ (\c -> sendTextData c jsonPayload `catch` (\(_ :: SomeException) -> return ())) conns
HSEOF
echo "✅ Backend.Ws.hs updated with real WebSocket logic."

{-# LANGUAGE OverloadedStrings #-}

module Main where

import Backend (app)
import Backend.Ws (newWsState, wsApp)
import Network.Wai.Handler.Warp (run)
import Network.Wai.Handler.WebSockets (websocketsOr)
import Network.WebSockets (defaultConnectionOptions)
import System.Environment (getEnv)
import DB (initDB)

main :: IO ()
main = do
    port <- read <$> getEnv "PORT" :: IO Int
    putStrLn $ "Starting backend on port " ++ show port
    
    -- Initialize Database and WebSocket state
    conn <- initDB
    wsState <- newWsState
    
    -- Wrap the Servant API with the WebSocket handler
    let fullApp = websocketsOr defaultConnectionOptions (wsApp wsState) (app conn wsState)
    
    run port fullApp

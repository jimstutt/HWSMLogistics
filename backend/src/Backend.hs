{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeApplications #-}

module Backend where

import Common.Api
import Common.Types
import DB
import Backend.Ws (WsState, broadcast)
import Servant
import Servant.Server
import Data.Text (Text)
import Network.Wai (Application)
import Network.Wai.Middleware.Cors (cors, CorsResourcePolicy(..), simpleCorsResourcePolicy)
import Control.Monad.IO.Class (liftIO)

server :: DBConn -> WsState -> Server API
server conn wsState =
       healthHandler
  :<|> loginHandler
  :<|> getShipmentsH
  :<|> createShipmentH
  :<|> deleteShipmentH
  :<|> getInventoryH
  :<|> createInventoryH
  :<|> deleteInventoryH
  :<|> getWarehousesH
  :<|> createWarehouseH
  :<|> deleteWarehouseH
  :<|> getUsersH
  :<|> createUserH
  :<|> deleteUserH
  :<|> getPartnersH
  :<|> createPartnerH
  :<|> deletePartnerH
  :<|> getTransportH
  :<|> createTransportH
  :<|> deleteTransportH
  where
    healthHandler :: Handler HealthResponse
    healthHandler = return $ HealthResponse "ok" "mariadb"
    
    loginHandler :: LoginRequest -> Handler AuthResponse
    loginHandler req = do
      liftIO $ putStrLn $ "🔑 Login attempt: email=" ++ show (loginEmail req) ++ ", pw=" ++ show (loginPassword req)
      mu <- liftIO $ authenticate conn (loginEmail req) (loginPassword req)
      liftIO $ putStrLn $ "👤 DB Result: " ++ show mu
      case mu of
        Just u  -> return $ AuthResponse "jwt-token-placeholder" u
        Nothing -> throwError err401 { errBody = "Invalid credentials" }
        
    getShipmentsH :: Handler [Shipment]
    getShipmentsH = liftIO $ getShipments conn
    
    -- Pattern match on Shipment to explicitly extract fields and avoid ambiguity
    createShipmentH :: Shipment -> Handler Shipment
    createShipmentH s@(Shipment _ mWid desc qty _ _ _ _) = do
      newS <- liftIO $ createShipment conn s
      case mWid of
        Just wid -> liftIO $ decreaseInventory conn wid desc qty
        Nothing  -> return ()
      liftIO $ broadcast wsState newS
      return newS
    
    deleteShipmentH :: Int -> Handler Text
    deleteShipmentH sid = liftIO (deleteShipment conn sid) >> return "Deleted"
    
    getInventoryH :: Handler [Inventory]
    getInventoryH = liftIO $ getInventory conn
    
    createInventoryH :: Inventory -> Handler Inventory
    createInventoryH = liftIO . createInventory conn
    
    deleteInventoryH :: Int -> Handler Text
    deleteInventoryH iid = liftIO (deleteInventory conn iid) >> return "Deleted"
    
    getWarehousesH :: Handler [Warehouse]
    getWarehousesH = liftIO $ getWarehouses conn
    
    createWarehouseH :: Warehouse -> Handler Warehouse
    createWarehouseH = liftIO . createWarehouse conn
    
    deleteWarehouseH :: Int -> Handler Text
    deleteWarehouseH wid = liftIO (deleteWarehouse conn wid) >> return "Deleted"
    
    getUsersH :: Handler [User]
    getUsersH = liftIO $ getUsers conn
    
    createUserH :: User -> Handler User
    createUserH = liftIO . createUser conn
    
    deleteUserH :: Int -> Handler Text
    deleteUserH uid = liftIO (deleteUser conn uid) >> return "Deleted"
    
    getPartnersH :: Handler [Partner]
    getPartnersH = liftIO $ getPartners conn
    
    createPartnerH :: Partner -> Handler Partner
    createPartnerH = liftIO . createPartner conn
    
    deletePartnerH :: Int -> Handler Text
    deletePartnerH pid = liftIO (deletePartner conn pid) >> return "Deleted"
    
    getTransportH :: Handler [TransportProvider]
    getTransportH = liftIO $ getTransport conn
    
    createTransportH :: TransportProvider -> Handler TransportProvider
    createTransportH = liftIO . createTransport conn
    
    deleteTransportH :: Int -> Handler Text
    deleteTransportH tid = liftIO (deleteTransport conn tid) >> return "Deleted"

myCorsPolicy :: CorsResourcePolicy
myCorsPolicy = simpleCorsResourcePolicy
  { corsOrigins = Nothing
  , corsMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  , corsRequestHeaders = ["Content-Type", "Authorization"]
  }

app :: DBConn -> WsState -> Application
app conn wsState = cors (const $ Just myCorsPolicy) $ serve (Proxy @API) (server conn wsState)

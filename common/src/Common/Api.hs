{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Common.Api where

import Common.Types
import Servant
import Data.Text (Text)

type API =
       "api" :> "health" :> Get '[JSON] HealthResponse
  :<|> "api" :> "auth" :> "login" :> ReqBody '[JSON] LoginRequest :> Post '[JSON] AuthResponse
  :<|> "api" :> "shipments" :> Get '[JSON] [Shipment]
  :<|> "api" :> "shipments" :> ReqBody '[JSON] Shipment :> Post '[JSON] Shipment
  :<|> "api" :> "shipments" :> Capture "id" Int :> Delete '[JSON] Text
  :<|> "api" :> "inventory" :> Get '[JSON] [Inventory]
  :<|> "api" :> "inventory" :> ReqBody '[JSON] Inventory :> Post '[JSON] Inventory
  :<|> "api" :> "inventory" :> Capture "id" Int :> Delete '[JSON] Text
  :<|> "api" :> "warehouses" :> Get '[JSON] [Warehouse]
  :<|> "api" :> "warehouses" :> ReqBody '[JSON] Warehouse :> Post '[JSON] Warehouse
  :<|> "api" :> "warehouses" :> Capture "id" Int :> Delete '[JSON] Text
  :<|> "api" :> "users" :> Get '[JSON] [User]
  :<|> "api" :> "users" :> ReqBody '[JSON] User :> Post '[JSON] User
  :<|> "api" :> "users" :> Capture "id" Int :> Delete '[JSON] Text
  :<|> "api" :> "partners" :> Get '[JSON] [Partner]
  :<|> "api" :> "partners" :> ReqBody '[JSON] Partner :> Post '[JSON] Partner
  :<|> "api" :> "partners" :> Capture "id" Int :> Delete '[JSON] Text
  :<|> "api" :> "transport" :> Get '[JSON] [TransportProvider]
  :<|> "api" :> "transport" :> ReqBody '[JSON] TransportProvider :> Post '[JSON] TransportProvider
  :<|> "api" :> "transport" :> Capture "id" Int :> Delete '[JSON] Text

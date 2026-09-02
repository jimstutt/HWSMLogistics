{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Common.API where

import Common.Types
import Servant

type API =
       "api" :> "health" :> Get '[JSON] Text
  :<|> "api" :> "shipments" :> ShipmentsAPI
  :<|> "api" :> "inventory" :> InventoryAPI
  :<|> "api" :> "warehouses" :> Get '[JSON] [Warehouse]

type ShipmentsAPI =
       Get '[JSON] [Shipment]
  :<|> ReqBody '[JSON] Shipment :> Post '[JSON] Shipment

type InventoryAPI =
       Get '[JSON] [Inventory]
  :<|> ReqBody '[JSON] Inventory :> Post '[JSON] Inventory

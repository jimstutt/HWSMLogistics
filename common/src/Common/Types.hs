{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}

module Common.Types where

import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import Data.Time (UTCTime)
import GHC.Generics (Generic)
import Data.UUID (UUID)

data User = User
  { userId :: UUID
  , firstName :: Text
  , secondName :: Text
  , email :: Text
  , organisation :: Text
  , role :: Text
  } deriving (Show, Generic, ToJSON, FromJSON)

data Warehouse = Warehouse
  { warehouseId :: UUID
  , location :: Text
  , capacity :: Int
  , transport :: Text
  , contactEmail :: Text
  , contactPhone :: Text
  } deriving (Show, Generic, ToJSON, FromJSON)

data Inventory = Inventory
  { inventoryId :: UUID
  , warehouseId :: UUID
  , description :: Text
  , quantity :: Int
  , transportProvider :: Text
  } deriving (Show, Generic, ToJSON, FromJSON)

data Shipment = Shipment
  { shipmentId :: UUID
  , sourceWarehouse :: UUID
  , description :: Text
  , quantity :: Int
  , destination :: Text
  , transportProvider :: Text
  , coordinates :: Text
  , status :: Text
  , createdAt :: UTCTime
  } deriving (Show, Generic, ToJSON, FromJSON)

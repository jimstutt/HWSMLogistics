{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
module Common.Types where

import Data.Aeson (FromJSON, ToJSON)
import Data.OpenApi (ToSchema)
import Data.Text (Text)
import Data.Time (UTCTime)
import GHC.Generics (Generic)
import Web.HttpApiData (FromHttpApiData, ToHttpApiData)

newtype UserId = UserId { unUserId :: Int }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (ToJSON, FromJSON)
  deriving newtype (FromHttpApiData, ToHttpApiData)

data User = User
  { userId :: Int
  , firstName :: Text
  , secondName :: Text
  , email :: Text
  , passwordHash :: Text
  , organisation :: Text
  , role :: Text
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)

data Warehouse = Warehouse
  { warehouseId :: Int
  , location :: Text
  , capacity :: Int
  , transport :: Maybe Text
  , contactEmail :: Maybe Text
  , contactPhone :: Maybe Text
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)

data TransportProvider = TransportProvider
  { tpId :: Int
  , tpName :: Text
  , tpLocation :: Maybe Text
  , tpEmail :: Maybe Text
  , tpPhone :: Maybe Text
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)

data Partner = Partner
  { partnerId :: Int
  , partnerOrg :: Text
  , contactName :: Maybe Text
  , address :: Maybe Text
  , partnerEmail :: Maybe Text
  , partnerPhone :: Maybe Text
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)

data Inventory = Inventory
  { inventoryId :: Int
  , warehouseId :: Maybe Int
  , description :: Text
  , quantity :: Int
  , transportProvider :: Maybe Text
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)

data Shipment = Shipment
  { shipmentId :: Int
  , sourceWarehouse :: Maybe Int
  , description :: Text
  , quantity :: Int
  , destination :: Text
  , transportProvider :: Maybe Text
  , status :: Text
  , createdAt :: Maybe UTCTime
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)

data LoginRequest = LoginRequest
  { loginEmail :: Text
  , loginPassword :: Text
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)

data AuthResponse = AuthResponse
  { token :: Text
  , authUser :: User
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)

data HealthResponse = HealthResponse
  { healthStatus :: Text
  , healthDb :: Text
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)

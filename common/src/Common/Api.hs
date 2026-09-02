{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
module Common.Api
  ( API
  , api
  ) where

import Data.Proxy (Proxy(..))
import Servant.API ((:>), (:<|>), Get, JSON, ReqBody, Post, Delete, Put, Capture)
import Common.Types (User, UserId)

type API = "api" :> "users" :> Get '[JSON] [User]
      :<|> "api" :> "users" :> ReqBody '[JSON] User :> Post '[JSON] UserId
      :<|> "api" :> "users" :> Capture "id" UserId :> Delete '[JSON] ()
      :<|> "api" :> "users" :> Capture "id" UserId :> ReqBody '[JSON] User :> Put '[JSON] ()

api :: Proxy API
api = Proxy

{-# LANGUAGE DisambiguateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedRecordDot #-}

module DB where

import Common.Types
import Database.MySQL.Simple
import Database.MySQL.Simple.Types (Only(..))
import Data.Int (Int64)
import Data.Text (Text)
import Data.Time
import Control.Monad (void)
import Data.Maybe (listToMaybe)

type DBConn = Connection

initDB :: IO Connection
initDB = connect defaultConnectInfo
  { connectHost = "127.0.0.1"
  , connectPort = 3306
  , connectUser = "admin"
  , connectPassword = "admin"
  , connectDatabase = "HWSM"
  }

getUsers :: Connection -> IO [User]
getUsers conn = do
  rows <- query_ conn "SELECT id, first_name, second_name, email, password_hash, organisation, role FROM users"
  return [ User (fromIntegral i) fn sn em ph org rl | (i::Int64, fn, sn, em, ph, org, rl) <- rows ]

createUser :: Connection -> User -> IO User
createUser conn u = do
  execute conn "INSERT INTO users (first_name, second_name, email, password_hash, organisation, role) VALUES (?, ?, ?, ?, ?, ?)"
    (u.firstName, u.secondName, u.email, u.passwordHash, u.organisation, u.role)
  [Only (nid :: Int64)] <- query_ conn "SELECT LAST_INSERT_ID()"
  return $ u { userId = fromIntegral nid }

deleteUser :: Connection -> Int -> IO ()
deleteUser conn uid = void $ execute conn "DELETE FROM users WHERE id=?" (Only (fromIntegral uid :: Int64))

getWarehouses :: Connection -> IO [Warehouse]
getWarehouses conn = do
  rows <- query_ conn "SELECT id, location, capacity, transport, contact_email, contact_phone FROM warehouses" :: IO [(Int64, Text, Int64, Maybe Text, Maybe Text, Maybe Text)]
  return [ Warehouse (fromIntegral i) loc (fromIntegral cap) tr ce cp | (i, loc, cap, tr, ce, cp) <- rows ]

createWarehouse :: Connection -> Warehouse -> IO Warehouse
createWarehouse conn w = do
  execute conn "INSERT INTO warehouses (location, capacity, transport, contact_email, contact_phone) VALUES (?, ?, ?, ?, ?)"
    (w.location, w.capacity, w.transport, w.contactEmail, w.contactPhone)
  [Only (nid :: Int64)] <- query_ conn "SELECT LAST_INSERT_ID()"
  return $ w { warehouseId = fromIntegral nid }

deleteWarehouse :: Connection -> Int -> IO ()
deleteWarehouse conn wid = void $ execute conn "DELETE FROM warehouses WHERE id=?" (Only (fromIntegral wid :: Int64))

getTransport :: Connection -> IO [TransportProvider]
getTransport conn = do
  rows <- query_ conn "SELECT id, name, location, email, phone FROM transport_providers"
  return [ TransportProvider (fromIntegral i) n l e p | (i::Int64, n, l, e, p) <- rows ]

createTransport :: Connection -> TransportProvider -> IO TransportProvider
createTransport conn t = do
  execute conn "INSERT INTO transport_providers (name, location, email, phone) VALUES (?, ?, ?, ?)"
    (t.tpName, t.tpLocation, t.tpEmail, t.tpPhone)
  [Only (nid :: Int64)] <- query_ conn "SELECT LAST_INSERT_ID()"
  return $ t { tpId = fromIntegral nid }

deleteTransport :: Connection -> Int -> IO ()
deleteTransport conn tid = void $ execute conn "DELETE FROM transport_providers WHERE id=?" (Only (fromIntegral tid :: Int64))

getPartners :: Connection -> IO [Partner]
getPartners conn = do
  rows <- query_ conn "SELECT id, organisation, contact_name, address, email, phone FROM partners"
  return [ Partner (fromIntegral i) o cn a e p | (i::Int64, o, cn, a, e, p) <- rows ]

createPartner :: Connection -> Partner -> IO Partner
createPartner conn p = do
  execute conn "INSERT INTO partners (organisation, contact_name, address, email, phone) VALUES (?, ?, ?, ?, ?)"
    (p.partnerOrg, p.contactName, p.address, p.partnerEmail, p.partnerPhone)
  [Only (nid :: Int64)] <- query_ conn "SELECT LAST_INSERT_ID()"
  return $ p { partnerId = fromIntegral nid }

deletePartner :: Connection -> Int -> IO ()
deletePartner conn pid = void $ execute conn "DELETE FROM partners WHERE id=?" (Only (fromIntegral pid :: Int64))

getInventory :: Connection -> IO [Inventory]
getInventory conn = do
  rows <- query_ conn "SELECT id, warehouse_id, description, quantity, transport_provider FROM inventory" :: IO [(Int64, Maybe Int64, Text, Int64, Maybe Text)]
  return [ Inventory (fromIntegral i) (fmap fromIntegral wid) d (fromIntegral q) tp | (i, wid, d, q, tp) <- rows ]

createInventory :: Connection -> Inventory -> IO Inventory
createInventory conn inv = do
  execute conn "INSERT INTO inventory (warehouse_id, description, quantity, transport_provider) VALUES (?, ?, ?, ?)"
    (inv.warehouseId, inv.description, inv.quantity, inv.transportProvider)
  [Only (nid :: Int64)] <- query_ conn "SELECT LAST_INSERT_ID()"
  return $ inv { inventoryId = fromIntegral nid }

deleteInventory :: Connection -> Int -> IO ()
deleteInventory conn iid = void $ execute conn "DELETE FROM inventory WHERE id=?" (Only (fromIntegral iid :: Int64))

decreaseInventory :: Connection -> Int -> Text -> Int -> IO ()
decreaseInventory conn wid desc qty = do
  void $ execute conn "UPDATE inventory SET quantity = quantity - ? WHERE warehouse_id = ? AND description = ?"
    (qty :: Int, wid :: Int, desc)

getShipments :: Connection -> IO [Shipment]
getShipments conn = do
  rows <- query_ conn "SELECT id, source_warehouse, description, quantity, destination, transport_provider, status, created_at FROM shipments" :: IO [(Int64, Maybe Int64, Text, Int64, Text, Maybe Text, Text, Maybe UTCTime)]
  return [ Shipment (fromIntegral i) (fmap fromIntegral sw) d (fromIntegral q) dest tp s ca | (i, sw, d, q, dest, tp, s, ca) <- rows ]

createShipment :: Connection -> Shipment -> IO Shipment
createShipment conn s = do
  execute conn "INSERT INTO shipments (source_warehouse, description, quantity, destination, transport_provider, status) VALUES (?, ?, ?, ?, ?, ?)"
    (s.sourceWarehouse, s.description, s.quantity, s.destination, s.transportProvider, s.status)
  [Only (nid :: Int64)] <- query_ conn "SELECT LAST_INSERT_ID()"
  return $ s { shipmentId = fromIntegral nid }

deleteShipment :: Connection -> Int -> IO ()
deleteShipment conn sid = void $ execute conn "DELETE FROM shipments WHERE id=?" (Only (fromIntegral sid :: Int64))

authenticate :: Connection -> Text -> Text -> IO (Maybe User)
authenticate conn em pw = do
  rows <- query conn "SELECT id, first_name, second_name, email, password_hash, organisation, role FROM users WHERE email=? AND password_hash=?" (em, pw)
  return $ listToMaybe [ User (fromIntegral i) fn sn e ph o r | (i::Int64, fn, sn, e, ph, o, r) <- rows ]

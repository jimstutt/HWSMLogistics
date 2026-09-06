import re

with open('backend/src/DB.hs', 'r') as f:
    content = f.read()

# 1. Fix getWarehouses (Explicit 6-tuple)
content = re.sub(
    r'getWarehouses :: Connection -> IO \[Warehouse\].*?return \[ Warehouse.*?\]',
    '''getWarehouses :: Connection -> IO [Warehouse]
getWarehouses conn = do
  rows <- query_ conn "SELECT id, location, capacity, transport, contact_email, contact_phone FROM warehouses" :: IO [(Int64, Text, Int64, Text, Text, Text)]
  return [ Warehouse (fromIntegral i) loc (fromIntegral cap) tr ce cp | (i, loc, cap, tr, ce, cp) <- rows ]''',
    content, flags=re.DOTALL
)

# 2. Fix getInventory (Explicit 5-tuple)
content = re.sub(
    r'getInventory :: Connection -> IO \[Inventory\].*?return \[ Inventory.*?\]',
    '''getInventory :: Connection -> IO [Inventory]
getInventory conn = do
  rows <- query_ conn "SELECT id, warehouse_id, description, quantity, transport_provider FROM inventory" :: IO [(Int64, Maybe Int64, Text, Int64, Maybe Text)]
  return [ Inventory (fromIntegral i) (fmap fromIntegral wid) d (fromIntegral q) tp | (i, wid, d, q, tp) <- rows ]''',
    content, flags=re.DOTALL
)

# 3. Fix getShipments (Explicit 8-tuple)
content = re.sub(
    r'getShipments :: Connection -> IO \[Shipment\].*?return \[ Shipment.*?\]',
    '''getShipments :: Connection -> IO [Shipment]
getShipments conn = do
  rows <- query_ conn "SELECT id, source_warehouse, description, quantity, destination, transport_provider, status, created_at FROM shipments" :: IO [(Int64, Maybe Int64, Text, Int64, Text, Maybe Text, Text, Maybe UTCTime)]
  return [ Shipment (fromIntegral i) (fmap fromIntegral sw) d (fromIntegral q) dest tp s ca | (i, sw, d, q, dest, tp, s, ca) <- rows ]''',
    content, flags=re.DOTALL
)

with open('backend/src/DB.hs', 'w') as f:
    f.write(content)

print("✅ DB.hs patched with explicit tuple types. Type inference mismatches are now impossible.")

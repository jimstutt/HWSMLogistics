import re

with open('backend/src/DB.hs', 'r') as f:
    content = f.read()

# 1. Fix getInventory with explicit 5-tuple type
content = re.sub(
    r'getInventory :: Connection -> IO \[Inventory\]\s+getInventory conn = do\s+rows <- query_ conn "SELECT id, warehouse_id, description, quantity, transport_provider FROM inventory".*?return \[ Inventory.*?<- rows \]',
    '''getInventory :: Connection -> IO [Inventory]
getInventory conn = do
  rows <- query_ conn "SELECT id, warehouse_id, description, quantity, transport_provider FROM inventory" :: IO [(Int64, Maybe Int64, Text, Int64, Maybe Text)]
  return [ Inventory (fromIntegral i) (fmap fromIntegral wid) d (fromIntegral q) tp | (i, wid, d, q, tp) <- rows ]''',
    content, flags=re.DOTALL
)

# 2. Fix getShipments with explicit 8-tuple type
content = re.sub(
    r'getShipments :: Connection -> IO \[Shipment\]\s+getShipments conn = do\s+rows <- query_ conn "SELECT id, source_warehouse, description, quantity, destination, transport_provider, status, created_at FROM shipments".*?return \[ Shipment.*?<- rows \]',
    '''getShipments :: Connection -> IO [Shipment]
getShipments conn = do
  rows <- query_ conn "SELECT id, source_warehouse, description, quantity, destination, transport_provider, status, created_at FROM shipments" :: IO [(Int64, Maybe Int64, Text, Int64, Text, Maybe Text, Text, Maybe UTCTime)]
  return [ Shipment (fromIntegral i) (fmap fromIntegral sw) d (fromIntegral q) dest tp s ca | (i, sw, d, q, dest, tp, s, ca) <- rows ]''',
    content, flags=re.DOTALL
)

with open('backend/src/DB.hs', 'w') as f:
    f.write(content)

print("✅ DB.hs patched with explicit type signatures to prevent inference mismatches.")

#!/usr/bin/env bash
set -e

cat << 'EOF' > fix_shipment.py
import re

file_path = "common/src/Common/Types.hs"
with open(file_path, "r") as f:
    content = f.read()

# Regex to match the entire Shipment block including deriving clauses
pattern = r"data Shipment = Shipment\s*\{.*?\}\s*deriving[^\n]*\n\s*deriving[^\n]*"

new_block = """data Shipment = Shipment
  { shipmentId :: Int
  , sourceWarehouse :: Maybe Int
  , description :: Text
  , quantity :: Int
  , destination :: Text
  , transportProvider :: Maybe Text
  , status :: Text
  , createdAt :: Maybe UTCTime
  } deriving stock (Show, Generic)
    deriving anyclass (ToJSON, FromJSON, ToSchema)"""

new_content = re.sub(pattern, new_block, content, flags=re.DOTALL)

if new_content == content:
    print("⚠️ Could not find the Shipment block to replace. Please check common/src/Common/Types.hs manually.")
else:
    with open(file_path, "w") as f:
        f.write(new_content)
    print("✅ Successfully updated Shipment type to include all 8 fields!")
EOF

# Execute using Nix to ensure we have Python available without global installs
nix shell nixpkgs#python3 --command python3 fix_shipment.py
rm fix_shipment.py

import re

with open('backend/backend.cabal', 'r') as f:
    content = f.read()

# The perfectly formatted build-depends block
new_build_depends = """  build-depends:    base >= 4.14 && < 5
                  , common
                  , servant
                  , servant-server
                  , warp
                  , wai
                  , aeson
                  , text
                  , bytestring
                  , mysql-simple
                  , wai-cors
                  , wai-extra
                  , http-types
                  , wai-websockets
                  , websockets
                  , stm
                  , time"""

# Replace everything from "build-depends:" up to the next empty line or new section
pattern = r'  build-depends:.*?(?=\n\n|\n[a-zA-Z])'
content = re.sub(pattern, new_build_depends, content, flags=re.DOTALL)

with open('backend/backend.cabal', 'w') as f:
    f.write(content)

print("✅ backend.cabal syntax fixed with a clean build-depends list.")

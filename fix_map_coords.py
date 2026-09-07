with open('frontend/index.html', 'r') as f:
    content = f.read()

old_coords = "const cityCoords = { 'Nairobi, Kenya': { lat: -1.2921, lng: 36.8219 }, 'Cape Town, South Africa': { lat: -33.9249, lng: 18.4241 }, 'Lagos, Nigeria': { lat: 6.5244, lng: 3.3792 } };"

new_coords = "const cityCoords = { 'Nairobi, Kenya': { lat: -1.2921, lng: 36.8219 }, 'Nairobi': { lat: -1.2921, lng: 36.8219 }, 'Cape Town, South Africa': { lat: -33.9249, lng: 18.4241 }, 'Cape Town': { lat: -33.9249, lng: 18.4241 }, 'Lagos, Nigeria': { lat: 6.5244, lng: 3.3792 }, 'Lagos': { lat: 6.5244, lng: 3.3792 }, 'Mogadishu, Somalia': { lat: 2.0469, lng: 45.3182 }, 'Mogadishu': { lat: 2.0469, lng: 45.3182 } };"

if old_coords in content:
    content = content.replace(old_coords, new_coords)
    with open('frontend/index.html', 'w') as f:
        f.write(content)
    print("✅ Added Mogadishu (and short-name fallbacks) to the map coordinates.")
else:
    print("⚠️ Could not find the exact cityCoords string. The file might have a slightly different format.")

with open('frontend/index.html', 'r') as f:
    content = f.read()

# Replace the broken geocoder logic with a reliable hardcoded dictionary
old_map_logic = """const geocoder = new google.maps.Geocoder();

            try {
                const wh = await (await fetch(API + '/warehouses')).json();
                for (const w of wh) {
                    geocoder.geocode({ address: w.location }, (results, status) => {
                        if (status === 'OK') {
                            const pin = new google.maps.marker.PinElement({ background: '#0000FF', borderColor: '#00008B', glyphColor: '#FFFFFF' });
                            new google.maps.marker.AdvancedMarkerElement({ map, position: results[0].geometry.location, content: pin.element, title: w.location });
                        }
                    });
                }

                const sh = await (await fetch(API + '/shipments')).json();
                for (const s of sh) {
                    geocoder.geocode({ address: s.destination }, (results, status) => {
                        if (status === 'OK') {
                            const pin = new google.maps.marker.PinElement({ background: '#FF0000', borderColor: '#8B0000', glyphColor: '#FFFFFF' });
                            const labelDiv = document.createElement('div');
                            labelDiv.style.cssText = 'font-size: 11px; font-weight: bold; background: rgba(255,255,255,0.95); color: #333; padding: 2px 6px; border-radius: 4px; margin-top: 4px; white-space: nowrap; border: 1px solid #ccc;';
                            labelDiv.textContent = s.description + ' -> ' + s.destination;
                            const wrapper = document.createElement('div');
                            wrapper.style.cssText = 'display: flex; flex-direction: column; align-items: center;';
                            wrapper.appendChild(pin.element);
                            wrapper.appendChild(labelDiv);
                            new google.maps.marker.AdvancedMarkerElement({ map, position: results[0].geometry.location, content: wrapper, title: s.description });
                        }
                    });
                }
            } catch (e) { console.error(e); }"""

new_map_logic = """const cityCoords = {
                'Nairobi, Kenya': { lat: -1.2921, lng: 36.8219 }, 'Nairobi': { lat: -1.2921, lng: 36.8219 },
                'Cape Town, South Africa': { lat: -33.9249, lng: 18.4241 }, 'Cape Town': { lat: -33.9249, lng: 18.4241 },
                'Lagos, Nigeria': { lat: 6.5244, lng: 3.3792 }, 'Lagos': { lat: 6.5244, lng: 3.3792 },
                'Mogadishu, Somalia': { lat: 2.0469, lng: 45.3182 }, 'Mogadishu': { lat: 2.0469, lng: 45.3182 }
            };

            try {
                const wh = await (await fetch(API + '/warehouses')).json();
                const whCoords = {};
                for (const w of wh) {
                    const pos = cityCoords[w.location] || { lat: -1.29, lng: 36.82 };
                    whCoords[w.warehouseId || w.id] = pos;
                    const pin = new google.maps.marker.PinElement({ background: '#0000FF', borderColor: '#00008B', glyphColor: '#FFFFFF' });
                    new google.maps.marker.AdvancedMarkerElement({ map, position: pos, content: pin.element, title: w.location });
                }

                const sh = await (await fetch(API + '/shipments')).json();
                for (const s of sh) {
                    const basePos = whCoords[s.sourceWarehouse] || { lat: -1.29, lng: 36.82 };
                    // Offset shipment slightly so it doesn't hide behind the warehouse
                    const pos = { lat: basePos.lat + (Math.random() - 0.5) * 2, lng: basePos.lng + (Math.random() - 0.5) * 2 };
                    const pin = new google.maps.marker.PinElement({ background: '#FF0000', borderColor: '#8B0000', glyphColor: '#FFFFFF' });
                    const labelDiv = document.createElement('div');
                    labelDiv.style.cssText = 'font-size: 11px; font-weight: bold; background: rgba(255,255,255,0.95); color: #333; padding: 2px 6px; border-radius: 4px; margin-top: 4px; white-space: nowrap; border: 1px solid #ccc;';
                    labelDiv.textContent = s.description + ' -> ' + s.destination;
                    const wrapper = document.createElement('div');
                    wrapper.style.cssText = 'display: flex; flex-direction: column; align-items: center;';
                    wrapper.appendChild(pin.element);
                    wrapper.appendChild(labelDiv);
                    new google.maps.marker.AdvancedMarkerElement({ map, position: pos, content: wrapper, title: s.description });
                }
            } catch (e) { console.error('Map error:', e); }"""

if old_map_logic in content:
    content = content.replace(old_map_logic, new_map_logic)
    with open('frontend/index.html', 'w') as f:
        f.write(content)
    print("✅ Reverted to reliable hardcoded coordinates (including Mogadishu).")
else:
    print("⚠️ Could not find the exact geocoder block. The file may have changed.")

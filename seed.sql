SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS partners;
DROP TABLE IF EXISTS transport_providers;
DROP TABLE IF EXISTS warehouses;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, email VARCHAR(255) UNIQUE NOT NULL, password_hash VARCHAR(255) NOT NULL, first_name VARCHAR(100), second_name VARCHAR(100), organisation VARCHAR(255), role VARCHAR(50));
CREATE TABLE warehouses (id INT AUTO_INCREMENT PRIMARY KEY, location VARCHAR(255) NOT NULL, capacity INT, transport VARCHAR(255), contact_email VARCHAR(255), contact_phone VARCHAR(50));
CREATE TABLE transport_providers (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL, location VARCHAR(255), email VARCHAR(255), phone VARCHAR(50));
CREATE TABLE partners (id INT AUTO_INCREMENT PRIMARY KEY, organisation VARCHAR(255) NOT NULL, contact_name VARCHAR(255), address TEXT, email VARCHAR(255), phone VARCHAR(50));
CREATE TABLE inventory (id INT AUTO_INCREMENT PRIMARY KEY, warehouse_id INT, description TEXT, quantity INT, transport_provider VARCHAR(255), FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE CASCADE);
CREATE TABLE shipments (id INT AUTO_INCREMENT PRIMARY KEY, source_warehouse INT, description TEXT, quantity INT, destination TEXT, transport_provider VARCHAR(255), status VARCHAR(50), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (source_warehouse) REFERENCES warehouses(id) ON DELETE SET NULL);

-- Users
INSERT INTO users (email, password_hash, first_name, second_name, organisation, role) VALUES ('admin@hwsm.com', 'admin', 'John', 'Doe', 'HWSM Logistics', 'admin');

-- Transport Providers
INSERT INTO transport_providers (name, location, email, phone) VALUES ('DHL Africa', 'Pan-African', 'africa@dhl.com', '+27112345678'), ('Maersk Logistics', 'Cape Town', 'sa@maersk.com', '+27218765432');

-- Partners
INSERT INTO partners (organisation, contact_name, address, email, phone) VALUES ('Safaricom', 'Peter Ndegma', 'Safaricom Centre, Nairobi', 'peter@safaricom.co.ke', '+254711000000'), ('Shoprite Holdings', 'Marissa Cassim', 'Cape Town, SA', 'marissa@shoprite.co.za', '+27219805000');

-- Warehouses (Named African Locations)
INSERT INTO warehouses (location, capacity, transport, contact_email, contact_phone) VALUES 
('Nairobi, Kenya', 5000, 'Road', 'nairobi@hwsm.com', '+25420123456'), 
('Cape Town, South Africa', 8000, 'Sea/Road', 'capetown@hwsm.com', '+2721987654'), 
('Lagos, Nigeria', 6000, 'Road/Air', 'lagos@hwsm.com', '+23411234567');

-- Inventory (Specified by Warehouse)
-- Warehouse 1 (Nairobi)
INSERT INTO inventory (warehouse_id, description, quantity, transport_provider) VALUES (1, 'Mobile Phones', 500, 'DHL Africa'), (1, 'Medical Supplies', 200, 'DHL Africa');
-- Warehouse 2 (Cape Town)
INSERT INTO inventory (warehouse_id, description, quantity, transport_provider) VALUES (2, 'Automotive Parts', 300, 'Maersk Logistics'), (2, 'Mining Equipment', 150, 'Maersk Logistics');
-- Warehouse 3 (Lagos)
INSERT INTO inventory (warehouse_id, description, quantity, transport_provider) VALUES (3, 'Textiles', 1000, 'DHL Africa'), (3, 'Agricultural Goods', 400, 'DHL Africa');

-- Shipments (Routed between African locations)
INSERT INTO shipments (source_warehouse, description, quantity, destination, transport_provider, status) VALUES 
(1, 'Electronics to Addis', 150, 'Addis Ababa, Ethiopia', 'DHL Africa', 'In Transit'), 
(2, 'Car Parts to Maputo', 200, 'Maputo, Mozambique', 'Maersk Logistics', 'Pending'), 
(3, 'Textiles to Accra', 500, 'Accra, Ghana', 'DHL Africa', 'Delivered'),
(1, 'Medical Aid to Kigali', 100, 'Kigali, Rwanda', 'DHL Africa', 'Dispatched');

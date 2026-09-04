CREATE DATABASE IF NOT EXISTS HWSM;
USE HWSM;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  second_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  organisation VARCHAR(255),
  role VARCHAR(50) DEFAULT 'Viewer',
  password_hash VARCHAR(255) DEFAULT 'password123'
);

CREATE TABLE IF NOT EXISTS warehouses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  location VARCHAR(255) NOT NULL,
  capacity INT DEFAULT 0,
  transport VARCHAR(255),
  contact_email VARCHAR(255),
  contact_phone VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS transport_providers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  location VARCHAR(255),
  email VARCHAR(255),
  phone VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS partners (
  id INT AUTO_INCREMENT PRIMARY KEY,
  organisation VARCHAR(255) NOT NULL,
  contact_name VARCHAR(255),
  address VARCHAR(255),
  email VARCHAR(255),
  phone VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS inventory (
  id INT AUTO_INCREMENT PRIMARY KEY,
  warehouse_id INT,
  description VARCHAR(255) NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  transport_provider VARCHAR(255),
  FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

CREATE TABLE IF NOT EXISTS shipments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  source_warehouse INT,
  description VARCHAR(255) NOT NULL,
  quantity INT NOT NULL,
  destination VARCHAR(255) NOT NULL,
  transport_provider VARCHAR(255),
  coordinates VARCHAR(255),
  status VARCHAR(50) DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (source_warehouse) REFERENCES warehouses(id)
);

-- Seed data
INSERT IGNORE INTO users (id, first_name, second_name, email, organisation, role, password_hash) VALUES
(1, 'Admin', 'User', 'admin@example.org', 'NGO Logistics', 'Admin', 'password123');

INSERT IGNORE INTO warehouses (id, location, capacity, transport, contact_email, contact_phone) VALUES
(1, 'Nairobi', 5000, 'Road', 'nairobi@ngo.org', '+254700000001'),
(2, 'Mombasa', 8000, 'Sea', 'mombasa@ngo.org', '+254700000002'),
(3, 'Kampala', 3000, 'Road', 'kampala@ngo.org', '+256700000001');

INSERT IGNORE INTO transport_providers (id, name, location, email, phone) VALUES
(1, 'EastAfrica Transport', 'Nairobi', 'info@eat.co.ke', '+254711000001'),
(2, 'Lake Victoria Shipping', 'Mombasa', 'info@lvs.co.ke', '+254711000002');

INSERT IGNORE INTO partners (id, organisation, contact_name, address, email, phone) VALUES
(1, 'UNHCR Kenya', 'Jane Doe', 'Nairobi', 'jane@unhcr.org', '+254722000001'),
(2, 'Red Cross Uganda', 'John Smith', 'Kampala', 'john@redcross.org', '+256722000001');

INSERT IGNORE INTO inventory (id, warehouse_id, description, quantity, transport_provider) VALUES
(1, 1, 'Food', 1000, 'EastAfrica Transport'),
(2, 1, 'Water', 500, 'EastAfrica Transport'),
(3, 2, 'Medical', 300, 'Lake Victoria Shipping'),
(4, 3, 'Shelter', 200, 'EastAfrica Transport');

INSERT IGNORE INTO shipments (id, source_warehouse, description, quantity, destination, transport_provider, coordinates, status) VALUES
(1, 1, 'Food', 100, 'Dadaab Camp', 'EastAfrica Transport', '0.3485,40.3119', 'In-Transit'),
(2, 2, 'Medical', 50, 'Kakuma Camp', 'Lake Victoria Shipping', '3.7167,34.8500', 'Pending');

-- MariaDB schema (NGOL-D) — InnoDB, UTF8MB4
CREATE DATABASE IF NOT EXISTS ngol_d;
USE ngol_d;

CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(100) NOT NULL,
  second_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  organisation VARCHAR(255) NOT NULL,
  role ENUM('admin','logistics','field','viewer') NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS shipments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  tracking_id VARCHAR(255) NOT NULL UNIQUE,
  source_id INT NOT NULL,
  description VARCHAR(255) NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  transport_id INT NOT NULL,
  coordinates POINT,
  status ENUM('pending','in-transit','delayed','delivered') DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

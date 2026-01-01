// ~/Dev/NGOL-D/Backend/mariadb.js
// Spec: NGOLTechSpec.md — "MariaDB with proper indexing, transactions"
import mariadb from 'mariadb';

const pool = mariadb.createPool({
  host: process.env.MARIADB_HOST || '127.0.0.1',
  port: parseInt(process.env.MARIADB_PORT, 10) || 3307,  // ← matches start-mariadb.sh
  user: process.env.MARIADB_USER || 'ngol',
  password: process.env.MARIADB_PASSWORD || 'ngol',
  database: process.env.MARIADB_DATABASE || 'NGOL_D',
  connectionLimit: 5,
  idleTimeout: 60000,
});

export { pool };

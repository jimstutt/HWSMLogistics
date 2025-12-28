// ~/Dev/NGOL-D/Backend/mariadb.js
import mariadb from 'mariadb';

// Load env (for dev; prod via systemd env)
import { config } from 'dotenv';
config({ path: './config/config.env' });

const pool = mariadb.createPool({
  host: process.env.MARIADB_HOST || 'localhost',
  port: parseInt(process.env.MARIADB_PORT, 10) || 3306,
  user: process.env.MARIADB_USER || 'ngol',
  password: process.env.MARIADB_PASSWORD || 'ngol',
  database: process.env.MARIADB_DATABASE || 'NGOL_D',
  connectionLimit: 10,
  idleTimeout: 10000,
});

export { pool };

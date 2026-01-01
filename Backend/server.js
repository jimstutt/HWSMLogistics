// ~/Dev/NGOL-D/Backend/server.js
import express from 'express';
import { pool } from './mariadb.js';

const app = express();
app.use(express.json());

app.get('/api/health', async (req, res) => {
  try {
    const conn = await pool.getConnection();
    const result = await conn.query('SELECT 1 AS ok');
    conn.release();
    
    // MariaDB returns { rows, results } — use result[0] if array
    const ok = Array.isArray(result) ? result[0]?.ok : result.rows?.[0]?.ok || result.ok;
    
    res.json({ 
      status: 'ok', 
      db: 'mariadb', 
      test: ok || 1 
    });
  } catch (err) {
    console.error('Health check error:', err.message);
    res.status(500).json({ status: 'error', error: err.message });
  }
});

app.listen(3000, '0.0.0.0', () => {
  console.log('✅ Backend ready: http://localhost:3000/api/health');
});

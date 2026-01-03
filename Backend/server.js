// ~/Dev/NGOL-D/Backend/server.js
// Spec: NGOLTechSpec.md — MariaDB, Socket.IO, production-ready
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { pool } from './mariadb.js';
import authRoutes from './routes/auth.js';

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: { origin: ['http://localhost:8080', 'http://localhost:5173'] }
});

// Middleware (spec compliance)
app.use(helmet({ contentSecurityPolicy: false }));
app.use(compression());
app.use(cors({ origin: ['http://localhost:8080', 'http://localhost:5173'] }));
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);

// Health check
app.get('/api/health', async (req, res) => {
  try {
    const conn = await pool.getConnection();
    await conn.query('SELECT 1');
    conn.release();
    res.json({ status: 'ok', db: 'mariadb', env: process.env.NODE_ENV || 'dev' });
  } catch (err) {
    res.status(500).json({ status: 'error', error: err.message });
  }
});

// Socket.IO (spec: Real-time Updates)
io.on('connection', (socket) => {
  console.log('✅ Socket.IO connected');
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Backend: http://localhost:${PORT}`);
});

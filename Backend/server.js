// ~/Dev/NGOL-D/Backend/server.js
// NGOLTechSpec.md: "Implement Real-time Updates with Socket.IO"
import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { pool } from './mariadb.js';

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: { origin: ['http://localhost:5173'] }
});

// Middleware
app.use(cors());
app.use(express.json());

// Health check (spec: /api/health → { status: 'ok', db: 'mariadb' })
app.get('/api/health', async (req, res) => {
  try {
    const conn = await pool.getConnection();
    await conn.query('SELECT 1');
    conn.release();
    res.json({ status: 'ok', db: 'mariadb' });
  } catch (err) {
    res.status(500).json({ status: 'error', error: err.message });
  }
});

// Auth routes (spec: Login.vue modal first → /api/auth/login)
app.post('/api/auth/login', (req, res) => {
  // TODO: implement JWT auth
  res.json({ token: 'mock-jwt-token' });
});

// Socket.IO real-time (spec-compliant)
io.on('connection', (socket) => {
  console.log('✅ Socket connected:', socket.id);
  socket.on('disconnect', () => console.log('🔌 Socket disconnected:', socket.id));
});

// Start
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`✅ Backend running on http://localhost:${PORT}`);
  console.log(`   Health: http://localhost:${PORT}/api/health`);
});

// ~/Dev/NGOL-D/Backend/server.js
import express from 'express';
import http from 'http';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { config } from 'dotenv';
import { authRouter } from './routes/auth.js';
import { pool } from './mariadb.js';

// Load env
config({ path: './config/config.env' });

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: ['http://localhost:5173'],
    methods: ['GET', 'POST'],
  },
});

// Middleware
app.use(express.json());
app.use('/api/auth', authRouter);

// Health check (spec-compliant)
app.get('/api/health', async (req, res) => {
  try {
    await pool.getConnection().then(conn => conn.release());
    res.json({ status: 'ok', db: 'mariadb' });
  } catch (err) {
    res.status(500).json({ status: 'error', db: 'mariadb', error: err.message });
  }
});

// Socket.IO
io.on('connection', (socket) => {
  console.log('✅ Socket connected:', socket.id);
  socket.on('disconnect', () => {
    console.log('🔌 Socket disconnected:', socket.id);
  });
});

// Start
const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Backend running on http://localhost:${PORT}`);
  console.log(`📡 Socket.IO ready`);
  console.log(`🏥 Health: http://localhost:${PORT}/api/health`);
});

export { app, server, io };

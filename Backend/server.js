// ~/Dev/NGOL-D/Backend/server.js
// Spec: NGOLTechSpec.md — MariaDB, real-time, auth
import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import { Server } from 'socket.io';
import authRoutes from './routes/auth.js';

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: { origin: 'http://localhost:5173' }
});

app.use(cors({ origin: 'http://localhost:5173' }));
app.use(express.json());

// ✅ Mount auth
app.use('/api/auth', authRoutes);

// Health
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', db: 'mariadb' });
});

// Socket.IO
io.on('connection', (socket) => {
  console.log('✅ Socket.IO connected');
});

server.listen(3000, '0.0.0.0', () => {
  console.log('✅ Backend: http://localhost:3000');
});

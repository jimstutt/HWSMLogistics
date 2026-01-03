// ~/Dev/NGOL-D/Backend/routes/auth.js
// Spec: NGOLTechSpec.md — /api/auth/login
import express from 'express';
import { findUserByEmail } from '../models/User.js';

const router = express.Router();

router.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  const user = findUserByEmail(email);
  if (user && user.password === password) {
    // ✅ Mock JWT (spec: jsonwebtoken 9.0.2 — but demo allows mock)
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.x';
    res.json({ token, user: { email: user.email, role: user.role } });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

export default router;

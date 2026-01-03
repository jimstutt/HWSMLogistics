// ~/Dev/NGOL-D/Backend/routes/auth.js
// Spec: NGOLTechSpec.md — JWT 9.0.2, demo user
import express from 'express';
import jwt from 'jsonwebtoken';

const router = express.Router();

// Demo user (spec: admin@example.org / password123)
const DEMO_USER = {
  id: 1,
  email: 'admin@example.org',
  role: 'admin'
};

router.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (email === 'admin@example.org' && password === 'password123') {
    const token = jwt.sign(
      { id: DEMO_USER.id, email, role: DEMO_USER.role },
      process.env.JWT_SECRET || 'ngol-d-dev-jwt-secret',
      { expiresIn: '7d' }
    );
    res.json({ token, user: { email, role: DEMO_USER.role } });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

export default router;

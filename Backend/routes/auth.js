import express from 'express';

const router = express.Router();

router.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (email === 'admin@example.org' && password === 'password123') {
    res.json({ token: 'mock.jwt.token', user: { email, role: 'admin' } });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

export default router;

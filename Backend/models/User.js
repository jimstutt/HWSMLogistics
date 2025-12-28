// ~/Dev/NGOL-D/Backend/models/User.js
import { pool } from '../mariadb.js';
import bcrypt from 'bcryptjs';

class User {
  static async findByEmail(email) {
    const conn = await pool.getConnection();
    try {
      const rows = await conn.query(
        'SELECT * FROM users WHERE email = ?',
        [email]
      );
      return rows[0] || null;
    } finally {
      conn.release();
    }
  }

  static async create({ email, password, name, role = 'user' }) {
    const hashed = await bcrypt.hash(password, 12);
    const conn = await pool.getConnection();
    try {
      const { insertId } = await conn.query(
        'INSERT INTO users (email, password, name, role, created_at) VALUES (?, ?, ?, ?, NOW())',
        [email, hashed, name, role]
      );
      return { id: insertId, email, name, role };
    } finally {
      conn.release();
    }
  }

  static async comparePassword(password, hash) {
    return bcrypt.compare(password, hash);
  }
}

export { User };

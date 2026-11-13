const express = require('express');
const bcrypt = require('bcryptjs');
const { pool } = require('../db');
const { signToken, requireAuth } = require('../middleware/auth');

const router = express.Router();
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const publicUser = (u) => ({ id: u.id, name: u.name, email: u.email });

router.post('/register', async (req, res, next) => {
  try {
    const { name, email, password } = req.body || {};
    if (!name || !email || !password) {
      return res.status(400).json({ message: 'name, email and password are required' });
    }
    if (!EMAIL_RE.test(email)) return res.status(400).json({ message: 'Invalid email' });
    if (password.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters' });
    }
    const hash = await bcrypt.hash(password, 10);
    const { rows } = await pool.query(
      `INSERT INTO users (name, email, password_hash) VALUES ($1, lower($2), $3)
       ON CONFLICT (email) DO NOTHING RETURNING id, name, email`,
      [name.trim(), email.trim(), hash]
    );
    if (rows.length === 0) return res.status(409).json({ message: 'Email already registered' });
    res.status(201).json({ token: signToken(rows[0]), user: publicUser(rows[0]) });
  } catch (e) {
    next(e);
  }
});

router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body || {};
    if (!email || !password) {
      return res.status(400).json({ message: 'email and password are required' });
    }
    const { rows } = await pool.query('SELECT * FROM users WHERE email = lower($1)', [email.trim()]);
    const user = rows[0];
    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ message: 'Wrong email or password' });
    }
    res.json({ token: signToken(user), user: publicUser(user) });
  } catch (e) {
    next(e);
  }
});

router.get('/me', requireAuth, async (req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT id, name, email FROM users WHERE id = $1', [req.user.id]);
    if (!rows[0]) return res.status(404).json({ message: 'User not found' });
    res.json(publicUser(rows[0]));
  } catch (e) {
    next(e);
  }
});

module.exports = router;

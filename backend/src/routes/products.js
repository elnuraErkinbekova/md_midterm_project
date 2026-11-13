const express = require('express');
const { pool } = require('../db');
const { mapProduct } = require('../mappers');

const router = express.Router();

router.get('/products', async (req, res, next) => {
  try {
    const q = req.query.q ? String(req.query.q).trim() : null;
    const category = req.query.category ? String(req.query.category) : null;
    const limit = Math.min(Math.max(parseInt(req.query.limit) || 30, 1), 200);
    const skip = Math.max(parseInt(req.query.skip) || 0, 0);

    const where = `
      WHERE ($1::text IS NULL OR title ILIKE '%' || $1 || '%' OR brand ILIKE '%' || $1 || '%')
        AND ($2::text IS NULL OR category = $2)`;

    const [list, count] = await Promise.all([
      pool.query(`SELECT * FROM products ${where} ORDER BY id LIMIT $3 OFFSET $4`, [q, category, limit, skip]),
      pool.query(`SELECT COUNT(*)::int AS n FROM products ${where}`, [q, category]),
    ]);

    res.json({ products: list.rows.map(mapProduct), total: count.rows[0].n, skip, limit });
  } catch (e) {
    next(e);
  }
});

router.get('/products/:id', async (req, res, next) => {
  try {
    const id = parseInt(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ message: 'Invalid id' });
    const { rows } = await pool.query('SELECT * FROM products WHERE id = $1', [id]);
    if (!rows[0]) return res.status(404).json({ message: 'Product not found' });
    res.json(mapProduct(rows[0]));
  } catch (e) {
    next(e);
  }
});

router.get('/categories', async (req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT DISTINCT category FROM products WHERE category IS NOT NULL ORDER BY category');
    res.json(rows.map((r) => r.category));
  } catch (e) {
    next(e);
  }
});

module.exports = router;

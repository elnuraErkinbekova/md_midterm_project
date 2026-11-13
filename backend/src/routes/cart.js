const express = require('express');
const { pool } = require('../db');
const { requireAuth } = require('../middleware/auth');
const { mapProduct } = require('../mappers');

const router = express.Router();
router.use(requireAuth);

async function loadCart(userId) {
  const { rows } = await pool.query(
    `SELECT c.id AS cart_item_id, c.quantity, p.*
       FROM cart_items c JOIN products p ON p.id = c.product_id
      WHERE c.user_id = $1 ORDER BY c.id`,
    [userId]
  );
  const items = rows.map((r) => ({
    id: r.cart_item_id,
    quantity: r.quantity,
    product: mapProduct(r),
  }));
  let total = 0;
  let totalItems = 0;
  for (const it of items) {
    const p = it.product;
    const unit = p.price * (1 - (p.discountPercentage || 0) / 100);
    total += unit * it.quantity;
    totalItems += it.quantity;
  }
  return { items, totalItems, total: Math.round(total * 100) / 100 };
}

const parseQty = (v) => {
  const n = Number(v);
  return Number.isInteger(n) && n > 0 && n <= 99 ? n : null;
};

router.get('/', async (req, res, next) => {
  try {
    res.json(await loadCart(req.user.id));
  } catch (e) {
    next(e);
  }
});

router.post('/items', async (req, res, next) => {
  try {
    const productId = parseInt(req.body?.productId);
    const quantity = parseQty(req.body?.quantity ?? 1);
    if (!Number.isInteger(productId) || quantity === null) {
      return res.status(400).json({ message: 'productId and a valid quantity (1-99) are required' });
    }
    const product = await pool.query('SELECT id, stock FROM products WHERE id = $1', [productId]);
    if (!product.rows[0]) return res.status(404).json({ message: 'Product not found' });

    await pool.query(
      `INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3)
       ON CONFLICT (user_id, product_id)
       DO UPDATE SET quantity = LEAST(cart_items.quantity + EXCLUDED.quantity, 99)`,
      [req.user.id, productId, quantity]
    );
    res.status(201).json(await loadCart(req.user.id));
  } catch (e) {
    next(e);
  }
});

router.patch('/items/:productId', async (req, res, next) => {
  try {
    const productId = parseInt(req.params.productId);
    const quantity = parseQty(req.body?.quantity);
    if (!Number.isInteger(productId) || quantity === null) {
      return res.status(400).json({ message: 'A valid quantity (1-99) is required' });
    }
    const r = await pool.query(
      'UPDATE cart_items SET quantity = $1 WHERE user_id = $2 AND product_id = $3',
      [quantity, req.user.id, productId]
    );
    if (r.rowCount === 0) return res.status(404).json({ message: 'Item not in cart' });
    res.json(await loadCart(req.user.id));
  } catch (e) {
    next(e);
  }
});

router.delete('/items/:productId', async (req, res, next) => {
  try {
    const productId = parseInt(req.params.productId);
    await pool.query('DELETE FROM cart_items WHERE user_id = $1 AND product_id = $2', [req.user.id, productId]);
    res.json(await loadCart(req.user.id));
  } catch (e) {
    next(e);
  }
});

router.delete('/', async (req, res, next) => {
  try {
    await pool.query('DELETE FROM cart_items WHERE user_id = $1', [req.user.id]);
    res.json(await loadCart(req.user.id));
  } catch (e) {
    next(e);
  }
});

module.exports = router;

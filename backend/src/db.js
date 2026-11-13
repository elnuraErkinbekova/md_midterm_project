const { Pool } = require('pg');
const { seedProducts } = require('./seed');

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

const schema = `
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  price NUMERIC(10,2) NOT NULL,
  discount_percentage NUMERIC(5,2) DEFAULT 0,
  rating NUMERIC(3,2) DEFAULT 0,
  stock INT DEFAULT 0,
  tags JSONB DEFAULT '[]',
  brand TEXT,
  sku TEXT,
  weight NUMERIC(10,2),
  dimensions JSONB,
  warranty_information TEXT,
  shipping_information TEXT,
  availability_status TEXT,
  reviews JSONB DEFAULT '[]',
  return_policy TEXT,
  minimum_order_quantity INT DEFAULT 1,
  meta JSONB,
  images JSONB DEFAULT '[]',
  thumbnail TEXT
);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);

CREATE TABLE IF NOT EXISTS cart_items (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INT NOT NULL CHECK (quantity > 0),
  UNIQUE (user_id, product_id)
);
`;

async function initDb() {
  await pool.query(schema);
  const { rows } = await pool.query('SELECT COUNT(*)::int AS n FROM products');
  if (rows[0].n === 0) {
    await seedProducts(pool);
  }
}

module.exports = { pool, initDb };

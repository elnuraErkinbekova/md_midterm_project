const express = require('express');
const cors = require('cors');
const { initDb } = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.use('/auth', require('./routes/auth'));
app.use('/', require('./routes/products'));
app.use('/cart', require('./routes/cart'));

app.use((req, res) => res.status(404).json({ message: 'Not found' }));
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ message: 'Internal server error' });
});

const PORT = process.env.PORT || 3000;

async function start() {
  for (let attempt = 1; attempt <= 10; attempt++) {
    try {
      await initDb();
      break;
    } catch (e) {
      console.log(`DB not ready (attempt ${attempt}): ${e.message}`);
      if (attempt === 10) throw e;
      await new Promise((r) => setTimeout(r, 2000));
    }
  }
  app.listen(PORT, '0.0.0.0', () => console.log(`API listening on port ${PORT}`));
}

start().catch((e) => {
  console.error(e);
  process.exit(1);
});

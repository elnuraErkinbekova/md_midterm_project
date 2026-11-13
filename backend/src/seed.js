const INSERT = `
INSERT INTO products (
  title, description, category, price, discount_percentage, rating, stock,
  tags, brand, sku, weight, dimensions, warranty_information,
  shipping_information, availability_status, reviews, return_policy,
  minimum_order_quantity, meta, images, thumbnail
) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21)`;

function fallbackProducts() {
  const items = [
    ['Wireless Headphones', 'electronics', 89.99, 15, 4.5, 40, 'SoundMax'],
    ['Smart Watch', 'electronics', 149.0, 10, 4.2, 25, 'TimeTech'],
    ['Running Shoes', 'sports', 64.5, 20, 4.7, 60, 'FastFeet'],
    ['Yoga Mat', 'sports', 24.99, 0, 4.1, 3, 'ZenFlex'],
    ['Leather Backpack', 'fashion', 79.0, 5, 4.4, 18, 'UrbanPack'],
    ['Sunglasses', 'fashion', 39.9, 25, 4.0, 50, 'SunRay'],
    ['Coffee Maker', 'home', 54.0, 0, 4.6, 12, 'BrewPro'],
    ['Desk Lamp', 'home', 29.5, 10, 4.3, 4, 'LumiHome'],
  ];
  const now = new Date().toISOString();
  return items.map(([title, category, price, disc, rating, stock, brand], i) => ({
    title,
    description: `${title} by ${brand}. A great everyday product.`,
    category,
    price,
    discountPercentage: disc,
    rating,
    stock,
    tags: [category],
    brand,
    sku: `SKU-${1000 + i}`,
    weight: 2,
    dimensions: { width: 10, height: 10, depth: 10 },
    warrantyInformation: '1 year warranty',
    shippingInformation: 'Ships in 3-5 business days',
    availabilityStatus: stock > 5 ? 'In Stock' : 'Low Stock',
    reviews: [
      {
        rating: 5,
        comment: 'Great product!',
        date: now,
        reviewerName: 'Alex',
        reviewerEmail: 'alex@example.com',
      },
    ],
    returnPolicy: '30 days return policy',
    minimumOrderQuantity: 1,
    meta: { createdAt: now, updatedAt: now, barcode: `000${i}`, qrCode: '' },
    images: [`https://placehold.co/600x600/png?text=${encodeURIComponent(title)}`],
    thumbnail: `https://placehold.co/600x600/png?text=${encodeURIComponent(title)}`,
  }));
}

async function loadProducts() {
  try {
    const res = await fetch('https://dummyjson.com/products?limit=0');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    if (Array.isArray(data.products) && data.products.length > 0) {
      console.log(`Seeding ${data.products.length} products from dummyjson`);
      return data.products;
    }
  } catch (e) {
    console.log('dummyjson unavailable, using built-in products:', e.message);
  }
  return fallbackProducts();
}

async function seedProducts(pool) {
  const products = await loadProducts();
  for (const p of products) {
    await pool.query(INSERT, [
      p.title,
      p.description ?? '',
      p.category ?? 'other',
      p.price,
      p.discountPercentage ?? 0,
      p.rating ?? 0,
      p.stock ?? 0,
      JSON.stringify(p.tags ?? []),
      p.brand ?? null,
      p.sku ?? '',
      p.weight ?? 0,
      JSON.stringify(p.dimensions ?? { width: 0, height: 0, depth: 0 }),
      p.warrantyInformation ?? '',
      p.shippingInformation ?? '',
      p.availabilityStatus ?? 'In Stock',
      JSON.stringify(p.reviews ?? []),
      p.returnPolicy ?? '',
      p.minimumOrderQuantity ?? 1,
      JSON.stringify(
        p.meta ?? {
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
          barcode: '',
          qrCode: '',
        }
      ),
      JSON.stringify(p.images ?? []),
      p.thumbnail ?? '',
    ]);
  }
  console.log('Seeding done');
}

module.exports = { seedProducts };

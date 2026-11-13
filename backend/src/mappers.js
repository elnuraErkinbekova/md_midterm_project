const num = (v) => (v === null || v === undefined ? null : Number(v));

function mapProduct(r) {
  return {
    id: r.id,
    title: r.title,
    description: r.description,
    category: r.category,
    price: num(r.price),
    discountPercentage: num(r.discount_percentage),
    rating: num(r.rating),
    stock: r.stock,
    tags: r.tags || [],
    brand: r.brand,
    sku: r.sku,
    weight: num(r.weight),
    dimensions: r.dimensions,
    warrantyInformation: r.warranty_information,
    shippingInformation: r.shipping_information,
    availabilityStatus: r.availability_status,
    reviews: r.reviews || [],
    returnPolicy: r.return_policy,
    minimumOrderQuantity: r.minimum_order_quantity,
    meta: r.meta,
    images: r.images || [],
    thumbnail: r.thumbnail,
  };
}

module.exports = { mapProduct };

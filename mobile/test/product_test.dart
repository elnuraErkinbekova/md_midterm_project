import 'package:firstflutterproject/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Product.fromJson parses a full server response', () {
    final product = Product.fromJson({
      'id': 1,
      'title': 'Phone',
      'price': 100,
      'discountPercentage': 10.0,
      'stock': 3,
      'tags': ['a', 'b'],
      'dimensions': {'width': 1, 'height': 2.5, 'depth': 3},
      'reviews': [
        {
          'rating': 5,
          'comment': 'Great',
          'date': '2025-01-01T00:00:00.000Z',
          'reviewerName': 'Alex',
          'reviewerEmail': 'a@x.com',
        }
      ],
      'meta': {
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-02T00:00:00.000Z',
        'barcode': '123',
        'qrCode': 'qr',
      },
    });

    expect(product.id, 1);
    expect(product.price, 100.0);
    expect(product.tags, ['a', 'b']);
    expect(product.dimensions!.height, 2.5);
    expect(product.reviews!.single.reviewerName, 'Alex');
    expect(product.meta!.barcode, '123');
  });

  test('Product.fromJson does not crash when fields are missing', () {
    final product = Product.fromJson({'id': 7, 'title': 'Minimal'});

    expect(product.id, 7);
    expect(product.price, isNull);
    expect(product.reviews, isNull);
    expect(product.dimensions, isNull);
  });

  test('unitPrice applies the discount', () {
    const discounted = Product(price: 200, discountPercentage: 25);
    const regular = Product(price: 200);

    expect(discounted.unitPrice, 150);
    expect(regular.unitPrice, 200);
  });
}

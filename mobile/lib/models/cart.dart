import 'package:equatable/equatable.dart';

import 'product.dart';

class CartItem extends Equatable {
  final int id;
  final int quantity;
  final Product product;

  const CartItem({required this.id, required this.quantity, required this.product});

  double get lineTotal => product.unitPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [id, quantity, product];
}

class Cart extends Equatable {
  final List<CartItem> items;
  final int totalItems;
  final double total;

  const Cart({required this.items, required this.totalItems, required this.total});

  static const empty = Cart(items: [], totalItems: 0, total: 0);

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [items, totalItems, total];
}

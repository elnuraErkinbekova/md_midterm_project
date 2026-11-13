part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoaded extends CartEvent {
  const CartLoaded();
}

class CartItemAdded extends CartEvent {
  final int productId;
  final int quantity;
  const CartItemAdded(this.productId, {this.quantity = 1});

  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemQuantityChanged extends CartEvent {
  final int productId;
  final int quantity;
  const CartItemQuantityChanged(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemRemoved extends CartEvent {
  final int productId;
  const CartItemRemoved(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartReset extends CartEvent {
  const CartReset();
}

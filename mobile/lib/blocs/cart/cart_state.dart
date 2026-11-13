part of 'cart_bloc.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final Cart cart;

  final String? error;

  final String? notice;

  const CartState({
    this.status = CartStatus.initial,
    this.cart = Cart.empty,
    this.error,
    this.notice,
  });

  CartState copyWith({CartStatus? status, Cart? cart, String? error, String? notice}) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      error: error,
      notice: notice,
    );
  }

  @override
  List<Object?> get props => [status, cart, error, notice];
}

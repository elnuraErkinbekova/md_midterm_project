import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors.dart';
import '../../models/cart.dart';
import '../../repositories/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;

  CartBloc(this._repository) : super(const CartState()) {
    on<CartLoaded>(_onLoaded);
    on<CartItemAdded>(_onAdded);
    on<CartItemQuantityChanged>(_onQuantityChanged);
    on<CartItemRemoved>(_onRemoved);
    on<CartCleared>(_onCleared);
    on<CartReset>((event, emit) => emit(const CartState()));
  }

  Future<void> _onLoaded(CartLoaded event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final cart = await _repository.getCart();
      emit(state.copyWith(status: CartStatus.loaded, cart: cart));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, error: errorMessage(e)));
    }
  }

  Future<void> _onAdded(CartItemAdded event, Emitter<CartState> emit) {
    return _mutate(
      emit,
      () => _repository.addItem(event.productId, quantity: event.quantity),
      notice: 'Added to cart',
    );
  }

  Future<void> _onQuantityChanged(CartItemQuantityChanged event, Emitter<CartState> emit) {
    return _mutate(emit, () => _repository.setQuantity(event.productId, event.quantity));
  }

  Future<void> _onRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    return _mutate(emit, () => _repository.removeItem(event.productId));
  }

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) {
    return _mutate(emit, _repository.clear);
  }

  Future<void> _mutate(
    Emitter<CartState> emit,
    Future<Cart> Function() action, {
    String? notice,
  }) async {
    try {
      final cart = await action();
      emit(state.copyWith(status: CartStatus.loaded, cart: cart, notice: notice));
      if (notice != null) {
        emit(state.copyWith(status: CartStatus.loaded));
      }
    } catch (e) {
      emit(state.copyWith(status: CartStatus.loaded, error: errorMessage(e)));
      emit(state.copyWith(status: CartStatus.loaded));
    }
  }
}

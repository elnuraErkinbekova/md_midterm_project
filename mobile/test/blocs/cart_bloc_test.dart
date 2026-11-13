import 'package:bloc_test/bloc_test.dart';
import 'package:firstflutterproject/blocs/cart/cart_bloc.dart';
import 'package:firstflutterproject/models/cart.dart';
import 'package:firstflutterproject/models/product.dart';
import 'package:firstflutterproject/repositories/cart_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository repository;

  const product = Product(id: 1, title: 'Phone', price: 100);
  const cartWithOne = Cart(
    items: [CartItem(id: 1, quantity: 1, product: product)],
    totalItems: 1,
    total: 100,
  );

  setUp(() {
    repository = MockCartRepository();
  });

  blocTest<CartBloc, CartState>(
    'CartLoaded: emits loading, then loaded with the cart',
    setUp: () => when(() => repository.getCart()).thenAnswer((_) async => cartWithOne),
    build: () => CartBloc(repository),
    act: (bloc) => bloc.add(const CartLoaded()),
    expect: () => [
      isA<CartState>().having((s) => s.status, 'status', CartStatus.loading),
      isA<CartState>()
          .having((s) => s.status, 'status', CartStatus.loaded)
          .having((s) => s.cart, 'cart', cartWithOne),
    ],
  );

  blocTest<CartBloc, CartState>(
    'CartItemAdded: shows the new cart with a one-shot notice',
    setUp: () => when(() => repository.addItem(1, quantity: any(named: 'quantity')))
        .thenAnswer((_) async => cartWithOne),
    build: () => CartBloc(repository),
    act: (bloc) => bloc.add(const CartItemAdded(1)),
    expect: () => [
      isA<CartState>()
          .having((s) => s.cart, 'cart', cartWithOne)
          .having((s) => s.notice, 'notice', 'Added to cart'),
      isA<CartState>()
          .having((s) => s.cart, 'cart', cartWithOne)
          .having((s) => s.notice, 'notice', isNull),
    ],
  );

  blocTest<CartBloc, CartState>(
    'CartItemRemoved: calls the repository and shows the updated cart',
    setUp: () => when(() => repository.removeItem(1)).thenAnswer((_) async => Cart.empty),
    build: () => CartBloc(repository),
    act: (bloc) => bloc.add(const CartItemRemoved(1)),
    expect: () => [
      isA<CartState>().having((s) => s.cart.items, 'items', isEmpty),
    ],
    verify: (_) => verify(() => repository.removeItem(1)).called(1),
  );

  blocTest<CartBloc, CartState>(
    'CartItemAdded: reports an error and keeps the old cart when the server fails',
    setUp: () => when(() => repository.addItem(1, quantity: any(named: 'quantity')))
        .thenThrow(Exception('boom')),
    build: () => CartBloc(repository),
    act: (bloc) => bloc.add(const CartItemAdded(1)),
    expect: () => [
      isA<CartState>().having((s) => s.error, 'error', isNotNull),
      isA<CartState>().having((s) => s.error, 'error', isNull),
    ],
  );

  blocTest<CartBloc, CartState>(
    'CartReset: forgets the local cart',
    build: () => CartBloc(repository),
    seed: () => const CartState(status: CartStatus.loaded, cart: cartWithOne),
    act: (bloc) => bloc.add(const CartReset()),
    expect: () => [const CartState()],
  );
}

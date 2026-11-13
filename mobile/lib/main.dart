import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/products/products_bloc.dart';
import 'core/api_client.dart';
import 'data/auth_api.dart';
import 'data/cart_api.dart';
import 'data/product_api.dart';
import 'pages/home_page.dart';
import 'repositories/auth_repository.dart';
import 'repositories/cart_repository.dart';
import 'repositories/product_repository.dart';

void main() {
  final client = ApiClient();
  runApp(MyApp(
    productRepository: ProductRepository(ProductApiImpl(client)),
    cartRepository: CartRepository(CartApiImpl(client)),
    authRepository: AuthRepository(AuthApiImpl(client), client),
  ));
}

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final AuthRepository authRepository;

  const MyApp({
    super.key,
    required this.productRepository,
    required this.cartRepository,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: cartRepository),
        RepositoryProvider.value(value: authRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ProductsBloc(productRepository)..add(const ProductsStarted())),
          BlocProvider(create: (_) => CartBloc(cartRepository)),
          BlocProvider(create: (_) => AuthBloc(authRepository)..add(const AuthStarted())),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) => p.status != c.status,
              listener: (context, state) {
                if (state.isAuthenticated) {
                  context.read<CartBloc>().add(const CartLoaded());
                } else if (state.status == AuthStatus.unauthenticated) {
                  context.read<CartBloc>().add(const CartReset());
                }
              },
            ),
            BlocListener<CartBloc, CartState>(
              listenWhen: (p, c) =>
                  c.notice != null || (c.error != null && c.status != CartStatus.error),
              listener: (context, state) {
                final message = state.notice ?? state.error;
                if (message == null) return;
                _messengerKey.currentState
                  ?..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(message),
                    duration: const Duration(milliseconds: 1500),
                  ));
              },
            ),
          ],
          child: MaterialApp(
            title: 'Shop',
            scaffoldMessengerKey: _messengerKey,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: const HomePage(),
          ),
        ),
      ),
    );
  }
}

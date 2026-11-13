import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../models/product.dart';
import '../pages/login_page.dart';

void addToCartOrLogin(BuildContext context, Product product) {
  final id = product.id;
  if (id == null) return;

  if ((product.stock ?? 0) <= 0) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Out of stock')));
    return;
  }

  if (!context.read<AuthBloc>().state.isAuthenticated) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Please log in to use the cart')));
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
    return;
  }

  context.read<CartBloc>().add(CartItemAdded(id));
}

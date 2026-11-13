import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../models/cart.dart';
import 'login_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthBloc>().state.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.cart.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear cart',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => context.read<CartBloc>().add(const CartCleared()),
              );
            },
          ),
        ],
      ),
      body: !isLoggedIn
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 56, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Log in to see your cart'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: const Text('Log in'),
                  ),
                ],
              ),
            )
          : BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state.status == CartStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.error ?? 'Could not load the cart'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.read<CartBloc>().add(const CartLoaded()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state.status == CartStatus.loading && state.cart.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.cart.items.isEmpty) {
                  return const Center(child: Text('Your cart is empty'));
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _CartTile(item: state.cart.items[i]),
                      ),
                    ),
                    _Summary(cart: state.cart),
                  ],
                );
              },
            ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final bloc = context.read<CartBloc>();
    final productId = product.id!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Image.network(
                  product.thumbnail ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('\$${product.unitPrice.toStringAsFixed(2)} each',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('\$${item.lineTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => item.quantity <= 1
                          ? bloc.add(CartItemRemoved(productId))
                          : bloc.add(CartItemQuantityChanged(productId, item.quantity - 1)),
                    ),
                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => bloc.add(CartItemQuantityChanged(productId, item.quantity + 1)),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => bloc.add(CartItemRemoved(productId)),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final Cart cart;
  const _Summary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${cart.totalItems} items', style: TextStyle(color: Colors.grey.shade600)),
                  Text('\$${cart.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            FilledButton(
              onPressed: () async {
                final bloc = context.read<CartBloc>();
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Order placed'),
                    content: const Text('This is a demo checkout: no payment is made.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
                    ],
                  ),
                );
                bloc.add(const CartCleared());
              },
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

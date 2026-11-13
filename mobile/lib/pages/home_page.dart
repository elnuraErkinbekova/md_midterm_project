import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/products/products_bloc.dart';
import '../widgets/add_to_cart.dart';
import '../widgets/product_view.dart';
import 'cart_page.dart';
import 'login_page.dart';
import 'product_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Shop'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            buildWhen: (p, c) => p.cart.totalItems != c.cart.totalItems,
            builder: (context, state) {
              final count = state.cart.totalItems;
              return IconButton(
                tooltip: 'Cart',
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ),
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (!state.isAuthenticated) {
                return IconButton(
                  tooltip: 'Log in',
                  icon: const Icon(Icons.login),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                );
              }
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle_outlined),
                onSelected: (_) => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                itemBuilder: (_) => [
                  PopupMenuItem(enabled: false, child: Text(state.user?.name ?? '')),
                  const PopupMenuItem(value: 'logout', child: Text('Log out')),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ProductsBloc>().add(const ProductsSearchChanged(''));
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                isDense: true,
              ),
              onChanged: (value) => context.read<ProductsBloc>().add(ProductsSearchChanged(value)),
            ),
          ),
          const _CategoryChips(),
          const Expanded(child: _ProductsBody()),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  String _label(String c) {
    final text = c.replaceAll('-', ' ');
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      buildWhen: (p, c) => p.categories != c.categories || p.selectedCategory != c.selectedCategory,
      builder: (context, state) {
        if (state.categories.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: state.selectedCategory == null,
                  onSelected: (_) =>
                      context.read<ProductsBloc>().add(const ProductsCategorySelected(null)),
                ),
              ),
              for (final category in state.categories)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_label(category)),
                    selected: state.selectedCategory == category,
                    onSelected: (_) =>
                        context.read<ProductsBloc>().add(ProductsCategorySelected(category)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductsBody extends StatelessWidget {
  const _ProductsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state.products.isEmpty) {
          if (state.status == ProductsStatus.error) {
            return _Message(
              icon: Icons.cloud_off,
              text: state.error ?? 'Something went wrong',
              action: FilledButton(
                onPressed: () => context.read<ProductsBloc>().add(const ProductsRefreshed()),
                child: const Text('Retry'),
              ),
            );
          }
          if (state.status == ProductsStatus.loaded) {
            return const _Message(icon: Icons.search_off, text: 'No products found');
          }
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            if (state.status == ProductsStatus.loading) const LinearProgressIndicator(minHeight: 3),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final bloc = context.read<ProductsBloc>();
                  bloc.add(const ProductsRefreshed());
                  await bloc.stream.firstWhere(
                    (s) => s.status == ProductsStatus.loaded || s.status == ProductsStatus.error,
                  );
                },
                child: _ProductGrid(state: state),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final ProductsState state;
  const _ProductGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        const spacing = 14.0;
        final columns = (constraints.maxWidth / 190).floor().clamp(2, 6).toInt();
        final cellWidth = (constraints.maxWidth - padding * 2 - spacing * (columns - 1)) / columns;

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cellWidth + 185,
          ),
          itemCount: state.products.length,
          itemBuilder: (context, index) {
            final product = state.products[index];
            return ProductCard(
              product: product,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductPage(product: product)),
              ),
              onAddToCart: () => addToCartOrLogin(context, product),
            );
          },
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;
  const _Message({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

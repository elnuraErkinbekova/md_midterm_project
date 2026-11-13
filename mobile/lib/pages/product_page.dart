import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/product_detail/product_detail_bloc.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../widgets/add_to_cart.dart';

class ProductPage extends StatelessWidget {
  final Product product;
  const ProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ProductDetailBloc(context.read<ProductRepository>(), product);
        final id = product.id;
        if (id != null) bloc.add(ProductDetailRequested(id));
        return bloc;
      },
      child: const _ProductView(),
    );
  }
}

class _ProductView extends StatelessWidget {
  const _ProductView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        final product = state.product;
        final hasDiscount = (product.discountPercentage ?? 0) > 0;
        final images = (product.images != null && product.images!.isNotEmpty)
            ? product.images!
            : [if (product.thumbnail != null) product.thumbnail!];

        return Scaffold(
          appBar: AppBar(title: Text(product.title ?? 'Product', overflow: TextOverflow.ellipsis)),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasDiscount)
                          Text(
                            '\$${(product.price ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '\$${product.unitPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => addToCartOrLogin(context, product),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to cart'),
                  ),
                ],
              ),
            ),
          ),
          body: ListView(
            children: [
              if (state.status == ProductDetailStatus.loading) const LinearProgressIndicator(minHeight: 3),
              if (state.status == ProductDetailStatus.error)
                MaterialBanner(
                  content: Text(state.error ?? 'Could not refresh product'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final id = product.id;
                        if (id != null) {
                          context.read<ProductDetailBloc>().add(ProductDetailRequested(id));
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              _Gallery(images: images),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((product.brand ?? '').isNotEmpty)
                      Text(
                        product.brand!.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(product.title ?? 'Untitled',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB800)),
                        const SizedBox(width: 4),
                        Text((product.rating ?? 0).toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        Text(
                          product.availabilityStatus ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: (product.stock ?? 0) > 0 ? Colors.green.shade700 : Colors.red,
                          ),
                        ),
                        if ((product.stock ?? 0) > 0) Text('  (${product.stock} in stock)'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(product.description ?? '', style: const TextStyle(height: 1.4)),
                    if (product.tags != null && product.tags!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [for (final t in product.tags!) Chip(label: Text(t))],
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text('Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _InfoRow('SKU', product.sku),
                    _InfoRow('Category', product.category),
                    _InfoRow('Warranty', product.warrantyInformation),
                    _InfoRow('Shipping', product.shippingInformation),
                    _InfoRow('Returns', product.returnPolicy),
                    _InfoRow(
                      'Minimum order',
                      product.minimumOrderQuantity?.toString(),
                    ),
                    _InfoRow('Weight', product.weight != null ? '${product.weight} kg' : null),
                    if (product.dimensions != null)
                      _InfoRow(
                        'Size (W×H×D)',
                        '${product.dimensions!.width} × ${product.dimensions!.height} × ${product.dimensions!.depth}',
                      ),
                    const SizedBox(height: 16),
                    Text('Reviews (${product.reviews?.length ?? 0})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    for (final r in product.reviews ?? const <Review>[])
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(child: Text(r.reviewerName)),
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < r.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                  size: 16,
                                  color: const Color(0xFFFFB800),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(r.comment),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Gallery extends StatefulWidget {
  final List<String> images;
  const _Gallery({required this.images});

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 280,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, size: 56, color: Colors.grey),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Image.network(
              widget.images[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, size: 56, color: Colors.grey),
              ),
            ),
          ),
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.images.length; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value!)),
        ],
      ),
    );
  }
}

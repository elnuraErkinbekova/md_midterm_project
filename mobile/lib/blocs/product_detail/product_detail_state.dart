part of 'product_detail_bloc.dart';

enum ProductDetailStatus { initial, loading, loaded, error }

class ProductDetailState extends Equatable {
  final ProductDetailStatus status;
  final Product product;
  final String? error;

  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    required this.product,
    this.error,
  });

  ProductDetailState copyWith({ProductDetailStatus? status, Product? product, String? error}) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, product, error];
}

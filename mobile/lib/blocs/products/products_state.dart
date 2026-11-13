part of 'products_bloc.dart';

enum ProductsStatus { initial, loading, loaded, error }

class ProductsState extends Equatable {
  final ProductsStatus status;
  final List<Product> products;
  final List<String> categories;
  final String query;
  final String? selectedCategory;
  final String? error;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.query = '',
    this.selectedCategory,
    this.error,
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    List<String>? categories,
    String? query,
    String? selectedCategory,
    bool clearCategory = false,
    String? error,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, products, categories, query, selectedCategory, error];
}

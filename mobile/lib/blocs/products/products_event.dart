part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class ProductsStarted extends ProductsEvent {
  const ProductsStarted();
}

class ProductsSearchChanged extends ProductsEvent {
  final String query;
  const ProductsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ProductsCategorySelected extends ProductsEvent {
  final String? category;
  const ProductsCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class ProductsRefreshed extends ProductsEvent {
  const ProductsRefreshed();
}

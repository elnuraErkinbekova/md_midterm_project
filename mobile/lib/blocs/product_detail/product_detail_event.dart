part of 'product_detail_bloc.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class ProductDetailRequested extends ProductDetailEvent {
  final int id;
  const ProductDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

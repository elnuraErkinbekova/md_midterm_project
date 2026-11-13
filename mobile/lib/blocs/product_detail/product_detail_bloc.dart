import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductRepository _repository;

  ProductDetailBloc(this._repository, Product initial)
      : super(ProductDetailState(product: initial)) {
    on<ProductDetailRequested>(_onRequested);
  }

  Future<void> _onRequested(ProductDetailRequested event, Emitter<ProductDetailState> emit) async {
    emit(state.copyWith(status: ProductDetailStatus.loading));
    try {
      final product = await _repository.getProduct(event.id);
      emit(state.copyWith(status: ProductDetailStatus.loaded, product: product));
    } catch (e) {
      emit(state.copyWith(status: ProductDetailStatus.error, error: errorMessage(e)));
    }
  }
}

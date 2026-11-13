import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductRepository _repository;

  ProductsBloc(this._repository) : super(const ProductsState()) {
    on<ProductsStarted>(_onStarted);
    on<ProductsSearchChanged>(_onSearchChanged, transformer: restartable());
    on<ProductsCategorySelected>(_onCategorySelected, transformer: restartable());
    on<ProductsRefreshed>(_onRefreshed, transformer: restartable());
  }

  Future<void> _onStarted(ProductsStarted event, Emitter<ProductsState> emit) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final categories = await _repository.getCategories();
      final products = await _repository.getProducts(
        query: state.query,
        category: state.selectedCategory,
      );
      emit(state.copyWith(status: ProductsStatus.loaded, categories: categories, products: products));
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.error, error: errorMessage(e)));
    }
  }

  Future<void> _onSearchChanged(ProductsSearchChanged event, Emitter<ProductsState> emit) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (emit.isDone) return;
    await _load(emit, query: event.query.trim(), category: state.selectedCategory);
  }

  Future<void> _onCategorySelected(ProductsCategorySelected event, Emitter<ProductsState> emit) {
    return _load(emit, query: state.query, category: event.category);
  }

  Future<void> _onRefreshed(ProductsRefreshed event, Emitter<ProductsState> emit) async {
    try {
      final categories = await _repository.getCategories();
      if (emit.isDone) return;
      emit(state.copyWith(categories: categories));
    } catch (_) {
    }
    if (emit.isDone) return;
    await _load(emit, query: state.query, category: state.selectedCategory);
  }

  Future<void> _load(
    Emitter<ProductsState> emit, {
    required String query,
    String? category,
  }) async {
    emit(state.copyWith(
      status: ProductsStatus.loading,
      query: query,
      selectedCategory: category,
      clearCategory: category == null,
    ));
    try {
      final products = await _repository.getProducts(query: query, category: category);
      emit(state.copyWith(status: ProductsStatus.loaded, products: products));
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.error, error: errorMessage(e)));
    }
  }
}

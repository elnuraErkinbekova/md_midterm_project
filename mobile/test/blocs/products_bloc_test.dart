import 'package:bloc_test/bloc_test.dart';
import 'package:firstflutterproject/blocs/products/products_bloc.dart';
import 'package:firstflutterproject/models/product.dart';
import 'package:firstflutterproject/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;
  const phone = Product(id: 1, title: 'Phone', price: 100);

  setUp(() {
    repository = MockProductRepository();
  });

  void stubProducts(List<Product> products) {
    when(() => repository.getProducts(
          query: any(named: 'query'),
          category: any(named: 'category'),
        )).thenAnswer((_) async => products);
  }

  blocTest<ProductsBloc, ProductsState>(
    'ProductsStarted: emits loading, then loaded with products and categories',
    setUp: () {
      when(() => repository.getCategories()).thenAnswer((_) async => ['beauty']);
      stubProducts([phone]);
    },
    build: () => ProductsBloc(repository),
    act: (bloc) => bloc.add(const ProductsStarted()),
    expect: () => [
      isA<ProductsState>().having((s) => s.status, 'status', ProductsStatus.loading),
      isA<ProductsState>()
          .having((s) => s.status, 'status', ProductsStatus.loaded)
          .having((s) => s.products, 'products', [phone])
          .having((s) => s.categories, 'categories', ['beauty']),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'ProductsStarted: emits error when the repository throws',
    setUp: () {
      when(() => repository.getCategories()).thenThrow(Exception('boom'));
    },
    build: () => ProductsBloc(repository),
    act: (bloc) => bloc.add(const ProductsStarted()),
    expect: () => [
      isA<ProductsState>().having((s) => s.status, 'status', ProductsStatus.loading),
      isA<ProductsState>()
          .having((s) => s.status, 'status', ProductsStatus.error)
          .having((s) => s.error, 'error', isNotNull),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'ProductsSearchChanged: searches with the trimmed query after the debounce',
    setUp: () => stubProducts([phone]),
    build: () => ProductsBloc(repository),
    act: (bloc) => bloc.add(const ProductsSearchChanged(' phone ')),
    wait: const Duration(milliseconds: 450),
    expect: () => [
      isA<ProductsState>()
          .having((s) => s.status, 'status', ProductsStatus.loading)
          .having((s) => s.query, 'query', 'phone'),
      isA<ProductsState>()
          .having((s) => s.status, 'status', ProductsStatus.loaded)
          .having((s) => s.products, 'products', [phone]),
    ],
    verify: (_) {
      verify(() => repository.getProducts(query: 'phone', category: null)).called(1);
    },
  );

  blocTest<ProductsBloc, ProductsState>(
    'ProductsCategorySelected: filters by category',
    setUp: () => stubProducts([phone]),
    build: () => ProductsBloc(repository),
    act: (bloc) => bloc.add(const ProductsCategorySelected('beauty')),
    expect: () => [
      isA<ProductsState>().having((s) => s.selectedCategory, 'category', 'beauty'),
      isA<ProductsState>()
          .having((s) => s.status, 'status', ProductsStatus.loaded)
          .having((s) => s.selectedCategory, 'category', 'beauty'),
    ],
    verify: (_) {
      verify(() => repository.getProducts(query: '', category: 'beauty')).called(1);
    },
  );
}

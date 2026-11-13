import '../data/product_api.dart';
import '../models/product.dart';

class ProductRepository {
  final ProductApi _api;
  ProductRepository(this._api);

  Future<List<Product>> getProducts({String query = '', String? category}) =>
      _api.getProducts(query: query, category: category);

  Future<Product> getProduct(int id) => _api.getProductById(id);

  Future<List<String>> getCategories() => _api.getCategories();
}

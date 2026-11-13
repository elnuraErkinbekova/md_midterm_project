import '../core/api_client.dart';
import '../models/product.dart';

abstract class ProductApi {
  Future<List<Product>> getProducts({String query = '', String? category, int limit = 100});
  Future<Product> getProductById(Object? id);
  Future<List<String>> getCategories();
}

class ProductApiImpl implements ProductApi {
  final ApiClient _client;
  ProductApiImpl(this._client);

  @override
  Future<List<Product>> getProducts({String query = '', String? category, int limit = 100}) async {
    final response = await _client.dio.get(
      '/products',
      queryParameters: {
        if (query.isNotEmpty) 'q': query,
        if (category != null) 'category': category,
        'limit': limit,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return (data['products'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product> getProductById(Object? id) async {
    final response = await _client.dio.get('/products/$id');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await _client.dio.get('/categories');
    return (response.data as List).map((e) => e.toString()).toList();
  }
}

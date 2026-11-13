import '../core/api_client.dart';
import '../models/cart.dart';

abstract class CartApi {
  Future<Cart> getCart();
  Future<Cart> addItem(int productId, int quantity);
  Future<Cart> setQuantity(int productId, int quantity);
  Future<Cart> removeItem(int productId);
  Future<Cart> clear();
}

class CartApiImpl implements CartApi {
  final ApiClient _client;
  CartApiImpl(this._client);

  Cart _parse(dynamic data) => Cart.fromJson(data as Map<String, dynamic>);

  @override
  Future<Cart> getCart() async => _parse((await _client.dio.get('/cart')).data);

  @override
  Future<Cart> addItem(int productId, int quantity) async => _parse(
        (await _client.dio.post('/cart/items', data: {'productId': productId, 'quantity': quantity})).data,
      );

  @override
  Future<Cart> setQuantity(int productId, int quantity) async => _parse(
        (await _client.dio.patch('/cart/items/$productId', data: {'quantity': quantity})).data,
      );

  @override
  Future<Cart> removeItem(int productId) async =>
      _parse((await _client.dio.delete('/cart/items/$productId')).data);

  @override
  Future<Cart> clear() async => _parse((await _client.dio.delete('/cart')).data);
}

import '../data/cart_api.dart';
import '../models/cart.dart';

class CartRepository {
  final CartApi _api;
  CartRepository(this._api);

  Future<Cart> getCart() => _api.getCart();
  Future<Cart> addItem(int productId, {int quantity = 1}) => _api.addItem(productId, quantity);
  Future<Cart> setQuantity(int productId, int quantity) => _api.setQuantity(productId, quantity);
  Future<Cart> removeItem(int productId) => _api.removeItem(productId);
  Future<Cart> clear() => _api.clear();
}

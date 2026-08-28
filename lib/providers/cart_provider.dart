import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../models/vendor_branch_model.dart';

class CartProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  CartModel _cart = CartModel.empty();
  bool _isLoading = false;
  String? _error;

  CartProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  CartModel get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cart.totalItemsCount;
  bool get isEmpty => _cart.isEmpty;

  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _apiClient.get(ApiEndpoints.cart);
      if (res is Map<String, dynamic>) {
        _cart = CartModel.fromJson(res);
      }
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart({
    required VendorBranchModel branch,
    required ProductModel product,
    required ProductVariantModel variant,
    int quantity = 1,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _apiClient.post(
        ApiEndpoints.cartItems,
        body: {
          'branchId': branch.id,
          'variantId': variant.id,
          'quantity': quantity,
        },
      );

      if (res is Map<String, dynamic>) {
        _cart = CartModel.fromJson(res);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      await fetchCart();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add item to cart: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      return removeItem(itemId);
    }

    try {
      final res = await _apiClient.patch(
        ApiEndpoints.cartItem(itemId),
        body: {'quantity': quantity},
      );

      if (res is Map<String, dynamic>) {
        _cart = CartModel.fromJson(res);
        notifyListeners();
        return true;
      }
      await fetchCart();
      return true;
    } catch (e) {
      _error = 'Failed to update quantity: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(String itemId) async {
    try {
      final res = await _apiClient.delete(ApiEndpoints.cartItem(itemId));
      if (res is Map<String, dynamic>) {
        _cart = CartModel.fromJson(res);
        notifyListeners();
        return true;
      }
      await fetchCart();
      return true;
    } catch (e) {
      _error = 'Failed to remove item: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> clearCart() async {
    try {
      await _apiClient.delete(ApiEndpoints.cart);
      _cart = CartModel.empty();
      notifyListeners();
    } catch (_) {
      _cart = CartModel.empty();
      notifyListeners();
    }
  }
}

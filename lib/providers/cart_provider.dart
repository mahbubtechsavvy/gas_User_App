import 'package:flutter/material.dart';
import 'package:userapp/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.effectivePrice * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  int? _vendorId;
  String? _vendorName;

  List<CartItem> get items => _items.values.toList();
  int? get vendorId => _vendorId;
  String? get vendorName => _vendorName;
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + item.total);

  bool canAddFromVendor(int vendorId) =>
      _items.isEmpty || _vendorId == vendorId;

  void addItem(Product product) {
    if (!canAddFromVendor(product.vendorId)) {
      throw Exception('Cart has items from another vendor. Clear cart first.');
    }

    _vendorId = product.vendorId;
    _vendorName = product.vendorName;
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    if (_items.isEmpty) {
      _vendorId = null;
      _vendorName = null;
    }
    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
      notifyListeners();
    } else {
      removeItem(productId);
    }
  }

  void increaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;
    _items[productId]!.quantity++;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _vendorId = null;
    _vendorName = null;
    notifyListeners();
  }
}

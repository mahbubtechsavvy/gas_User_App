import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _vendorProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _allProducts;
  List<Product> get vendorProducts => _vendorProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts(String token) async {
    _isLoading = true;
    _error = null;
    _vendorProducts = [];
    notifyListeners();

    try {
      _allProducts = await ProductService.getAllProducts(token);
    } catch (e) {
      _error = _errorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVendorProducts(String token, int vendorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vendorProducts = await ProductService.getVendorProducts(token, vendorId);
    } catch (e) {
      _error = _errorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String _errorMessage(Object error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'Connection timed out. Please try again.';
    }
    final message = error.toString().replaceAll('Exception: ', '');
    return message.isEmpty ? 'Could not load products' : message;
  }
}

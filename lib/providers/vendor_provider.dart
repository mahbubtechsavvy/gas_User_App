import 'package:flutter/material.dart';

import '../models/vendor.dart';
import '../services/vendor_service.dart';

class VendorProvider extends ChangeNotifier {
  List<Vendor> _vendors = [];
  List<dynamic> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<Vendor> get vendors => _vendors;
  List<dynamic> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVendors(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vendors = await VendorService.getVendors(token);

      try {
        _banners = await VendorService.getBanners(token);
      } catch (e) {
        debugPrint('Could not load banners: $e');
        _banners = [];
      }
    } catch (e) {
      _vendors = [];
      _banners = [];
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
    return message.isEmpty ? 'Could not load vendors' : message;
  }
}

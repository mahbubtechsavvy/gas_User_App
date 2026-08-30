import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/address_model.dart';
import '../models/vendor_branch_model.dart';

class AddressProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  List<VendorBranchModel> _servingBranches = [];
  bool _isLoading = false;
  String? _error;

  AddressProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  List<AddressModel> get addresses => _addresses;
  AddressModel? get selectedAddress => _selectedAddress ?? defaultAddress;
  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }
  List<VendorBranchModel> get servingBranches => _servingBranches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
    fetchServingBranches(address.id);
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _apiClient.get(ApiEndpoints.addresses);
      if (res is List) {
        _addresses = res.map((a) => AddressModel.fromJson(a as Map<String, dynamic>)).toList();
      } else if (res is Map<String, dynamic> && res['items'] is List) {
        _addresses = (res['items'] as List).map((a) => AddressModel.fromJson(a as Map<String, dynamic>)).toList();
      }
      
      if (_selectedAddress == null && _addresses.isNotEmpty) {
        _selectedAddress = defaultAddress;
        if (_selectedAddress != null) {
          fetchServingBranches(_selectedAddress!.id);
        }
      }
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load addresses: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress({
    required String label,
    required String recipientName,
    required String phone,
    required String division,
    required String district,
    required String thana,
    required String fullAddress,
    String? landmark,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    String formattedPhone = phone.trim();
    if (formattedPhone.startsWith('01')) {
      formattedPhone = '+88$formattedPhone';
    } else if (formattedPhone.startsWith('8801')) {
      formattedPhone = '+$formattedPhone';
    } else if (!formattedPhone.startsWith('+8801') && formattedPhone.isNotEmpty) {
      formattedPhone = '+880$formattedPhone';
    }

    try {
      final res = await _apiClient.post(
        ApiEndpoints.addresses,
        body: {
          'label': label.isNotEmpty ? label : 'Home',
          'recipientName': recipientName.trim().isNotEmpty ? recipientName.trim() : 'Customer',
          'phone': formattedPhone,
          'line1': fullAddress.trim().isNotEmpty ? fullAddress.trim() : '$thana, $district',
          'area': thana.trim().isNotEmpty ? thana.trim() : (district.trim().isNotEmpty ? district.trim() : 'Dhaka'),
          if (thana.trim().isNotEmpty) 'thana': thana.trim(),
          'district': district.trim().isNotEmpty ? district.trim() : 'Dhaka',
          if (landmark != null && landmark.trim().isNotEmpty) 'line2': landmark.trim(),
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );

      if (res is Map<String, dynamic>) {
        final newAddress = AddressModel.fromJson(res);
        if (isDefault || _addresses.isEmpty) {
          _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
          _selectedAddress = newAddress;
        }
        _addresses.insert(0, newAddress);
        _isLoading = false;
        notifyListeners();
        fetchServingBranches(newAddress.id);
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add address: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setDefaultAddress(String addressId) async {
    try {
      await _apiClient.post(ApiEndpoints.setDefaultAddress(addressId));
      _addresses = _addresses.map((a) {
        return a.copyWith(isDefault: a.id == addressId);
      }).toList();
      _selectedAddress = defaultAddress;
      notifyListeners();
      if (_selectedAddress != null) {
        fetchServingBranches(_selectedAddress!.id);
      }
      return true;
    } catch (e) {
      _error = 'Failed to set default address: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      await _apiClient.delete(ApiEndpoints.address(addressId));
      _addresses.removeWhere((a) => a.id == addressId);
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = defaultAddress;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete address: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchServingBranches(String addressId) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.addressServingBranches(addressId));
      if (res is List) {
        _servingBranches = res.map((b) => VendorBranchModel.fromJson(b as Map<String, dynamic>)).toList();
        notifyListeners();
      } else if (res is Map<String, dynamic> && res['branches'] is List) {
        _servingBranches = (res['branches'] as List).map((b) => VendorBranchModel.fromJson(b as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (_) {
      // Soft-fail: fallback to public branches
    }
  }
}

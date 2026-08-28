import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/vendor_branch_model.dart';

class CatalogueProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<CategoryModel> _categories = [];
  List<VendorBranchModel> _branches = [];
  List<ProductModel> _products = [];
  CategoryModel? _selectedCategory;
  VendorBranchModel? _selectedBranch;
  bool _isLoading = false;
  String? _error;

  CatalogueProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  List<CategoryModel> get categories => _categories;
  List<VendorBranchModel> get branches => _branches;
  List<ProductModel> get products => _products;
  CategoryModel? get selectedCategory => _selectedCategory;
  VendorBranchModel? get selectedBranch => _selectedBranch;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
    fetchProducts(
      categoryId: category?.id,
      branchId: _selectedBranch?.id,
    );
  }

  void selectBranch(VendorBranchModel branch) {
    _selectedBranch = branch;
    notifyListeners();
    fetchProducts(branchId: branch.id);
  }

  Future<void> fetchCategories() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.categories, requiresAuth: false);
      if (res is List) {
        _categories = res.map((c) => CategoryModel.fromJson(c as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (_) {
      // Soft-fail
    }
  }

  Future<void> fetchBranches({double? lat, double? lng}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (lat != null && lng != null) {
        params['lat'] = lat;
        params['lng'] = lng;
      }

      final res = await _apiClient.get(
        ApiEndpoints.branches,
        queryParams: params,
        requiresAuth: false,
      );

      if (res is List) {
        _branches = res.map((b) => VendorBranchModel.fromJson(b as Map<String, dynamic>)).toList();
      } else if (res is Map<String, dynamic> && res['items'] is List) {
        _branches = (res['items'] as List).map((b) => VendorBranchModel.fromJson(b as Map<String, dynamic>)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load branches: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts({
    String? branchId,
    String? categoryId,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (branchId != null) params['branchId'] = branchId;
      if (categoryId != null) params['categoryId'] = categoryId;
      if (search != null && search.isNotEmpty) params['q'] = search;

      final res = await _apiClient.get(
        ApiEndpoints.products,
        queryParams: params,
        requiresAuth: false,
      );

      if (res is List) {
        _products = res.map((p) => ProductModel.fromJson(p as Map<String, dynamic>)).toList();
      } else if (res is Map<String, dynamic> && res['items'] is List) {
        _products = (res['items'] as List).map((p) => ProductModel.fromJson(p as Map<String, dynamic>)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load products: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> fetchProductDetails(String productId) async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.product(productId),
        requiresAuth: false,
      );
      if (res is Map<String, dynamic>) {
        return ProductModel.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

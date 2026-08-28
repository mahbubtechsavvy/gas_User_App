import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/delivery_slot_model.dart';
import '../models/order_model.dart';

class BranchDeliveryChoice {
  final String branchId;
  String deliveryMode; // 'ASAP' or 'SCHEDULED'
  DeliverySlotModel? selectedSlot;

  BranchDeliveryChoice({
    required this.branchId,
    this.deliveryMode = 'ASAP',
    this.selectedSlot,
  });
}

class CheckoutProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  String _paymentMethod = 'COD'; // 'COD' or 'ONLINE'
  String? _notes;
  final Map<String, BranchDeliveryChoice> _branchChoices = {};
  final Map<String, List<DeliverySlotModel>> _branchSlots = {};
  bool _isLoading = false;
  String? _error;
  List<OrderModel> _createdOrders = [];

  CheckoutProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  String get paymentMethod => _paymentMethod;
  String? get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<OrderModel> get createdOrders => _createdOrders;

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setNotes(String? notes) {
    _notes = notes;
    notifyListeners();
  }

  BranchDeliveryChoice getChoiceForBranch(String branchId) {
    return _branchChoices.putIfAbsent(
      branchId,
      () => BranchDeliveryChoice(branchId: branchId),
    );
  }

  void setDeliveryMode(String branchId, String mode) {
    final choice = getChoiceForBranch(branchId);
    choice.deliveryMode = mode;
    notifyListeners();
  }

  void setDeliverySlot(String branchId, DeliverySlotModel slot) {
    final choice = getChoiceForBranch(branchId);
    choice.selectedSlot = slot;
    choice.deliveryMode = 'SCHEDULED';
    notifyListeners();
  }

  List<DeliverySlotModel> getSlotsForBranch(String branchId) {
    return _branchSlots[branchId] ?? [];
  }

  Future<void> fetchSlotsForBranch(String branchId, {String? date}) async {
    try {
      final queryDate = date ?? DateTime.now().toIso8601String().substring(0, 10);
      final res = await _apiClient.get(
        ApiEndpoints.branchDeliverySlots(branchId),
        queryParams: {'date': queryDate},
        requiresAuth: false,
      );

      if (res is List) {
        _branchSlots[branchId] = res.map((s) => DeliverySlotModel.fromJson(s as Map<String, dynamic>)).toList();
        notifyListeners();
      } else if (res is Map<String, dynamic> && res['slots'] is List) {
        _branchSlots[branchId] = (res['slots'] as List).map((s) => DeliverySlotModel.fromJson(s as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (_) {
      // Soft-fail: fallback to ASAP
    }
  }

  Future<List<OrderModel>?> executeCheckout({
    required String addressId,
    required List<String> branchIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final branchDeliveries = branchIds.map((branchId) {
        final choice = getChoiceForBranch(branchId);
        return {
          'branchId': branchId,
          'deliveryMode': choice.deliveryMode,
          if (choice.deliveryMode == 'SCHEDULED' && choice.selectedSlot != null)
            'deliverySlotId': choice.selectedSlot!.id,
        };
      }).toList();

      final idempotencyKey = 'chk_${DateTime.now().millisecondsSinceEpoch}';

      final res = await _apiClient.post(
        ApiEndpoints.checkout,
        body: {
          'addressId': addressId,
          'paymentMethod': _paymentMethod,
          'branchDeliveries': branchDeliveries,
          if (_notes != null && _notes!.isNotEmpty) 'notes': _notes,
        },
        idempotencyKey: idempotencyKey,
      );

      if (res is Map<String, dynamic>) {
        final rawOrders = res['orders'] as List<dynamic>? ?? [];
        _createdOrders = rawOrders.map((o) => OrderModel.fromJson(o as Map<String, dynamic>)).toList();

        if (_paymentMethod == 'ONLINE' && res['checkoutId'] != null) {
          try {
            await _apiClient.post(
              ApiEndpoints.initPayment,
              body: {
                'checkoutId': res['checkoutId'],
                'provider': 'BKASH',
              },
            );
          } catch (_) {
            // Online gateway mock fallback
          }
        }

        _isLoading = false;
        notifyListeners();
        return _createdOrders;
      }

      _error = 'Invalid checkout response';
      _isLoading = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Checkout failed: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}

import '../core/money/money.dart';
import 'product_model.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
  rejected;

  static OrderStatus fromString(String? status) {
    if (status == null) return OrderStatus.pending;
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        return OrderStatus.accepted;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY':
        return OrderStatus.ready;
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.outForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      case 'REJECTED':
        return OrderStatus.rejected;
      case 'PENDING':
      default:
        return OrderStatus.pending;
    }
  }

  String toApiString() {
    switch (this) {
      case OrderStatus.accepted:
        return 'ACCEPTED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.ready:
        return 'READY';
      case OrderStatus.outForDelivery:
        return 'OUT_FOR_DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
      case OrderStatus.rejected:
        return 'REJECTED';
      case OrderStatus.pending:
        return 'PENDING';
    }
  }

  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.rejected;

  bool get isActive => !isTerminal;
}

class OrderItemModel {
  final String id;
  final String productName;
  final String variantName;
  final double? cylinderSizeKg;
  final SupplyType supplyType;
  final int unitPricePaisa;
  final int depositPaisa;
  final int quantity;
  final int lineTotalPaisa;

  OrderItemModel({
    required this.id,
    required this.productName,
    required this.variantName,
    this.cylinderSizeKg,
    this.supplyType = SupplyType.refill,
    required this.unitPricePaisa,
    this.depositPaisa = 0,
    required this.quantity,
    required this.lineTotalPaisa,
  });

  Money get unitPrice => Money.fromPaisa(unitPricePaisa);
  Money get deposit => Money.fromPaisa(depositPaisa);
  Money get lineTotal => Money.fromPaisa(lineTotalPaisa);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? json['product_name']?.toString() ?? 'LPG Cylinder',
      variantName: json['variantName']?.toString() ?? json['variant_name']?.toString() ?? '',
      cylinderSizeKg: json['cylinderSizeKg'] != null
          ? (json['cylinderSizeKg'] as num).toDouble()
          : (json['cylinder_size_kg'] != null ? (json['cylinder_size_kg'] as num).toDouble() : null),
      supplyType: SupplyType.fromString(
        json['supplyType']?.toString() ?? json['supply_type']?.toString(),
      ),
      unitPricePaisa: json['unitPricePaisa'] ?? json['unit_price_paisa'] ?? 140000,
      depositPaisa: json['depositPaisa'] ?? json['deposit_paisa'] ?? 0,
      quantity: json['quantity'] ?? 1,
      lineTotalPaisa: json['lineTotalPaisa'] ?? json['line_total_paisa'] ?? (json['unitPricePaisa'] ?? 140000) * (json['quantity'] ?? 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'variantName': variantName,
      'cylinderSizeKg': cylinderSizeKg,
      'supplyType': supplyType.toApiString(),
      'unitPricePaisa': unitPricePaisa,
      'depositPaisa': depositPaisa,
      'quantity': quantity,
      'lineTotalPaisa': lineTotalPaisa,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String? checkoutId;
  final String vendorName;
  final String branchName;
  final String? branchPhone;
  final OrderStatus status;
  final String paymentStatus;
  final String paymentMethod;
  final String deliveryMode;
  final String? deliverySlotFormatted;
  final String deliveryAddressText;
  final int subtotalPaisa;
  final int depositTotalPaisa;
  final int deliveryFeePaisa;
  final int totalPaisa;
  final DateTime createdAt;
  final String? riderName;
  final String? riderPhone;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.checkoutId,
    required this.vendorName,
    required this.branchName,
    this.branchPhone,
    required this.status,
    this.paymentStatus = 'PENDING',
    this.paymentMethod = 'COD',
    this.deliveryMode = 'ASAP',
    this.deliverySlotFormatted,
    required this.deliveryAddressText,
    required this.subtotalPaisa,
    this.depositTotalPaisa = 0,
    required this.deliveryFeePaisa,
    required this.totalPaisa,
    required this.createdAt,
    this.riderName,
    this.riderPhone,
    this.items = const [],
  });

  Money get subtotal => Money.fromPaisa(subtotalPaisa);
  Money get depositTotal => Money.fromPaisa(depositTotalPaisa);
  Money get deliveryFee => Money.fromPaisa(deliveryFeePaisa);
  Money get total => Money.fromPaisa(totalPaisa);

  bool get canCancelDirectly => status == OrderStatus.pending;
  bool get canRequestCancellation =>
      status == OrderStatus.accepted ||
      status == OrderStatus.preparing ||
      status == OrderStatus.ready;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final branch = json['branch'] as Map<String, dynamic>?;
    final vendor = json['vendor'] as Map<String, dynamic>? ?? branch?['vendor'] as Map<String, dynamic>?;
    final delivery = json['delivery'] as Map<String, dynamic>?;
    final rider = delivery?['rider'] as Map<String, dynamic>?;
    final slot = json['deliverySlot'] as Map<String, dynamic>?;
    final address = json['deliveryAddress'] as Map<String, dynamic>?;

    var rawItems = json['items'] as List<dynamic>? ?? [];
    List<OrderItemModel> itemsList =
        rawItems.map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>)).toList();

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? json['order_number']?.toString() ?? 'GL-000000',
      checkoutId: json['checkoutId']?.toString() ?? json['checkout_id']?.toString(),
      vendorName: vendor?['businessName']?.toString() ?? json['vendorName']?.toString() ?? 'LPG Vendor',
      branchName: branch?['name']?.toString() ?? json['branchName']?.toString() ?? 'Main Branch',
      branchPhone: branch?['phone']?.toString() ?? json['branchPhone']?.toString(),
      status: OrderStatus.fromString(json['status']?.toString()),
      paymentStatus: json['paymentStatus']?.toString() ?? json['payment_status']?.toString() ?? 'PENDING',
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString() ?? 'COD',
      deliveryMode: json['deliveryMode']?.toString() ?? json['delivery_mode']?.toString() ?? 'ASAP',
      deliverySlotFormatted: slot != null ? '${slot['date']} (${slot['startTime']} - ${slot['endTime']})' : json['deliverySlotFormatted']?.toString(),
      deliveryAddressText: address != null
          ? '${address['fullAddress'] ?? ''}, ${address['thana'] ?? ''}, ${address['district'] ?? ''}'
          : json['deliveryAddressText']?.toString() ?? 'Address',
      subtotalPaisa: json['subtotalPaisa'] ?? json['subtotal_paisa'] ?? 0,
      depositTotalPaisa: json['depositTotalPaisa'] ?? json['deposit_total_paisa'] ?? json['depositPaisa'] ?? 0,
      deliveryFeePaisa: json['deliveryFeePaisa'] ?? json['delivery_fee_paisa'] ?? 5000,
      totalPaisa: json['totalPaisa'] ?? json['total_paisa'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      riderName: rider?['fullName']?.toString() ?? json['riderName']?.toString(),
      riderPhone: rider?['phone']?.toString() ?? json['riderPhone']?.toString(),
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'checkoutId': checkoutId,
      'vendorName': vendorName,
      'branchName': branchName,
      'branchPhone': branchPhone,
      'status': status.toApiString(),
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'deliveryMode': deliveryMode,
      'deliverySlotFormatted': deliverySlotFormatted,
      'deliveryAddressText': deliveryAddressText,
      'subtotalPaisa': subtotalPaisa,
      'depositTotalPaisa': depositTotalPaisa,
      'deliveryFeePaisa': deliveryFeePaisa,
      'totalPaisa': totalPaisa,
      'createdAt': createdAt.toIso8601String(),
      'riderName': riderName,
      'riderPhone': riderPhone,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

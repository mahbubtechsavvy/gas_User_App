import '../core/money/money.dart';
import 'product_model.dart';

class CartItemModel {
  final String id;
  final String branchId;
  final String branchName;
  final String vendorName;
  final String productId;
  final String productName;
  final String variantId;
  final String variantName;
  final double? cylinderSizeKg;
  final SupplyType supplyType;
  final int unitPricePaisa;
  final int depositPaisa;
  final int quantity;
  final String? imageUrl;

  CartItemModel({
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.vendorName,
    required this.productId,
    required this.productName,
    required this.variantId,
    required this.variantName,
    this.cylinderSizeKg,
    this.supplyType = SupplyType.refill,
    required this.unitPricePaisa,
    this.depositPaisa = 0,
    required this.quantity,
    this.imageUrl,
  });

  Money get unitPrice => Money.fromPaisa(unitPricePaisa);
  Money get deposit => Money.fromPaisa(depositPaisa);
  Money get lineSubtotal => Money.fromPaisa(unitPricePaisa * quantity);
  Money get lineDepositTotal => Money.fromPaisa(depositPaisa * quantity);
  Money get lineTotal => Money.fromPaisa((unitPricePaisa + depositPaisa) * quantity);

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final variant = json['variant'] as Map<String, dynamic>?;
    final product = json['product'] as Map<String, dynamic>? ?? variant?['product'] as Map<String, dynamic>?;
    final branch = json['branch'] as Map<String, dynamic>?;
    final vendor = branch?['vendor'] as Map<String, dynamic>?;

    return CartItemModel(
      id: json['id']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? json['branch_id']?.toString() ?? branch?['id']?.toString() ?? '',
      branchName: branch?['name']?.toString() ?? json['branchName']?.toString() ?? 'Main Branch',
      vendorName: vendor?['businessName']?.toString() ?? json['vendorName']?.toString() ?? 'Vendor',
      productId: product?['id']?.toString() ?? json['productId']?.toString() ?? '',
      productName: product?['name']?.toString() ?? json['productName']?.toString() ?? 'LPG Cylinder',
      variantId: variant?['id']?.toString() ?? json['variantId']?.toString() ?? '',
      variantName: variant?['name']?.toString() ?? json['variantName']?.toString() ?? '',
      cylinderSizeKg: variant?['cylinderSizeKg'] != null
          ? (variant!['cylinderSizeKg'] as num).toDouble()
          : (json['cylinderSizeKg'] != null ? (json['cylinderSizeKg'] as num).toDouble() : null),
      supplyType: SupplyType.fromString(
        variant?['supplyType']?.toString() ?? json['supplyType']?.toString(),
      ),
      unitPricePaisa: json['unitPricePaisa'] ?? json['unit_price_paisa'] ?? variant?['pricePaisa'] ?? 140000,
      depositPaisa: json['depositPaisa'] ?? json['deposit_paisa'] ?? variant?['depositPaisa'] ?? 0,
      quantity: json['quantity'] ?? 1,
      imageUrl: product?['imageUrl']?.toString() ?? json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'branchName': branchName,
      'vendorName': vendorName,
      'productId': productId,
      'productName': productName,
      'variantId': variantId,
      'variantName': variantName,
      'cylinderSizeKg': cylinderSizeKg,
      'supplyType': supplyType.toApiString(),
      'unitPricePaisa': unitPricePaisa,
      'depositPaisa': depositPaisa,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}

class BranchCartGroupModel {
  final String branchId;
  final String branchName;
  final String vendorName;
  final bool isOpen;
  final int deliveryFeePaisa;
  final List<CartItemModel> items;

  BranchCartGroupModel({
    required this.branchId,
    required this.branchName,
    required this.vendorName,
    this.isOpen = true,
    this.deliveryFeePaisa = 5000,
    required this.items,
  });

  int get subtotalPaisa => items.fold(0, (sum, i) => sum + (i.unitPricePaisa * i.quantity));
  int get depositTotalPaisa => items.fold(0, (sum, i) => sum + (i.depositPaisa * i.quantity));
  int get groupTotalPaisa => subtotalPaisa + depositTotalPaisa + deliveryFeePaisa;

  Money get subtotal => Money.fromPaisa(subtotalPaisa);
  Money get depositTotal => Money.fromPaisa(depositTotalPaisa);
  Money get deliveryFee => Money.fromPaisa(deliveryFeePaisa);
  Money get groupTotal => Money.fromPaisa(groupTotalPaisa);
}

class CartModel {
  final List<BranchCartGroupModel> groups;

  CartModel({required this.groups});

  factory CartModel.empty() => CartModel(groups: []);

  bool get isEmpty => groups.isEmpty || totalItemsCount == 0;
  bool get isNotEmpty => !isEmpty;

  int get totalItemsCount => groups.fold(0, (sum, g) => sum + g.items.fold(0, (iSum, item) => iSum + item.quantity));
  int get subtotalPaisa => groups.fold(0, (sum, g) => sum + g.subtotalPaisa);
  int get depositTotalPaisa => groups.fold(0, (sum, g) => sum + g.depositTotalPaisa);
  int get deliveryFeeTotalPaisa => groups.fold(0, (sum, g) => sum + g.deliveryFeePaisa);
  int get grandTotalPaisa => subtotalPaisa + depositTotalPaisa + deliveryFeeTotalPaisa;

  Money get subtotal => Money.fromPaisa(subtotalPaisa);
  Money get depositTotal => Money.fromPaisa(depositTotalPaisa);
  Money get deliveryFeeTotal => Money.fromPaisa(deliveryFeeTotalPaisa);
  Money get grandTotal => Money.fromPaisa(grandTotalPaisa);

  factory CartModel.fromItems(List<CartItemModel> items, {Map<String, int>? branchDeliveryFees}) {
    if (items.isEmpty) return CartModel.empty();

    final Map<String, List<CartItemModel>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.branchId, () => []).add(item);
    }

    final groups = grouped.entries.map((entry) {
      final first = entry.value.first;
      final fee = branchDeliveryFees?[entry.key] ?? 5000;
      return BranchCartGroupModel(
        branchId: entry.key,
        branchName: first.branchName,
        vendorName: first.vendorName,
        deliveryFeePaisa: fee,
        items: entry.value,
      );
    }).toList();

    return CartModel(groups: groups);
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    var rawGroups = json['groups'] as List<dynamic>?;
    if (rawGroups != null) {
      List<BranchCartGroupModel> groupList = rawGroups.map((g) {
        var rawItems = g['items'] as List<dynamic>? ?? [];
        return BranchCartGroupModel(
          branchId: g['branchId']?.toString() ?? '',
          branchName: g['branchName']?.toString() ?? 'Branch',
          vendorName: g['vendorName']?.toString() ?? 'Vendor',
          isOpen: g['isOpen'] ?? true,
          deliveryFeePaisa: g['deliveryFeePaisa'] ?? 5000,
          items: rawItems.map((i) => CartItemModel.fromJson(i as Map<String, dynamic>)).toList(),
        );
      }).toList();
      return CartModel(groups: groupList);
    }

    var rawItems = json['items'] as List<dynamic>? ?? [];
    List<CartItemModel> items = rawItems.map((i) => CartItemModel.fromJson(i as Map<String, dynamic>)).toList();
    return CartModel.fromItems(items);
  }
}

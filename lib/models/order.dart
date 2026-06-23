class Order {
  final int id;
  final String orderNumber;
  final int vendorId;
  final String shopName;
  final String orderStatus;
  final double totalAmount;
  final String paymentMethod;
  final String deliveryAddress;
  final String? notes;
  final DateTime? createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.vendorId,
    required this.shopName,
    required this.orderStatus,
    required this.totalAmount,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.notes,
    this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.map((item) => OrderItem.fromJson(item)).toList()
        : const <OrderItem>[];

    return Order(
      id: _parseInt(json['id']),
      orderNumber: json['order_number']?.toString() ?? '#${json['id']}',
      vendorId: _parseInt(json['vendor_id']),
      shopName: json['shop_name']?.toString() ?? 'Vendor',
      orderStatus: json['order_status']?.toString() ?? 'pending',
      totalAmount: _parseDouble(json['total_amount']),
      paymentMethod: json['payment_method']?.toString() ?? 'cod',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      items: items,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final image = json['product_image']?.toString();

    return OrderItem(
      id: _parseInt(json['id']),
      orderId: _parseInt(json['order_id']),
      productId: _parseInt(json['product_id']),
      productName: json['product_name']?.toString() ?? 'Product',
      productImage: image != null && image.isNotEmpty
          ? _absoluteImageUrl(image)
          : null,
      quantity: _parseInt(json['quantity']),
      price: _parseDouble(json['price']),
      total: _parseDouble(json['total']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static String _absoluteImageUrl(String image) {
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    return 'https://gaslagbaadmin.gtgroup.cloud/$image';
  }
}

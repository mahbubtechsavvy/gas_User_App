class Product {
  final int id;
  final int vendorId;
  final String vendorName;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String? imageUrl;
  final int stock;
  final String unit;
  final String status;
  final double rating;
  final String categoryName;

  Product({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    this.imageUrl,
    required this.stock,
    required this.unit,
    required this.status,
    required this.rating,
    required this.categoryName,
  });

  double get effectivePrice => discountPrice ?? price;
  bool get isAvailable => status == 'active' && stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    final image = json['image']?.toString();
    final imageUrl = image != null && image.isNotEmpty
        ? _absoluteImageUrl(image)
        : 'https://via.placeholder.com/300x300?text=Gas+Product';

    return Product(
      id: _parseInt(json['id']),
      vendorId: _parseInt(json['vendor_id']),
      vendorName:
          json['shop_name']?.toString() ??
          json['vendor_name']?.toString() ??
          'Vendor',
      name: json['name']?.toString() ?? 'Unknown Product',
      description: json['description']?.toString() ?? '',
      price: _parseDouble(json['price']),
      discountPrice: json['discount_price'] == null
          ? null
          : _parseDouble(json['discount_price']),
      imageUrl: imageUrl,
      stock: _parseInt(json['stock']),
      unit: json['unit']?.toString() ?? 'kg',
      status: json['status']?.toString() ?? 'active',
      rating: _parseDouble(json['rating']),
      categoryName: json['category_name']?.toString() ?? 'Gas',
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

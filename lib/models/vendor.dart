class Vendor {
  final int id;
  final String uniqueId;
  final String name;
  final String shopName;
  final String shopAddress;
  final String? shopImage;
  final double rating;
  final bool isOpen;
  final String status;
  final String phone;
  final String email;

  Vendor({
    required this.id,
    required this.uniqueId,
    required this.name,
    required this.shopName,
    required this.shopAddress,
    this.shopImage,
    required this.rating,
    required this.isOpen,
    required this.status,
    required this.phone,
    required this.email,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'];
    final rating = rawRating == null
        ? 0.0
        : double.tryParse(rawRating.toString()) ?? 0.0;

    return Vendor(
      id: _parseInt(json['id']),
      uniqueId: json['unique_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? json['name']?.toString() ?? '',
      shopAddress:
          json['shop_address']?.toString() ?? json['address']?.toString() ?? '',
      shopImage: json['shop_image'],
      rating: rating,
      isOpen: json['is_open'] == true || json['is_open'] == 1,
      status: json['status']?.toString() ?? 'pending',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

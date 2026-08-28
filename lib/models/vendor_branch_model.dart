import '../core/money/money.dart';

class VendorBranchModel {
  final String id;
  final String vendorId;
  final String vendorName;
  final String branchName;
  final String phone;
  final String address;
  final String district;
  final String thana;
  final bool isOpen;
  final int deliveryFeePaisa;
  final int minOrderPaisa;
  final double rating;
  final int totalRatings;
  final double? coverageRadiusKm;
  final double? distanceKm;

  VendorBranchModel({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.branchName,
    required this.phone,
    required this.address,
    required this.district,
    required this.thana,
    this.isOpen = true,
    this.deliveryFeePaisa = 5000, // 50 BDT default
    this.minOrderPaisa = 0,
    this.rating = 4.8,
    this.totalRatings = 12,
    this.coverageRadiusKm,
    this.distanceKm,
  });

  Money get deliveryFee => Money.fromPaisa(deliveryFeePaisa);
  Money get minOrder => Money.fromPaisa(minOrderPaisa);

  String get displayName => branchName.isNotEmpty ? '$vendorName ($branchName)' : vendorName;

  factory VendorBranchModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>?;
    return VendorBranchModel(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? vendor?['id']?.toString() ?? '',
      vendorName: vendor?['businessName']?.toString() ?? json['vendorName']?.toString() ?? 'LPG Gas Vendor',
      branchName: json['name']?.toString() ?? json['branchName']?.toString() ?? 'Main Branch',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      thana: json['thana']?.toString() ?? '',
      isOpen: json['isOpen'] ?? json['is_open'] ?? true,
      deliveryFeePaisa: json['deliveryFeePaisa'] ?? json['delivery_fee_paisa'] ?? 5000,
      minOrderPaisa: json['minOrderPaisa'] ?? 0,
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : (vendor?['rating'] != null ? (vendor!['rating'] as num).toDouble() : 4.8),
      totalRatings: json['totalRatings'] ?? json['reviewCount'] ?? 10,
      coverageRadiusKm: json['coverageRadiusKm'] != null ? (json['coverageRadiusKm'] as num).toDouble() : null,
      distanceKm: json['distanceKm'] != null ? (json['distanceKm'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'branchName': branchName,
      'phone': phone,
      'address': address,
      'district': district,
      'thana': thana,
      'isOpen': isOpen,
      'deliveryFeePaisa': deliveryFeePaisa,
      'minOrderPaisa': minOrderPaisa,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }
}

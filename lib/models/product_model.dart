import '../core/money/money.dart';

enum SupplyType {
  refill,
  newCylinder,
  standard;

  static SupplyType fromString(String? type) {
    if (type == null) return SupplyType.refill;
    switch (type.toUpperCase()) {
      case 'NEW_CYLINDER':
      case 'NEW':
        return SupplyType.newCylinder;
      case 'STANDARD':
        return SupplyType.standard;
      case 'REFILL':
      default:
        return SupplyType.refill;
    }
  }

  String toApiString() {
    switch (this) {
      case SupplyType.newCylinder:
        return 'NEW_CYLINDER';
      case SupplyType.standard:
        return 'STANDARD';
      case SupplyType.refill:
        return 'REFILL';
    }
  }
}

class ProductVariantModel {
  final String id;
  final String productId;
  final String name;
  final double? cylinderSizeKg;
  final SupplyType supplyType;
  final int pricePaisa;
  final int? discountPricePaisa;
  final int depositPaisa; // Refundable deposit for NEW_CYLINDER
  final int stockQuantity;
  final bool isActive;

  ProductVariantModel({
    required this.id,
    required this.productId,
    required this.name,
    this.cylinderSizeKg,
    this.supplyType = SupplyType.refill,
    required this.pricePaisa,
    this.discountPricePaisa,
    this.depositPaisa = 0,
    this.stockQuantity = 10,
    this.isActive = true,
  });

  int get effectivePricePaisa {
    if (discountPricePaisa != null && discountPricePaisa! > 0 && discountPricePaisa! < pricePaisa) {
      return discountPricePaisa!;
    }
    return pricePaisa;
  }

  Money get price => Money.fromPaisa(pricePaisa);
  Money get discountPrice => Money.fromPaisa(discountPricePaisa ?? pricePaisa);
  Money get effectivePrice => Money.fromPaisa(effectivePricePaisa);
  Money get deposit => Money.fromPaisa(depositPaisa);
  Money get totalPrice => Money.fromPaisa(effectivePricePaisa + (supplyType == SupplyType.newCylinder ? depositPaisa : 0));

  bool get inStock => stockQuantity > 0;
  bool get hasDiscount => discountPricePaisa != null && discountPricePaisa! > 0 && discountPricePaisa! < pricePaisa;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Standard Variant',
      cylinderSizeKg: json['cylinderSizeKg'] != null
          ? (json['cylinderSizeKg'] as num).toDouble()
          : (json['cylinder_size_kg'] != null ? (json['cylinder_size_kg'] as num).toDouble() : 12.0),
      supplyType: SupplyType.fromString(json['supplyType']?.toString() ?? json['supply_type']?.toString()),
      pricePaisa: json['pricePaisa'] ?? json['price_paisa'] ?? 140000,
      discountPricePaisa: json['discountPricePaisa'] ?? json['discount_price_paisa'],
      depositPaisa: json['depositPaisa'] ?? json['deposit_paisa'] ?? 0,
      stockQuantity: json['stock'] ?? json['stockQuantity'] ?? json['stock_quantity'] ?? 10,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'cylinderSizeKg': cylinderSizeKg,
      'supplyType': supplyType.toApiString(),
      'pricePaisa': pricePaisa,
      'discountPricePaisa': discountPricePaisa,
      'depositPaisa': depositPaisa,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
    };
  }
}

class ProductModel {
  final String id;
  final String vendorId;
  final String categoryId;
  final String? categoryName;
  final String name;
  final String description;
  final String brand;
  final String unit;
  final String? imageUrl;
  final List<String> images;
  final bool isApproved;
  final bool isActive;
  final List<ProductVariantModel> variants;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.categoryId,
    this.categoryName,
    required this.name,
    required this.description,
    required this.brand,
    this.unit = 'kg',
    this.imageUrl,
    this.images = const [],
    this.isApproved = true,
    this.isActive = true,
    this.variants = const [],
  });

  ProductVariantModel? get defaultVariant {
    if (variants.isEmpty) return null;
    return variants.firstWhere((v) => v.isActive && v.inStock, orElse: () => variants.first);
  }

  Money get minPrice {
    if (variants.isEmpty) return Money.zero();
    int min = variants.first.effectivePricePaisa;
    for (var v in variants) {
      if (v.effectivePricePaisa < min) min = v.effectivePricePaisa;
    }
    return Money.fromPaisa(min);
  }

  String get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl!;
    if (images.isNotEmpty && images.first.isNotEmpty) return images.first;
    final b = brand.toLowerCase();
    if (b.contains('beximco')) return 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800&auto=format&fit=crop&q=60';
    if (b.contains('omera')) return 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=60';
    if (b.contains('jamuna')) return 'https://images.unsplash.com/photo-1584992236310-6edddc08acff?w=800&auto=format&fit=crop&q=60';
    if (b.contains('universal')) return 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&auto=format&fit=crop&q=60';
    return 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=800&auto=format&fit=crop&q=60';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var rawVariants = json['variants'] as List<dynamic>? ?? [];
    List<ProductVariantModel> variantList = rawVariants
        .map((v) => ProductVariantModel.fromJson(v as Map<String, dynamic>))
        .toList();

    var rawImages = json['images'] as List<dynamic>? ?? [];
    List<String> imageList = [];
    for (var img in rawImages) {
      if (img is String && img.isNotEmpty) {
        imageList.add(img);
      } else if (img is Map<String, dynamic>) {
        if (img['url'] != null && img['url'].toString().isNotEmpty) {
          imageList.add(img['url'].toString());
        } else if (img['storageKey'] != null && img['storageKey'].toString().isNotEmpty) {
          imageList.add(img['storageKey'].toString());
        }
      }
    }

    final directImage = json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? json['photoUrl']?.toString();
    final firstImage = imageList.isNotEmpty ? imageList.first : null;

    return ProductModel(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? json['vendor_id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? json['category_id']?.toString() ?? '',
      categoryName: json['category']?['name']?.toString() ?? json['categoryName']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Gas Lagba',
      unit: json['unit']?.toString() ?? 'kg',
      imageUrl: directImage ?? firstImage,
      images: imageList,
      isApproved: json['isApproved'] ?? json['is_approved'] ?? true,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      variants: variantList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'brand': brand,
      'unit': unit,
      'imageUrl': imageUrl,
      'images': images,
      'isApproved': isApproved,
      'isActive': isActive,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}

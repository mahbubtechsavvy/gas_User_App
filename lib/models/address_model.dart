class AddressModel {
  final String id;
  final String label;
  final String recipientName;
  final String phone;
  final String division;
  final String district;
  final String thana;
  final String fullAddress;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    this.label = 'HOME',
    required this.recipientName,
    required this.phone,
    required this.division,
    required this.district,
    required this.thana,
    required this.fullAddress,
    this.landmark,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  String get shortSummary => '$fullAddress, $thana, $district';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'HOME',
      recipientName: json['recipientName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      division: json['division']?.toString() ?? json['district']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      thana: json['thana']?.toString() ?? json['area']?.toString() ?? '',
      fullAddress: json['fullAddress']?.toString() ?? json['line1']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? json['line2']?.toString(),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'recipientName': recipientName,
      'phone': phone,
      'division': division,
      'district': district,
      'thana': thana,
      'fullAddress': fullAddress,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? phone,
    String? division,
    String? district,
    String? thana,
    String? fullAddress,
    String? landmark,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      division: division ?? this.division,
      district: district ?? this.district,
      thana: thana ?? this.thana,
      fullAddress: fullAddress ?? this.fullAddress,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

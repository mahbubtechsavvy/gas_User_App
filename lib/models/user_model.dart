class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? customerId;
  final String locale;
  final bool marketingOptIn;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.customerId,
    this.locale = 'bn',
    this.marketingOptIn = true,
    this.role = 'CUSTOMER',
  });

  bool get isProfileComplete =>
      fullName != null &&
      fullName!.trim().isNotEmpty &&
      phone != null &&
      phone!.trim().isNotEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: customer?['fullName']?.toString() ?? json['fullName']?.toString() ?? json['name']?.toString(),
      phone: customer?['phone']?.toString() ?? json['phone']?.toString(),
      customerId: customer?['id']?.toString() ?? json['customerId']?.toString(),
      locale: json['locale']?.toString() ?? 'bn',
      marketingOptIn: customer?['marketingOptIn'] ?? json['marketingOptIn'] ?? true,
      role: json['role']?.toString() ?? 'CUSTOMER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'customerId': customerId,
      'locale': locale,
      'marketingOptIn': marketingOptIn,
      'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? customerId,
    String? locale,
    bool? marketingOptIn,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      customerId: customerId ?? this.customerId,
      locale: locale ?? this.locale,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
      role: role ?? this.role,
    );
  }
}

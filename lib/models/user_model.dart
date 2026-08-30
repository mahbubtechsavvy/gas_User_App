class UserModel {
  final String id;
  final String? uniqueCode;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatarKey;
  final String? avatarUrl;
  final String? customerId;
  final String locale;
  final bool marketingOptIn;
  final String role;

  UserModel({
    required this.id,
    this.uniqueCode,
    required this.email,
    this.fullName,
    this.phone,
    this.avatarKey,
    this.avatarUrl,
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
    final userObj = json['user'] as Map<String, dynamic>?;

    final uniqueCode = json['uniqueCode']?.toString() ??
        userObj?['uniqueCode']?.toString() ??
        customer?['uniqueCode']?.toString();

    final avatarKey = json['avatarKey']?.toString() ??
        userObj?['avatarKey']?.toString() ??
        customer?['avatarKey']?.toString();

    final avatarUrl = json['avatarUrl']?.toString() ??
        userObj?['avatarUrl']?.toString() ??
        customer?['avatarUrl']?.toString() ??
        avatarKey;

    return UserModel(
      id: json['id']?.toString() ?? '',
      uniqueCode: uniqueCode,
      email: json['email']?.toString() ?? userObj?['email']?.toString() ?? '',
      fullName: customer?['fullName']?.toString() ??
          userObj?['fullName']?.toString() ??
          json['fullName']?.toString() ??
          json['name']?.toString(),
      phone: customer?['phone']?.toString() ?? userObj?['phone']?.toString() ?? json['phone']?.toString(),
      avatarKey: avatarKey,
      avatarUrl: avatarUrl,
      customerId: customer?['id']?.toString() ?? json['customerId']?.toString(),
      locale: json['locale']?.toString() ?? userObj?['locale']?.toString() ?? 'bn',
      marketingOptIn: customer?['marketingOptIn'] ?? json['marketingOptIn'] ?? true,
      role: json['role']?.toString() ?? userObj?['kind']?.toString() ?? 'CUSTOMER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uniqueCode': uniqueCode,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'avatarKey': avatarKey,
      'avatarUrl': avatarUrl,
      'customerId': customerId,
      'locale': locale,
      'marketingOptIn': marketingOptIn,
      'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    String? uniqueCode,
    String? email,
    String? fullName,
    String? phone,
    String? avatarKey,
    String? avatarUrl,
    String? customerId,
    String? locale,
    bool? marketingOptIn,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarKey: avatarKey ?? this.avatarKey,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      customerId: customerId ?? this.customerId,
      locale: locale ?? this.locale,
      marketingOptIn: marketingOptIn ?? this.marketingOptIn,
      role: role ?? this.role,
    );
  }
}

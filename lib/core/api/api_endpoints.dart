import '../config/app_config.dart';

class ApiEndpoints {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Auth (Email OTP)
  static String get requestOtp => '$baseUrl/auth/otp/request';
  static String get verifyOtp => '$baseUrl/auth/otp/verify';

  // Current User & Customer Profile
  static String get me => '$baseUrl/me';
  static String get meCustomer => '$baseUrl/me/customer';

  // Addresses
  static String get addresses => '$baseUrl/me/addresses';
  static String address(String id) => '$baseUrl/me/addresses/$id';
  static String setDefaultAddress(String id) => '$baseUrl/me/addresses/$id/default';
  static String addressServingBranches(String id) => '$baseUrl/me/addresses/$id/branches';

  // Catalogue
  static String get categories => '$baseUrl/categories';
  static String get branches => '$baseUrl/branches';
  static String branch(String id) => '$baseUrl/branches/$id';
  static String branchDeliverySlots(String id) => '$baseUrl/branches/$id/delivery-slots';
  static String get products => '$baseUrl/products';
  static String product(String id) => '$baseUrl/products/$id';

  // Cart
  static String get cart => '$baseUrl/me/cart';
  static String get cartItems => '$baseUrl/me/cart/items';
  static String cartItem(String id) => '$baseUrl/me/cart/items/$id';
  static String get cartValidate => '$baseUrl/me/cart/validate';

  // Orders & Checkout
  static String get checkout => '$baseUrl/me/orders/checkout';
  static String get orders => '$baseUrl/me/orders';
  static String order(String id) => '$baseUrl/me/orders/$id';
  static String cancelOrder(String id) => '$baseUrl/me/orders/$id/cancel';
  static String submitOrderReview(String id) => '$baseUrl/me/orders/$id/reviews';
  static String reportOrderIssue(String id) => '$baseUrl/me/orders/$id/report';
  static String submitOrderPayment(String id) => '$baseUrl/me/orders/$id/payment';
  static String orderDelivery(String id) => '$baseUrl/orders/$id/delivery';

  // Payments
  static String get initPayment => '$baseUrl/payments/init';
  static String get myPayments => '$baseUrl/me/payments';

  // Notifications
  static String get notifications => '$baseUrl/me/notifications';
  static String get unreadNotificationsCount => '$baseUrl/me/notifications/unread-count';
  static String readNotification(String id) => '$baseUrl/me/notifications/$id/read';
  static String get readAllNotifications => '$baseUrl/me/notifications/read-all';
  static String get notificationPreferences => '$baseUrl/me/notifications/preferences';

  // Devices & Push
  static String get devices => '$baseUrl/devices';
  static String device(String token) => '$baseUrl/devices/$token';
}

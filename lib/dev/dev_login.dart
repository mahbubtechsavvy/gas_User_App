/// DEV-LOGIN-BACKDOOR — TEMPORARY. Delete this file once the backend is complete; the
/// removal checklist lives in gas-lagba-api/docs/06-security/DEV_LOGIN_BACKDOOR.md.
///
/// A one-tap way past the email-OTP screen so the UI can be exercised before OTP delivery
/// works end to end. It first asks the API for a real throwaway customer session, so
/// authenticated screens work against real data; if the API is unreachable or has the
/// backdoor switched off, it falls back to a purely local session so the UI is still
/// browsable — authenticated calls then fail, which is expected.
///
/// [kDebugMode] is the lock. Release and profile builds compile the button and this
/// session away entirely, so a shipped APK cannot contain the backdoor even if someone
/// forgets to remove the code.
library;

import 'package:flutter/foundation.dart';

import '../core/api/api_endpoints.dart';

class DevLogin {
  const DevLogin._();

  /// Off in release/profile builds, always. Debug builds can still opt out with
  /// `flutter run --dart-define=DEV_LOGIN=false`.
  static bool get enabled => kDebugMode && const bool.fromEnvironment('DEV_LOGIN', defaultValue: true);

  /// Deliberately kept here rather than in ApiEndpoints, so removal is one file.
  static String get endpoint => '${ApiEndpoints.baseUrl}/auth/dev-login';

  /// Deliberately not token-shaped, so it is obvious in a log that it is not a real one.
  static const String placeholderToken = 'dev-login-placeholder-not-a-real-token';

  /// Used when the API cannot be reached. The profile is complete on purpose: an
  /// incomplete one would divert the app to the profile-setup screen on every launch.
  /// Reserved `.local` TLD (RFC 6762): this address can never receive mail.
  static Map<String, dynamic> offlineProfile() => {
    'id': 'usr_devlogin',
    'email': 'dev-customer@gaslagba.local',
    'fullName': 'Dev Customer (backdoor)',
    'phone': '+8800000000000',
    'locale': 'en',
    'role': 'CUSTOMER',
  };
}

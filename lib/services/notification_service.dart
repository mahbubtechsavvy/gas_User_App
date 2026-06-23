import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class NotificationService {
  static FirebaseMessaging? _fcm;

  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization skipped: $e');
    }

    try {
      _fcm = FirebaseMessaging.instance;
    } catch (e) {
      debugPrint('Firebase Messaging unavailable: $e');
      _fcm = null;
    }
  }

  static Future<String?> initialize() async {
    if (_fcm == null) {
      try {
        _fcm = FirebaseMessaging.instance;
      } catch (e) {
        debugPrint('Firebase Messaging unavailable: $e');
        return null;
      }
    }

    try {
      await _fcm!.requestPermission();
      return await _fcm!.getToken();
    } catch (e) {
      debugPrint('FCM token unavailable: $e');
      return null;
    }
  }

  static void onMessage(void Function(RemoteMessage) handler) {
    if (_fcm == null) return;
    FirebaseMessaging.onMessage.listen(handler);
  }

  static void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    if (_fcm == null) return;
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }
}

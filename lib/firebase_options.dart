// File generated from android/app/google-services.json for Gas Lagba userapp.
// Run flutterfire configure to add iOS/web/macOS options when those platforms are configured.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'run FlutterFire CLI after adding a web Firebase app.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'run FlutterFire CLI after adding an iOS Firebase app.',
        );
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWEwoXfc0BTVGezgCe5-eG3aLjL6JRya0',
    appId: '1:124565848314:android:06e1f0c61b4e33159a8943',
    messagingSenderId: '124565848314',
    projectId: 'gasvendorapp',
    storageBucket: 'gasvendorapp.firebasestorage.app',
  );
}

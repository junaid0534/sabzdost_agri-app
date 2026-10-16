// File generated for SabzDost Firebase integration
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2-Cptk6pfCxdLXJIs_aK3k7BQWag9GlA',
    appId: '1:276136067728:android:8b9e8687b875b163598e15',
    messagingSenderId: '276136067728',
    projectId: 'sabzdost-513bc',
    storageBucket: 'sabzdost-513bc.firebasestorage.app',
  );
}

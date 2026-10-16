import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Safe initialization of Firebase with native and options fallback
  static Future<void> initialize() async {
    try {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (_) {
        // Fallback for native google-services.json on Android
        await Firebase.initializeApp();
      }
      _isInitialized = true;
      debugPrint("Firebase successfully initialized for SabzDost!");
    } catch (e) {
      _isInitialized = false;
      debugPrint("Firebase initialization note: $e");
    }
  }
}

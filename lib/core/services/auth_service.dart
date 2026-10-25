import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/controllers/user_session_controller.dart';
import '../../features/auth/models/app_role.dart';

class EmailNotVerifiedException implements Exception {
  final String email;
  final String message;
  EmailNotVerifiedException({required this.email, required this.message});

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  /// Register a new user with Firebase Auth, send verification link, and save profile into Firestore
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required AppRole role,
    required String district,
    String? businessOrFarmName,
    String? licenseNo,
  }) async {
    try {
      // 1. Create Auth Account in Firebase Authentication
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = cred.user;
      if (user != null) {
        // Set display name in Firebase Auth
        await user.updateDisplayName(name.trim());

        // Send email verification link
        await user.sendEmailVerification();

        // 2. Prepare user document for Firestore 'users' collection
        final isDealer = role == AppRole.seedFertilizerDealer;
        final userData = {
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
          'role': role.id,
          'district': district.trim(),
          'businessOrFarmName': businessOrFarmName?.trim() ?? '',
          'licenseNo': licenseNo?.trim() ?? '',
          'isVerified': !isDealer, // Dealers may require document verification
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // 3. Write to Cloud Firestore
        await _firestore.collection('users').doc(user.uid).set(userData);

        // 4. Update in-memory user session
        UserSessionController.instance.registerUser(
          uid: user.uid,
          email: email.trim(),
          name: name.trim(),
          phone: phone.trim(),
          role: role,
          district: district.trim(),
          businessOrFarmName: businessOrFarmName?.trim(),
          licenseNo: licenseNo?.trim(),
          isVerified: !isDealer,
        );

        debugPrint("User successfully registered in Firebase & Firestore: ${user.uid}");
      }

      return cred;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      throw _getFriendlyAuthErrorMessage(e.code);
    } catch (e) {
      debugPrint("Registration error: $e");
      throw "Registration failed: $e";
    }
  }

  /// Sign In with Email and Password, then load user profile from Firestore
  Future<AppRole> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = cred.user;
      if (user == null) {
        throw "Failed to retrieve user details.";
      }

      // Reload to ensure we have the latest emailVerified status
      await user.reload();
      final freshUser = _auth.currentUser ?? user;

      // Mandatory Email Verification Check
      if (!freshUser.emailVerified) {
        throw EmailNotVerifiedException(
          email: freshUser.email ?? email,
          message: "Aapki email verify nahi hui. Barah-e-karam apni email par bheje gaye link par click karein.",
        );
      }

      // Fetch user profile from Firestore
      final doc = await _firestore.collection('users').doc(freshUser.uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        UserSessionController.instance.loadFromFirestore(data);

        // Update Firestore emailVerified status if needed
        if (data['emailVerified'] != true) {
          await _firestore.collection('users').doc(freshUser.uid).update({
            'emailVerified': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        return UserSessionController.instance.activeRole;
      } else {
        // Fallback if firestore document hasn't been created yet
        UserSessionController.instance.registerUser(
          uid: freshUser.uid,
          email: freshUser.email ?? email,
          name: freshUser.displayName ?? "User",
          phone: "",
          role: AppRole.farmer,
          district: "Multan",
        );
        return AppRole.farmer;
      }
    } on EmailNotVerifiedException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Sign-In Error: ${e.code} - ${e.message}");
      throw _getFriendlyAuthErrorMessage(e.code);
    } catch (e) {
      debugPrint("Sign-In error: $e");
      throw "Login failed: $e";
    }
  }

  /// Check if the currently signed-in user's email has been verified
  Future<bool> checkEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      final freshUser = _auth.currentUser;
      if (freshUser != null && freshUser.emailVerified) {
        // Update Firestore flag as well
        await _firestore.collection('users').doc(freshUser.uid).update({
          'emailVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error checking email verification: $e");
      return false;
    }
  }

  /// Resend email verification link to the current user
  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw "No user session found. Please log in again.";
      }
    } on FirebaseAuthException catch (e) {
      throw _getFriendlyAuthErrorMessage(e.code);
    }
  }

  /// Auto-load existing user profile on app start (if already signed in and email is verified)
  Future<bool> tryAutoLogin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Must be verified
      await user.reload();
      final freshUser = _auth.currentUser;
      if (freshUser == null || !freshUser.emailVerified) return false;

      final doc = await _firestore.collection('users').doc(freshUser.uid).get();
      if (doc.exists && doc.data() != null) {
        UserSessionController.instance.loadFromFirestore(doc.data()!);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Auto login note: $e");
      return false;
    }
  }

  /// Send password reset link to user email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _getFriendlyAuthErrorMessage(e.code);
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      UserSessionController.instance.clearSession();
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
  }

  /// Convert technical Firebase error codes into friendly user messages
  String _getFriendlyAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'The email address is not valid. Please enter a valid email.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'user-not-found':
        return 'No account found for this email. Please register first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please verify and try again.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again after a few moments.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication error ($code). Please try again.';
    }
  }
}

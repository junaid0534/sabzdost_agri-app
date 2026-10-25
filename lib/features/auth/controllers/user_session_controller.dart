import 'package:flutter/foundation.dart';
import '../models/app_role.dart';

class UserSessionController extends ChangeNotifier {
  UserSessionController._();
  static final UserSessionController instance = UserSessionController._();

  String? _uid;
  String? _email;
  AppRole _activeRole = AppRole.farmer;
  String? _userName;
  String? _userPhone;
  String? _district;
  String? _businessOrFarmName;
  String? _licenseNo;
  bool _isVerified = true;
  bool _isRegistered = false;

  String get uid => _uid ?? '';
  String get email => _email ?? '';
  AppRole get activeRole => _activeRole;
  String get userName => _userName ?? 'کسان بھائی';
  String get userPhone => _userPhone ?? '';
  String get district => _district ?? 'ملتان';
  String get businessOrFarmName => _businessOrFarmName ?? '';
  String get licenseNo => _licenseNo ?? '';
  bool get isVerified => _isVerified;
  bool get isRegistered => _isRegistered;

  void registerUser({
    String? uid,
    String? email,
    required String name,
    required String phone,
    required AppRole role,
    required String district,
    String? businessOrFarmName,
    String? licenseNo,
    bool? isVerified,
  }) {
    _uid = uid;
    _email = email;
    _userName = name;
    _userPhone = phone;
    _activeRole = role;
    _district = district;
    _businessOrFarmName = businessOrFarmName;
    _licenseNo = licenseNo;
    if (isVerified != null) _isVerified = isVerified;
    _isRegistered = true;
    notifyListeners();
  }

  void loadFromFirestore(Map<String, dynamic> data) {
    _uid = data['uid'] as String?;
    _email = data['email'] as String?;
    _userName = data['name'] as String? ?? 'User';
    _userPhone = data['phone'] as String? ?? '';
    _district = data['district'] as String? ?? 'Multan';
    _businessOrFarmName = data['businessOrFarmName'] as String? ?? '';
    _licenseNo = data['licenseNo'] as String? ?? '';
    _isVerified = data['isVerified'] as bool? ?? true;
    _isRegistered = true;

    final roleStr = data['role'] as String?;
    if (roleStr == 'dealer' || roleStr == 'seedFertilizerDealer') {
      _activeRole = AppRole.seedFertilizerDealer;
    } else if (roleStr == 'machinery_provider' || roleStr == 'machineryProvider') {
      _activeRole = AppRole.machineryProvider;
    } else {
      _activeRole = AppRole.farmer;
    }

    notifyListeners();
  }

  void switchRole(AppRole role) {
    if (_activeRole != role) {
      _activeRole = role;
      notifyListeners();
    }
  }

  void clearSession() {
    _uid = null;
    _email = null;
    _userName = null;
    _userPhone = null;
    _district = null;
    _businessOrFarmName = null;
    _licenseNo = null;
    _isRegistered = false;
    _activeRole = AppRole.farmer;
    notifyListeners();
  }
}

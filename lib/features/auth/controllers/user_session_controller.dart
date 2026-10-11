import 'package:flutter/foundation.dart';
import '../models/app_role.dart';

class UserSessionController extends ChangeNotifier {
  UserSessionController._();
  static final UserSessionController instance = UserSessionController._();

  AppRole _activeRole = AppRole.farmer;
  String? _userName;
  String? _userPhone;
  String? _district;
  String? _businessOrFarmName;
  bool _isRegistered = false;

  AppRole get activeRole => _activeRole;
  String get userName => _userName ?? 'کسان بھائی';
  String get userPhone => _userPhone ?? '';
  String get district => _district ?? 'ملتان';
  String get businessOrFarmName => _businessOrFarmName ?? '';
  bool get isRegistered => _isRegistered;

  void registerUser({
    required String name,
    required String phone,
    required AppRole role,
    required String district,
    String? businessOrFarmName,
  }) {
    _userName = name;
    _userPhone = phone;
    _activeRole = role;
    _district = district;
    _businessOrFarmName = businessOrFarmName;
    _isRegistered = true;
    notifyListeners();
  }

  void switchRole(AppRole role) {
    if (_activeRole != role) {
      _activeRole = role;
      notifyListeners();
    }
  }
}

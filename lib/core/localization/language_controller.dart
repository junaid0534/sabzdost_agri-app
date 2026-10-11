import 'package:flutter/material.dart';

class LanguageController extends ChangeNotifier {
  static final LanguageController instance = LanguageController._internal();
  LanguageController._internal();

  bool _isUrdu = false;

  bool get isUrdu => _isUrdu;
  bool get isEnglish => !_isUrdu;

  void toggleLanguage() {
    _isUrdu = !_isUrdu;
    notifyListeners();
  }

  void setUrdu(bool value) {
    if (_isUrdu != value) {
      _isUrdu = value;
      notifyListeners();
    }
  }
}

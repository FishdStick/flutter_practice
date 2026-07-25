import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier{
  bool _isLoggedIn = false;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;

  void login(String email, String password){
    _isLoggedIn = true;
    _userEmail = email;

    // Apparently this notifies "listening" UI widgets to re-render
    notifyListeners();
  }

  void logout(){
    _isLoggedIn = false;
    _userEmail = null;
    notifyListeners();
  }
}
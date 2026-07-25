import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

class AuthProvider extends ChangeNotifier{
  late final StreamSubscription<AuthState> _authSubscription;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(){
    _initAuthListener();
  }

  bool get isLoggedIn => _currentUser != null;
  User? get currentUser => _currentUser;
  String? get userEmail => _currentUser?.email;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initAuthListener(){
    _currentUser = supabase.auth.currentUser;
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e){
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Sign up
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e){
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await supabase.auth.signOut();
    _setLoading(false);
  }

  void _setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message){
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError(){
    _errorMessage = null;
  }

  @override
  void dispose(){
    _authSubscription.cancel();
    super.dispose();
  }
}
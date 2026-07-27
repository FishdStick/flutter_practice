import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../models/app_user.dart';

class AuthService {
  User? get currentSupabaseUser => supabase.auth.currentUser;

  AppUser? get currentUser {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    } else {
      return AppUser(id: user.id, email: user.email ?? '');
    }
  }

  bool get isLoggedIn => supabase.auth.currentUser != null;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

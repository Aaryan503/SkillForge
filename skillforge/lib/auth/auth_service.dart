import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String? email;
  final String? userId;
  final bool isAuthenticated;

  User({this.email, this.userId, this.isAuthenticated=false});
}

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super( User()) {
    _initializeUser();
  }

  void _initializeUser() {
    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession?.user != null) {
      state = User(
        userId: currentSession!.user.id,
        email: currentSession.user.email,
        isAuthenticated: true,
      );
    }
  }
}
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
    String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  Future<AuthResponse> signUpWithEmailPassword(
    String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  String? getCurrentUserEmail(){
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}

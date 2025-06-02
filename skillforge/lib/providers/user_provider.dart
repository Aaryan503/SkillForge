import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillforge/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class User {
  final String? email;
  final String? userId;
  final String? username;
  final bool isAuthenticated;

  User({this.email, this.userId, this.username, this.isAuthenticated = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          userId == other.userId &&
          username == other.username &&
          isAuthenticated == other.isAuthenticated;

  @override
  int get hashCode =>
      email.hashCode ^ userId.hashCode ^ username.hashCode ^ isAuthenticated.hashCode;
}

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User()) {
    _initialize();
  }

  final AuthService _authService = AuthService();
  StreamSubscription<AuthState>? _authSubscription;
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    _setupAuthListener();
    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession?.user != null) {
      await _updateUserFromSession(currentSession);
    } else {
      print("HELLOOOOOOO 2");
      state = User();
    }
  }

  void _setupAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.signedIn:
          if (data.session?.user != null) {
            _updateUserFromSession(data.session);
          }
          break;
        case AuthChangeEvent.signedOut:
          state = User();
          break;
        default:
          break;
      }
    });
  }

  Future<void> _updateUserFromSession(Session? session) async {
    if (session?.user == null) {
      state = User();
      return;
    }
    try {
      final userId = session!.user.id;
      final email = session.user.email;
      final userRow = await Supabase.instance.client
          .from('users')
          .select('username')
          .eq('id', userId)
          .maybeSingle();
      final username = userRow?['username'] as String?;
      state = User(
        userId: userId,
        email: email,
        username: username,
        isAuthenticated: true,
      );
    } catch (_) {
      print("HELLLOOOOOOO");
      state = User(
        userId: session!.user.id,
        email: session.user.email,
        username: null,
        isAuthenticated: true,
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    final response = await _authService.signInWithEmailPassword(email, password);
    if (response.user == null) {
      throw Exception('Login failed: No user returned');
    }
    // Auth listener will update state
  }

  Future<void> signUp(String email, String password, String username) async {
    final response = await _authService.signUpWithEmailPassword(email, password);
    if (response.user == null) {
      throw Exception('Sign up failed: No user returned');
    }
    await Supabase.instance.client.from('users').insert({
      'id': response.user!.id,
      'email': email,
      'username': username,
    });
    // Auth listener will update state
  }

  Future<void> signOut() async {
    await _authService.signOut();
    // Auth listener will update state
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).userId;
});

final emailProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).email;
});

final usernameProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).username;
});
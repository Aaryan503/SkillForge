import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillforge/screens/auth_screen.dart';
import 'package:skillforge/screens/home_screen.dart';
import 'package:skillforge/providers/user_provider.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  
    final user = ref.watch(userProvider);

    
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: user.isAuthenticated 
                ? const HomeScreen(key: ValueKey('home'))
                : const AuthScreen(key: ValueKey('auth')),
            ),
          ),
        ],
      ),
    );
  }
}
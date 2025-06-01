import 'package:flutter/material.dart';
import 'package:skillforge/screens/auth_screen.dart';
import 'package:skillforge/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _checkInitialSession();
  }

  Future<void> _checkInitialSession() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildSplashScreen();
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }
        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        }
        final session = _getCurrentSession(snapshot);

        if (session != null && session.accessToken.isNotEmpty) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }

  Session? _getCurrentSession(AsyncSnapshot<AuthState> snapshot) {
    try {
      if (snapshot.hasData && snapshot.data != null) {
        return snapshot.data!.session;
      }
      return Supabase.instance.client.auth.currentSession;
    } catch (e) {
      debugPrint('Error getting session: $e');
      return null;
    }
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.school_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SkillForge',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking authentication...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Authentication Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to connect to authentication service',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                  });
                  _checkInitialSession();
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                child: const Text('Continue to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
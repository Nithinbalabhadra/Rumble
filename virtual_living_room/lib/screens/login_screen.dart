import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'lobby_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                child: const Text('Login with Google'),
                onPressed: () async {
                  setState(() => _loading = true);
                  try {
                    final user = await AuthService().signInWithGoogle();
                    if (!mounted) return;
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LobbyScreen()),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login failed: $e')),
                    );
                  } finally {
                    if (mounted) {
                      setState(() => _loading = false);
                    }
                  }
                },
              ),
      ),
    );
  }
}

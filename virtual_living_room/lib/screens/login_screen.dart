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
                child: const Text('Start as Guest (0-cost mode)'),
                onPressed: () async {
                  setState(() => _loading = true);
                  final user = await AuthService().signInAsGuest();
                  if (!mounted) return;
                  setState(() => _loading = false);
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LobbyScreen()),
                    );
                  }
                },
              ),
      ),
    );
  }
}

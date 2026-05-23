import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';
import 'lobby_screen.dart';

class LoginScreen extends StatefulWidget {
  final String modeLabel;
  const LoginScreen({super.key, required this.modeLabel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  bool _isAdult = false;
  bool _livenessAck = false;
  bool _idAck = false;

  final _nameController = TextEditingController(text: 'Joker Junction Player');
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _profileImageController = TextEditingController();

  final _emailRegex = RegExp(r'^[^@\s]+@gmail\.com$');
  final _mobileRegex = RegExp(r'^[0-9]{10}$');

  @override
  void initState() {
    super.initState();
    _restoreAndContinueIfSignedUp();
  }

  Future<void> _restoreAndContinueIfSignedUp() async {
    setState(() => _loading = true);
    final user = await AuthService().restoreSession();
    if (!mounted) return;
    setState(() => _loading = false);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LobbyScreen()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _profileImageController.dispose();
    super.dispose();
  }

  String? _validateInputs() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return 'Enter player name.';
    if (name.length < 3) return 'Player name must be at least 3 characters.';
    if (!_emailRegex.hasMatch(_emailController.text.trim())) return 'Enter a valid Gmail address.';
    if (!_mobileRegex.hasMatch(_mobileController.text.trim())) return 'Enter a valid 10-digit mobile number.';
    if (_profileImageController.text.trim().isEmpty) return 'Add signup profile image path or URL.';
    if (!_isAdult || !_livenessAck || !_idAck) return 'Complete all verification acknowledgements.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConfig.appName, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(AppConfig.appTagline, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              Text('Mode: ${widget.modeLabel}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Player name (must be unique)')),
              const SizedBox(height: 10),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Gmail address')),
              const SizedBox(height: 10),
              TextField(controller: _mobileController, keyboardType: TextInputType.phone, maxLength: 10, decoration: const InputDecoration(labelText: 'Mobile number', counterText: '')),
              const SizedBox(height: 10),
              TextField(controller: _profileImageController, decoration: const InputDecoration(labelText: 'Signup image URL/path')),
              CheckboxListTile(
                value: _isAdult,
                onChanged: (v) => setState(() => _isAdult = v ?? false),
                title: const Text('I confirm I am 18+'),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _livenessAck,
                onChanged: (v) => setState(() => _livenessAck = v ?? false),
                title: const Text('Verification completed at signup (camera blink/liveness)'),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _idAck,
                onChanged: (v) => setState(() => _idAck = v ?? false),
                title: const Text('Aadhaar fallback verification acknowledged at signup'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final error = _validateInputs();
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                            return;
                          }
                          final auth = AuthService();
                          final available = await auth.isDisplayNameAvailable(_nameController.text);
                          if (!available) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name already taken. Choose another player name.')));
                            return;
                          }

                          setState(() => _loading = true);
                          AppUser? user;
                          try {
                            user = await auth.signUpOnce(
                              displayName: _nameController.text,
                                email: _emailController.text,
                                mobileNumber: _mobileController.text,
                                profileImagePath: _profileImageController.text,
                                isVerifiedAtSignup: true,
                            );
                          } on StateError catch (e) {
                            if (!mounted) return;
                            setState(() => _loading = false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${e.message}')));
                            return;
                          }
                          if (!mounted) return;
                          setState(() => _loading = false);
                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LobbyScreen()),
                            );
                          }
                        },
                        child: const Text('Complete Signup'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final modeLabel = AppConfig.dataMode.name.toUpperCase();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Joker Junction',
      theme: ThemeData.dark(),
      home: LoginScreen(modeLabel: modeLabel),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/assinatura_screen.dart';

void main() {
  runApp(const EduMovApp());
}

class EduMovApp extends StatelessWidget {
  const EduMovApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduMov - Educação em Movimento',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/setup': (context) => const SetupScreen(),
        '/assinatura': (context) => const AssinaturaScreen(),
      },
    );
  }
}
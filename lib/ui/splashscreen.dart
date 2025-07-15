import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/dbhelper.dart'; // Pastikan import sesuai
import '../helpers/session_manager.dart'; // Jika kamu punya class ini

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DbHelper dbHelper = DbHelper(); // Inisialisasi DB Helper

  @override
  void initState() {
    super.initState();
    dbHelper.autoUpdateSemester(); // Jika perlu dijalankan saat splash

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (onboardingCompleted) {
        // Ganti FirebaseAuth dengan SQLite-based session
        final userId = await SessionManager.getUserId();

        if (!mounted) return;

        if (userId != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF554DDE),
              Color(0xFF8E44AD),
            ],
          ),
        ),
        child: Center(
          child: Text('MindCourse'),
        ),
      ),
    );
  }
}

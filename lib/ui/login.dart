import 'dart:async';

import 'package:MindCourse/components/alertCard.dart';
import 'package:MindCourse/helpers/auth_service.dart';
import 'package:MindCourse/ui/forms/login_form.dart';
import 'package:MindCourse/ui/forms/register_form.dart';
import 'package:flutter/material.dart';
import '/helpers/dbhelper.dart';
import '/ui/home.dart';

/// Halaman yang menangani UI dan logika untuk Login dan Registrasi.
/// Menggunakan PageView untuk beralih antara dua form.
class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final PageController _pageController = PageController();
  // ignore: unused_field
  int _currentPage = 0;

  final DbHelper dbHelper = DbHelper();

  // Controller untuk form Login
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Controller untuk form Registrasi
  final TextEditingController regNameController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();
  final TextEditingController regPasswordConfirmController =
      TextEditingController();

  Widget? _notificationCard; // Untuk menyimpan widget notifikasi
  bool _isNotificationVisible = false; // Untuk mengontrol animasi
  Timer? _notificationTimer; // Untuk menghilangkan notifikasi secara otomatis

  @override
  void dispose() {
    _pageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    regNameController.dispose();
    regEmailController.dispose();
    regPasswordController.dispose();
    _notificationTimer
        ?.cancel(); // Pastikan timer dibatalkan saat widget dihapus
    super.dispose();
  }

  void _goToRegister() {
    setState(() {
      _currentPage = 1;
    });
  }

  void _goToLogin() {
    setState(() {
      _currentPage = 0;
    });
  }

  final AuthService _authService = AuthService(); // Buat instance dari service

  Future<void> _handleLogin() async {
    try {
      final user = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Home()),
        );
      }
    } catch (e) {
      // Tangkap error dari service dan tampilkan notifikasi
      _showCustomNotification(
        e.toString().replaceFirst('Exception: ', ''),
        NotificationType.error,
      );
    }
  }

  Future<void> _handleRegister() async {
    try {
      // Panggil service untuk melakukan registrasi dengan data dari controller
      final String _ = await _authService.register(
        name: regNameController.text.trim(),
        email: regEmailController.text.trim(),
        password: regPasswordController.text.trim(),
        confirmPassword: regPasswordConfirmController.text.trim(),
      );

      // Jika registrasi di service berhasil (tidak ada exception),
      // tampilkan notifikasi sukses.
      _showCustomNotification(
        'Registrasi berhasil! Silakan masuk dengan akun baru Anda.',
        NotificationType.success,
      );

      // Setelah registrasi sukses, bersihkan field dan arahkan pengguna
      // ke halaman login untuk masuk.
      regNameController.clear();
      regEmailController.clear();
      regPasswordController.clear();
      regPasswordConfirmController.clear();
      _goToLogin(); // Panggil fungsi untuk pindah ke halaman login
    } catch (e) {
      // Jika terjadi Exception di dalam AuthService, tangkap di sini.
      // Tampilkan pesan error yang dikirim dari service.
      _showCustomNotification(
        // Menghapus "Exception: " dari pesan agar lebih rapi
        e.toString().replaceFirst('Exception: ', ''),
        NotificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentPage == 0
          ? Colors.white
          : const Color(0xFF013237),
      body: Stack(
        children: [
          // Login Page
          AnimatedOpacity(
            opacity: _currentPage == 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: _currentPage != 0,
              child: LoginForm(
                emailController: emailController,
                passwordController: passwordController,
                onLoginPressed: _handleLogin,
                onGoToRegister: _goToRegister,
              ),
            ),
          ),

          // Register Page
          AnimatedOpacity(
            opacity: _currentPage == 1 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: _currentPage != 1,
              child: RegisterForm(
                nameController: regNameController,
                emailController: regEmailController,
                passwordController: regPasswordController,
                confirmPasswordController: regPasswordConfirmController,
                onRegisterPressed: _handleRegister,
                onGoToLogin: _goToLogin,
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            // Posisi di atas layar saat terlihat, dan di luar layar saat tersembunyi
            top: _isNotificationVisible
                ? MediaQuery.of(context).padding.top + 16
                : -150,
            left: 16,
            right: 16,
            child: _notificationCard ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showCustomNotification(String message, NotificationType type) {
    if (!mounted) return;

    // Batalkan timer sebelumnya jika ada notifikasi yang masih berjalan
    _notificationTimer?.cancel();

    // Buat widget notifikasi menggunakan fungsi yang sudah Anda buat
    final notificationCard = buildNotificationCard(message, type);

    // Tampilkan notifikasi dengan animasi
    setState(() {
      _notificationCard = notificationCard;
      _isNotificationVisible = true;
    });

    // Atur timer untuk menghilangkan notifikasi setelah 4 detik
    _notificationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isNotificationVisible = false;
        });
      }
    });
  }
}

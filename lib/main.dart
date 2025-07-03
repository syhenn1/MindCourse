import 'package:flutter/material.dart';
import 'package:mindcourse/ui/login.dart';
import 'package:mindcourse/ui/home.dart';
import 'package:mindcourse/helpers/session_manager.dart';

void main() async {
  // Pastikan semua binding Flutter telah diinisialisasi sebelum menjalankan aplikasi.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

/// Widget utama aplikasi.
/// Konfigurasinya sekarang lebih sederhana, hanya mendefinisikan rute
/// dan menunjuk ke AuthGate sebagai halaman pertama.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Database',
      theme: ThemeData(primarySwatch: Colors.blue),
      // AuthGate sekarang menjadi halaman utama.
      // initialRoute tidak lagi digunakan di sini.
      home: AuthGate(),
      // Semua rute yang mungkin didefinisikan di sini agar selalu tersedia.
      routes: {
        '/login': (context) => LoginRegisterPage(),
        '/home': (context) => Home(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

/// AuthGate adalah "halaman gerbang" yang berfungsi sebagai layar pembuka.
/// Tugasnya adalah memeriksa status sesi dan mengarahkan pengguna.
class AuthGate extends StatefulWidget {
  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Menggunakan addPostFrameCallback untuk memastikan navigasi terjadi setelah
    // frame pertama selesai di-render, yang lebih aman.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSessionAndNavigate();
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    // Tunggu sesaat untuk memastikan transisi UI lebih mulus jika pengecekan sesi sangat cepat.
    await Future.delayed(Duration(milliseconds: 500));

    final userId = await SessionManager.getUserId();

    // Pastikan widget masih ada di tree sebelum melakukan navigasi.
    if (!mounted) return;

    if (userId != null) {
      // Jika ada user ID, ganti halaman saat ini dengan halaman Home.
      // Pengguna tidak bisa kembali ke AuthGate dengan tombol back.
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Jika tidak ada user ID, ganti dengan halaman Login.
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Selama pengecekan sesi, tampilkan layar loading sederhana.
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

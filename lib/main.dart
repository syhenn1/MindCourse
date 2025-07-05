import 'package:flutter/material.dart';
import 'helpers/dbhelper.dart';
import 'ui/login.dart';
import 'ui/home.dart';
import 'helpers/session_manager.dart';
import 'ui/subjectPage.dart';

final DbHelper dbHelper = DbHelper();

void main() async {
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
        '/subject': (context) => SubjectPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatefulWidget {
  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    dbHelper.autoUpdateSemester();
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
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

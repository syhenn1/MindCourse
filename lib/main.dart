import 'package:flutter/material.dart';
import 'helpers/dbhelper.dart';
import 'ui/login.dart';
import 'ui/home.dart';
import 'ui/splashscreen.dart';
import 'ui/subjectPage.dart';
import 'ui/onboarding.dart';

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
      home: SplashScreen(),
      // Semua rute yang mungkin didefinisikan di sini agar selalu tersedia.
      routes: {
        '/login': (context) => LoginRegisterPage(),
        '/home': (context) => Home(),
        '/subject': (context) => SubjectPage(),
        '/onboarding': (context) => OnboardingScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

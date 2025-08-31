import 'package:flutter/material.dart';
import 'helpers/dbhelper.dart';
import 'ui/login.dart';
import 'ui/home.dart';
import 'ui/splashscreen.dart';
import 'ui/subjectPage.dart';
import 'ui/subjectsPage.dart';
import 'ui/onboarding.dart';
import 'ui/coursesPage.dart';

final DbHelper dbHelper = DbHelper();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Database',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginRegisterPage(),
        '/home': (context) => Home(),
        '/subject': (context) => SubjectPage(),
        '/onboarding': (context) => OnboardingScreen(),
        '/subjects': (context) => SubjectsPage(),
        '/courses': (context) => CoursesPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

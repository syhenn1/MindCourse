import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '/helpers/dbhelper.dart';
import '/helpers/session_manager.dart';
import '/models/user.dart';
import '/ui/home.dart';

/// Halaman yang menangani UI dan logika untuk Login dan Registrasi.
/// Menggunakan PageView untuk beralih antara dua form.
class LoginRegisterPage extends StatefulWidget {
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final DbHelper dbHelper = DbHelper();

  // Controller untuk form Login
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Controller untuk form Registrasi
  final TextEditingController regNameController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    regNameController.dispose();
    regEmailController.dispose();
    regPasswordController.dispose();
    super.dispose();
  }

  void _goToRegister() {
    _pageController.animateToPage(
      1,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToLogin() {
    _pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password tidak boleh kosong');
      return;
    }

    final user = await dbHelper.getUserByEmail(email);

    if (user == null || user.password != password) {
      _showMessage('Email atau password salah');
    } else {
      if (user.userId == null) {
        _showMessage('Login gagal: Data pengguna rusak (ID tidak ada).');
        return;
      }

      await SessionManager.saveUserId(user.userId!);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Home()),
      );
    }
  }

  Future<void> _handleRegister() async {
    String name = regNameController.text.trim();
    String email = regEmailController.text.trim();
    String password = regPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Semua field harus diisi');
      return;
    }

    final existingEmail = await dbHelper.getUserByEmail(email);
    final existingName = await dbHelper.getUserByName(name);

    if (existingEmail != null) {
      _showMessage('Email sudah terdaftar');
      return;
    }

    if (existingName != null) {
      _showMessage('Nama sudah terdaftar');
      return;
    }

    var uuid = Uuid();
    String newUserId = uuid.v4();
    User newUser = User.create(
      userId: newUserId,
      name: name,
      phone: '', // Default ke string kosong
      email: email,
      password: password,
      dateAdded: DateTime.now().toIso8601String(),
      isDeleted: 0,
      semester: 0,
      semesterEnd: '',
    );

    String userId = (await dbHelper.insertUser(newUser)) as String;
    await SessionManager.saveUserId(userId);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Home()),
    );
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPage == 0 ? 'Login' : 'Register'),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [_buildLoginForm(), _buildRegisterForm()],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 12),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 24),
          ElevatedButton(onPressed: _handleLogin, child: Text('Login')),
          TextButton(
            onPressed: _goToRegister,
            child: Text("Belum punya akun? Daftar"),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: regNameController,
            decoration: InputDecoration(labelText: 'Nama'),
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: 12),
          TextField(
            controller: regEmailController,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 12),
          TextField(
            controller: regPasswordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 24),
          ElevatedButton(onPressed: _handleRegister, child: Text('Register')),
          TextButton(
            onPressed: _goToLogin,
            child: Text("Sudah punya akun? Login"),
          ),
        ],
      ),
    );
  }
}

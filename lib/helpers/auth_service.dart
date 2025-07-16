import 'package:MindCourse/models/user.dart'; // Sesuaikan path
import 'package:MindCourse/helpers/dbhelper.dart'; // Sesuaikan path
import 'package:MindCourse/helpers/session_manager.dart'; // Sesuaikan path
import 'package:uuid/uuid.dart';

// Kelas ini hanya fokus pada logika, tidak ada hubungannya dengan UI
class AuthService {
  final DbHelper _dbHelper = DbHelper();

  // Method untuk menangani login
  Future<User?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email dan password tidak boleh kosong');
    }

    final user = await _dbHelper.getUserByEmail(email);

    if (user == null || user.password != password) {
      throw Exception('Email atau password salah');
    }

    if (user.userId == null) {
      throw Exception('Login gagal: Data pengguna rusak (ID tidak ada).');
    }

    // Jika berhasil, simpan sesi dan kembalikan user
    await SessionManager.saveUserId(user.userId!);
    return user;
  }

  // Method untuk menangani registrasi
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      throw Exception('Semua field harus diisi');
    }

    if (password != confirmPassword) {
      throw Exception('Kata sandi tidak cocok');
    }

    final existingEmail = await _dbHelper.getUserByEmail(email);
    if (existingEmail != null) {
      throw Exception('Email sudah terdaftar');
    }

    final existingName = await _dbHelper.getUserByName(name);
    if (existingName != null) {
      throw Exception('Nama sudah terdaftar');
    }

    var uuid = Uuid();
    String newUserId = uuid.v4();
    User newUser = User.create(
      userId: newUserId,
      name: name,
      phone: '',
      email: email,
      password: password,
      dateAdded: DateTime.now().toIso8601String(),
      isDeleted: 0,
      semester: 0,
      semesterEnd: '',
    );

    // Kembalikan user ID yang baru dibuat
    return await _dbHelper.insertUser(newUser) as String;
  }
}

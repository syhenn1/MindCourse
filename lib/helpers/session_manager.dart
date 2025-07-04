import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Kelas utilitas untuk mengelola sesi pengguna.
/// Menggunakan SharedPreferences untuk menyimpan dan mengambil data sesi.
class SessionManager {
  static const _keyUserId = 'user_id';

  /// Menyimpan ID pengguna ke SharedPreferences.
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  /// Mengambil ID pengguna dari SharedPreferences.
  /// Mengembalikan null jika tidak ada ID yang tersimpan.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Menghapus data sesi (logout).
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  static Future getUserSemester() async {}
}

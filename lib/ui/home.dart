import 'package:flutter/material.dart';
import 'package:mindcourse/helpers/session_manager.dart';
import 'package:mindcourse/models/user.dart';
import 'package:mindcourse/helpers/dbhelper.dart';
import 'package:mindcourse/ui/login.dart';
import 'dart:async';


/// Halaman utama (Home) yang ditampilkan setelah pengguna berhasil login.
/// Halaman ini sekarang memuat data pengguna secara asinkron untuk ditampilkan.
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? _currentUser;
  bool _isLoading = true;

  final DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Memuat data pengguna dari database berdasarkan ID yang tersimpan di sesi.
  Future<void> _loadUserData() async {
    try {
      final userId = await SessionManager.getUserId();
      if (!mounted) return;

      if (userId != null) {
        // CATATAN: Pastikan Anda memiliki metode `getUserById` di kelas DbHelper Anda.
        final user = await dbHelper.getUserById(userId);
        setState(() {
          _currentUser = user;
        });
      } else {
        // Jika tidak ada ID pengguna di sesi, paksa logout.
        _logout();
      }
    } catch (e) {
      print("Error memuat data pengguna: $e");
      // Jika terjadi error saat memuat data, arahkan pengguna untuk logout.
      _logout();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menangani proses logout dengan membersihkan sesi dan riwayat navigasi.
  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
    // Menggunakan pushAndRemoveUntil untuk membersihkan semua rute sebelumnya,
    // sehingga pengguna tidak bisa kembali ke halaman home dengan tombol 'back'.
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginRegisterPage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Membangun body widget berdasarkan status loading dan data pengguna.
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Setelah loading selesai, periksa apakah data pengguna berhasil dimuat.
    if (_currentUser != null) {
      // Penggunaan `!` di `_currentUser!.name` aman di sini karena kita sudah memeriksa null.
      return Center(
        child: Text('Selamat datang, ${_currentUser!.name}! Anda telah login.'),
      );
    } else {
      // Jika data pengguna null setelah loading, berarti ada masalah (mis. user dihapus).
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Gagal memuat data pengguna.'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Kembali ke Login'),
            )
          ],
        ),
      );
    }
  }
}

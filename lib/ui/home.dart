import 'package:flutter/material.dart';
import '/helpers/session_manager.dart';
import '/models/user.dart';
import '/helpers/dbhelper.dart';
import '/ui/login.dart';
import '/components/courses.dart';
import '/components/subjects.dart';
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
      (Route<dynamic> route) => false,
    );
  }

  Future<void> showIncompleteInfoDialog(
    BuildContext context,
    String userId,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController semesterController = TextEditingController();
    final TextEditingController semesterEndController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false, // wajib isi
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Lengkapi Informasi Anda'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: 'Nomor HP'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: semesterController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Semester'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Wajib diisi';
                      if (int.tryParse(value) == null) return 'Harus angka';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: semesterEndController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Semester Berakhir',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        semesterEndController.text = pickedDate
                            .toIso8601String()
                            .substring(0, 10); // Format: YYYY-MM-DD
                      }
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Wajib pilih tanggal'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _logout(); // Kalau user tidak mau isi, logout paksa
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final phone = phoneController.text.trim();
                  final semester = int.parse(semesterController.text.trim());
                  final semesterEnd = semesterEndController.text.trim();

                  await dbHelper.updateUserInfo(
                    userId,
                    phone,
                    semester,
                    semesterEnd,
                  );

                  Navigator.of(ctx).pop(true);

                  // Refresh home
                  _loadUserData();
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),
      body: _buildBody(),
    );
  }

  /// Membangun body widget berdasarkan status loading dan data pengguna.
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final isIncomplete =
        (_currentUser!.phone.isEmpty) ||
        (_currentUser!.semester == 0) ||
        (_currentUser!.semesterEnd.isEmpty);

    if (isIncomplete) {
      // Show prompt and open popup after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showIncompleteInfoDialog(context, _currentUser!.userId as String);
      });

      return Center(
        child: Text(
          'Mari lengkapi informasi mu!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (_currentUser != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF007BFF),
              ),
            ),
            Text(
              'Selamat datang, ${_currentUser!.name}! Anda telah login dengan id: ${_currentUser!.userId} nomor hp ${_currentUser!.phone} email ${_currentUser!.email} semester ${_currentUser!.semester}',
            ),
            SizedBox(height: 16),
            Text(
              'Course kamu:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<Widget>>(
              future: buildCourseCards(_currentUser!.userId as String),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Terjadi error saat mengambil course.');
                } else {
                  return Column(children: snapshot.data ?? []);
                }
              },
            ),
            SizedBox(height: 16),
            Text(
              'Mata Kuliah:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<Widget>>(
              future: buildSubjectCards(context, _currentUser!.userId as String),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Terjadi error saat mengambil subject.');
                } else {
                  return Column(children: snapshot.data ?? []);
                }
              },
            ),
            SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () async {
                // Tunggu hasil dari dialog
                final result = await showAddSubjectDialog(
                  context,
                  _currentUser!.userId as String,
                );

                // Jika dialog mengembalikan true (berhasil menambah), panggil setState
                if (result == true && mounted) {
                  setState(() {
                    // Cukup panggil setState kosong. Ini akan memicu `build` ulang,
                    // dan FutureBuilder akan mengambil data subject yang baru.
                  });
                }
              },
              tooltip: 'Tambah Mata Kuliah',
              child: Icon(Icons.add),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Gagal memuat data pengguna.'),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _logout, child: Text('Kembali ke Login')),
          ],
        ),
      );
    }
  }
}

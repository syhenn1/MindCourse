import 'package:MindCourse/components/finishedDashboardCard.dart';
import 'package:MindCourse/components/unfinishedDashboardCard.dart';
import 'package:flutter/material.dart';
import '/helpers/session_manager.dart';
import '/models/user.dart';
import '/helpers/dbhelper.dart';
import '/ui/login.dart';
import '/components/courses.dart';
import '/components/subjects.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '/components/deadlineCard.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? _currentUser;
  bool _isLoading = true;
  final Map<String, String> _quotes = {
    "pagi":
        "Awali harimu dengan semangat belajar, karena setiap pengetahuan baru adalah bekal untuk masa depan yang lebih cerah.",
    "siang":
        "Gunakan siangmu untuk menambah ilmu, karena kesempatan tidak menunggu mereka yang menunda.",
    "sore":
        "Sore adalah waktu terbaik untuk merenung dan memperdalam pelajaran, agar langkah esok lebih mantap.",
    "malam":
        "Malam memberi ketenangan untuk belajar, saat fokusmu bisa sepenuhnya pada ilmu yang ingin dikuasai.",
    "tengahMalam":
        "Belajar di tengah malam adalah bukti tekad kuat, karena mimpi besar hanya lahir dari usaha yang luar biasa.",
  };

  String getQuoteByTime() {
    int hour = int.parse(DateFormat.H().format(DateTime.now()));

    if (hour >= 6 && hour < 11) {
      return _quotes["pagi"]!;
    } else if (hour >= 11 && hour < 15) {
      return _quotes["siang"]!;
    } else if (hour >= 15 && hour < 18) {
      return _quotes["sore"]!;
    } else if (hour >= 18 && hour < 23) {
      return _quotes["malam"]!;
    } else {
      return _quotes["tengahMalam"]!;
    }
  }

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
        backgroundColor: const Color(0xFF013237),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: const Color.fromARGB(255, 255, 255, 255),
              size: 32,
            ),
            onPressed: () => {},
          ),
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
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF013237),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salam bagian atas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Selamat Pagi, '),
                        TextSpan(
                          text: _currentUser!.name,
                          style: const TextStyle(
                            color: Color(0xFF4CA771), // warna khusus untuk nama
                          ),
                        ),
                        const TextSpan(text: '!'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '"${getQuoteByTime()}"',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC0E6BA),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "-ChatGPT :D",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 36),
                ],
              ),
            ),

            // Container putih isi konten utama → full sisa layar
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Dashboard',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF013237),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sudah mau Deadline! D:',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Ayo mulai kerjakan tugasmu dan raih IP tertinggi!',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const UpcomingDeadlineCard(),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          UnfinishedTaskCard(),
                          const SizedBox(width: 8),
                          FinishedTaskCard(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Menu Lainnya',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/courses');
                                  },
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF013237),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.library_books,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tugas',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/subjects');
                                  },
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF013237),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.storage,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Mata Kuliah',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

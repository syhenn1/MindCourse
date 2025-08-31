import 'package:MindCourse/components/finishedDashboardCard.dart';
import 'package:MindCourse/components/unfinishedDashboardCard.dart';
import 'package:flutter/material.dart';
import '/helpers/session_manager.dart';
import '/models/user.dart';
import '/helpers/dbhelper.dart';
import '/ui/login.dart';
import 'package:intl/intl.dart';
import '/components/deadlineCard.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DbHelper dbHelper = DbHelper();
  User? _currentUser;
  bool _isLoading = true;

  // State untuk data dashboard
  List<Map<String, dynamic>> _deadlines = [];
  int _jumlahBelumSelesai = 0;
  int _jumlahSelesai = 0;

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

  @override
  void initState() {
    super.initState();
    _refreshData(); // Panggil fungsi refresh utama saat inisialisasi
  }

  /// Memuat ulang SEMUA data yang diperlukan untuk halaman ini.
  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        _logout();
        return;
      }

      // Ambil semua data secara bersamaan untuk efisiensi
      final results = await Future.wait([
        dbHelper.getUserById(userId),
        dbHelper.getUpcomingDeadlines(),
        dbHelper.getJumlahBelumSelesai(),
        dbHelper.getJumlahSelesai(),
      ]);

      if (!mounted) return;
      setState(() {
        _currentUser = results[0] as User?;
        _deadlines = results[1] as List<Map<String, dynamic>>;
        _jumlahBelumSelesai = results[2] as int;
        _jumlahSelesai = results[3] as int;

        if (_currentUser == null) {
          _logout(); // Jika user tidak ditemukan, logout
        }
      });
    } catch (e) {
      print("Error memuat data home: $e");
      _logout(); // Jika ada error, lebih aman untuk logout
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menavigasi ke halaman lain dan me-refresh data saat kembali.
  Future<void> _navigateAndRefresh(String routeName) async {
    await Navigator.pushNamed(context, routeName);
    // Setelah kembali dari halaman lain, panggil refresh data
    _refreshData();
  }

  String getGreetingByTime() {
    int hour = int.parse(DateFormat.H().format(DateTime.now()));
    if (hour >= 6 && hour < 11) return "Selamat Pagi";
    if (hour >= 11 && hour < 15) return "Selamat Siang";
    if (hour >= 15 && hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  String getQuoteByTime() {
    int hour = int.parse(DateFormat.H().format(DateTime.now()));
    if (hour >= 6 && hour < 11) return _quotes["pagi"]!;
    if (hour >= 11 && hour < 15) return _quotes["siang"]!;
    if (hour >= 15 && hour < 18) return _quotes["sore"]!;
    if (hour >= 18 && hour < 23) return _quotes["malam"]!;
    return _quotes["tengahMalam"]!;
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
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
      barrierDismissible: false,
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
                            .substring(0, 10);
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
                _logout();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await dbHelper.updateUserInfo(
                    userId,
                    phoneController.text.trim(),
                    int.parse(semesterController.text.trim()),
                    semesterEndController.text.trim(),
                  );
                  Navigator.of(ctx).pop(true);
                  _refreshData(); // Refresh data setelah simpan
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

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Pengecekan null yang lebih aman
    if (_currentUser == null) {
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

    final isIncomplete =
        (_currentUser!.phone.isEmpty) ||
        (_currentUser!.semester == 0) ||
        (_currentUser!.semesterEnd.isEmpty);

    if (isIncomplete) {
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

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF013237),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      TextSpan(text: '${getGreetingByTime()}, '),
                      TextSpan(
                        text: _currentUser!.name,
                        style: const TextStyle(color: Color(0xFF4CA771)),
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
                  "-MindCourse AI",
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
                          UpcomingDeadlineCard(deadlines: _deadlines),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        UnfinishedTaskCard(
                          jumlahBelumSelesai: _jumlahBelumSelesai,
                        ),
                        const SizedBox(width: 8),
                        FinishedTaskCard(
                          jumlahSelesai: _jumlahSelesai,
                          jumlahBelumSelesai: _jumlahBelumSelesai,
                        ),
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
                                onTap: () => _navigateAndRefresh('/courses'),
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
                                onTap: () => _navigateAndRefresh('/subjects'),
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
  }
}

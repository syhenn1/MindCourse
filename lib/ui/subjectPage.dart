import 'package:MindCourse/models/course.dart';
import 'package:flutter/material.dart';
import 'package:MindCourse/helpers/dbhelper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({Key? key}) : super(key: key);

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  Map<String, dynamic>? _arguments;
  bool _isInitialized = false;
  final DbHelper dbHelper = DbHelper();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      _isInitialized = true;
    }
  }

  void _refreshCourses() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Menampilkan dialog konfirmasi sebelum melakukan aksi
  Future<bool?> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  /// Menampilkan dialog dengan detail lengkap dari sebuah course
  void _showCourseDetailsDialog(Course course) {
    final bool isDone = course.isDone == 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(course.name, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(Icons.description, 'Deskripsi',
                    course.description.isNotEmpty ? course.description : 'Tidak ada deskripsi.'),
                _buildDetailRow(Icons.calendar_today, 'Deadline',
                    '${course.deadlineDay} - ${course.deadlineTime}'),
                _buildDetailRow(Icons.info_outline, 'Status', course.status),
                if (isDone && course.doneDate.isNotEmpty)
                  _buildDetailRow(Icons.check_circle, 'Selesai Pada',
                      DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(course.doneDate))),
              ],
            ),
          ),
          actions: <Widget>[
            // Tombol Hapus
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                final confirmed = await _showConfirmationDialog(
                  context: context,
                  title: 'Konfirmasi Hapus',
                  content: 'Anda yakin ingin menghapus tugas "${course.name}"?',
                );
                if (confirmed == true) {
                  Navigator.of(context).pop(); // Tutup dialog detail
                  await dbHelper.softDeleteCourse(course.courseId!);
                  _refreshCourses();
                  if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('${course.name} telah dihapus.')));
                  }
                }
              },
            ),
            const Spacer(),
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Tombol Tandai Selesai (hanya muncul jika belum selesai)
            if (!isDone)
              ElevatedButton(
                child: const Text('Tandai Selesai'),
                onPressed: () async {
                   final confirmed = await _showConfirmationDialog(
                    context: context,
                    title: 'Konfirmasi Selesai',
                    content: 'Anda yakin ingin menyelesaikan tugas "${course.name}"?',
                  );
                  if (confirmed == true) {
                    Navigator.of(context).pop(); // Tutup dialog detail
                    await dbHelper.markCourseAsDone(course.courseId!);
                    _refreshCourses();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${course.name} ditandai selesai.')));
                    }
                  }
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_arguments == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Text('Gagal memuat data. Argumen tidak ditemukan.'),
        ),
      );
    }

    final String subjectId = _arguments!['subject_id'];
    final String subjectName = _arguments!['name'] ?? 'Tanpa Nama';
    final String subjectDesc =
        _arguments!['description'] ?? 'Tidak ada deskripsi.';
    final String userId = _arguments!['user_id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF013237),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF013237),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    subjectDesc,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFFC0E6BA),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: dbHelper.getCoursesBySubjectId(subjectId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final courses = snapshot.data;
                    if (courses == null || courses.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada tugas/materi.\nTekan tombol + untuk menambahkan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = Course.fromMap(courses[index]);
                        final bool isDone = course.isDone == 1;

                        return Card(
                          color: isDone ? Colors.grey[200] : Colors.white,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(
                              isDone ? Icons.check_circle : Icons.assignment,
                              color: isDone ? Colors.green : Color(0xFF013237),
                            ),
                            title: Text(
                              course.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isDone ? Colors.grey[600] : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                                'Deadline: ${course.deadlineDay} ${course.deadlineTime}'),
                            // --- PERUBAHAN UTAMA: onTap sekarang menampilkan dialog detail ---
                            onTap: () {
                              _showCourseDetailsDialog(course);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showAddCourseDialog(context, userId, subjectId);
          if (result == true) {
            _refreshCourses();
          }
        },
        tooltip: 'Tambah Tugas',
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF013237),
      ),
    );
  }
}

Future<bool?> showAddCourseDialog(
    BuildContext context, String userId, String subjectId) async {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final DbHelper dbHelper = DbHelper();

  DateTime? pickedDate;
  TimeOfDay? pickedTime;

  return await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) {
      return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.add_circle_outline, color: Color(0xFF013237)),
              SizedBox(width: 10),
              Text('Tugas Baru'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Tugas',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi (Opsional)',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: pickedDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(pickedDate!),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Tanggal Deadline',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setDialogState(() {
                          pickedDate = date;
                        });
                      }
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: pickedTime == null
                          ? ''
                          : pickedTime!.format(context),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Waktu Deadline',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setDialogState(() {
                          pickedTime = time;
                        });
                      }
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Batal'),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF013237),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var uuid = Uuid();
                  String newCourseId = uuid.v4();

                  final newCourse = Course(
                    newCourseId,
                    nameController.text.trim(),
                    descriptionController.text.trim(),
                    DateFormat('yyyy-MM-dd').format(pickedDate!),
                    '${pickedTime!.hour.toString().padLeft(2, '0')}:${pickedTime!.minute.toString().padLeft(2, '0')}:00',
                    "Belum Selesai",
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    0,
                    0,
                    "",
                    userId,
                    subjectId,
                  );

                  await dbHelper.insertCourse(newCourse);
                  Navigator.of(ctx).pop(true);
                }
              },
            ),
          ],
        );
      });
    },
  );
}
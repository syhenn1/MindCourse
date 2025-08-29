import 'package:flutter/material.dart';
import '/helpers/dbhelper.dart';
import '/helpers/session_manager.dart';

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final DbHelper dbHelper = DbHelper();
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await SessionManager.getUserId();
    if (mounted) {
      setState(() {
        _userId = userId;
        _isLoading = false;
      });
    }
  }

  void _refreshCourses() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semua Tugas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF013237),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_userId == null) {
      return Center(child: Text('Gagal memuat data pengguna.'));
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF013237),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Tugas Anda',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Lihat semua tugas dari berbagai mata kuliah.',
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
                future: dbHelper.getCoursesByUserId(_userId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Terjadi error saat mengambil data.'));
                  }

                  final courses = snapshot.data;

                  if (courses == null || courses.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada tugas yang terdaftar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final status = course['status'] ?? 'Belum';
                      final isDone = status == 'Selesai';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            isDone ? Icons.check_circle : Icons.assignment,
                            color: isDone ? Colors.green : Color(0xFF013237),
                          ),
                          title: Text(
                            course['name'] ?? 'Tanpa Nama',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (course['description'] != null &&
                                  course['description'].toString().isNotEmpty)
                                Text(course['description']),
                              Text(
                                'Deadline: ${course['deadline_day']} ${course['deadline_time']}',
                              ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              status,
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            backgroundColor: isDone ? Colors.green : Colors.orange,
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          ),
                          onTap: () async {
                            final result = await showCourseDialog(
                              context,
                              course['course_id'],
                            );
                            if (result == true) {
                              _refreshCourses();
                            }
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
    );
  }
}

Future<bool?> showCourseDialog(
  BuildContext context,
  String courseId,
) async {
  final DbHelper dbHelper = DbHelper();
  final course = await dbHelper.getCourseById(
    courseId,
  );

  if (course == null) {
    return null;
  }
  
  final isDone = (course['status'] ?? 'Belum') == 'Selesai';

  return await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Detail Tugas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${course['name']}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Deskripsi: ${course['description'] ?? '-'}'),
            SizedBox(height: 8),
            Text(
              'Deadline: ${course['deadline_day']} ${course['deadline_time']}',
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Status: '),
                Chip(
                  label: Text(
                    course['status'],
                    style: TextStyle(color: Colors.white),
                  ),
                   backgroundColor: isDone ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (!isDone)
          TextButton.icon(
            icon: Icon(Icons.check_circle, color: Colors.green),
            label: Text('Selesai', style: TextStyle(color: Colors.green)),
            onPressed: () async {
              await dbHelper.markCourseAsDone(courseId);
              Navigator.of(ctx).pop(true);
            },
          ),
          TextButton.icon(
            icon: Icon(Icons.delete, color: Colors.red),
            label: Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await dbHelper.softDeleteCourse(courseId);
              Navigator.of(ctx).pop(true);
            },
          ),
        ],
      );
    },
  );
}
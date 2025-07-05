import 'package:MindCourse/components/courses.dart';
import 'package:flutter/material.dart';
import 'package:MindCourse/helpers/dbhelper.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_arguments == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Text('Gagal memuat data subject. Argumen tidak ditemukan.'),
        ),
      );
    }

    final String subjectId = _arguments!['subject_id'];
    final String subjectName = _arguments!['name'] ?? 'Tanpa Nama';
    final String userId = _arguments!['user_id'];

    return Scaffold(
      appBar: AppBar(title: Text(subjectName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: Text(
                  'Konten detail untuk mata kuliah ini akan ditampilkan di sini. $subjectName, $subjectId, $userId',
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              // ✅ Tambahkan ini untuk mencegah unbounded height
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getCoursesBySubjectId(subjectId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('Belum ada course untuk mata kuliah ini.'),
                    );
                  }

                  final courses = snapshot.data!;
                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.class_outlined),
                          title: Text(course['name'] ?? 'Tanpa Nama Course'),
                          subtitle: Text(
                            course['description'] ?? 'Tanpa Deskripsi',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showAddCourseDialog(context, userId, subjectId);

          if (result == true && mounted) {
            setState(() {}); // trigger rebuild
          }
        },
        tooltip: 'Tambah Course',
        child: Icon(Icons.add),
      ),
    );
  }
}

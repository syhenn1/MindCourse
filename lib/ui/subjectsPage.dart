import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '/helpers/dbhelper.dart';
import '/helpers/session_manager.dart';
import '/models/subject.dart';

class SubjectsPage extends StatefulWidget {
  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
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

  void _refreshSubjects() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mata Kuliah', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF013237),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
      floatingActionButton: _userId != null
          ? FloatingActionButton(
              onPressed: () async {
                final result = await showAddSubjectDialog(context, _userId!);
                if (result == true) {
                  _refreshSubjects();
                }
              },
              tooltip: 'Tambah Mata Kuliah',
              child: const Icon(Icons.add),
              backgroundColor: const Color(0xFF013237),
            )
          : null,
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
                  'Mata Kuliah Anda',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola semua mata kuliahmu di semester ini.',
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
                future: dbHelper.getSubjectsByUserId(_userId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Terjadi error saat mengambil data.'));
                  }

                  final subjects = snapshot.data;

                  if (subjects == null || subjects.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada mata kuliah.\nTekan tombol + untuk menambahkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(Icons.school, color: Color(0xFF013237)),
                          title: Text(subject['name'] ?? 'Tanpa Nama',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              subject['description'] != null && subject['description'].isNotEmpty
                                  ? subject['description']
                                  : 'Tidak ada deskripsi'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              await dbHelper
                                  .softDeleteSubject(subject['subject_id']);
                              _refreshSubjects();
                               ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${subject['name']} dihapus.'))
                              );
                            },
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/subject',
                            arguments: {
                              'subject_id': subject['subject_id'],
                              'user_id': subject['user_id'],
                              'description': subject['description'],
                              'date_added': subject['date_added'],
                              'name': subject['name'],
                              'semester': subject['semester'],
                            },
                          ),
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

Future<bool?> showAddSubjectDialog(BuildContext context, String userId) async {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final DbHelper dbHelper = DbHelper();
  final userSemester = await dbHelper.getUserSemester(userId);

  return await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Tambah Mata Kuliah'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama Mata Kuliah'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Deskripsi (Opsional)'),
                ),
                SizedBox(height: 15),
                Text(
                  'Akan ditambahkan ke Semester $userSemester',
                  style: TextStyle(color: Colors.grey[700]),
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
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                var uuid = Uuid();
                String newSubjectId = uuid.v4();
                final name = nameController.text.trim();
                final desc = descriptionController.text.trim();
                final now = DateTime.now().toIso8601String().substring(0, 10);

                final newSubject = Subject(
                  newSubjectId,
                  name,
                  desc,
                  now,
                  0,
                  userId,
                  userSemester,
                  0,
                  '',
                );

                await dbHelper.insertSubject(newSubject);
                Navigator.of(ctx).pop(true);
              }
            },
            child: Text('Simpan'),
          ),
        ],
      );
    },
  );
}
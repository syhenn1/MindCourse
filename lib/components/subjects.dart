import 'package:flutter/material.dart';
import 'package:mindcourse/helpers/dbhelper.dart';
import 'package:mindcourse/helpers/session_manager.dart';
import 'package:mindcourse/models/subject.dart';

Future<List<Widget>> buildSubjectCards(int userId) async {
  final DbHelper dbHelper = DbHelper();
  final subjects = await dbHelper.getSubjectsByUserId(userId);

  if (subjects.isEmpty) {
    return [Text('Belum ada subject.')];
  }

  return subjects.map((subject) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.school),
        title: Text(subject['name'] ?? 'Tanpa Nama'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subject['description'] != null &&
                subject['description'].toString().isNotEmpty)
              Text(subject['description']),
            Text('Semester: ${subject['semester']}'),
            Text('Ditambahkan: ${subject['date_added']}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }).toList();
}

Future<void> showAddSubjectDialog(BuildContext context, int userId) async {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Ambil semester dari session
  final userSemester = await SessionManager.getUserSemester();

  await showDialog(
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
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                ),
                SizedBox(height: 10),
                if (userSemester != null)
                  Text(
                    'Semester Anda: $userSemester',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final name = nameController.text.trim();
                final desc = descriptionController.text.trim();
                final now = DateTime.now().toIso8601String().substring(0, 10);

                // 1. Create a proper Subject instance using its constructor
                final newSubject = Subject(
                  name,
                  desc,
                  now,
                  0, // is_deleted
                  userId,
                  userSemester ?? 0, // semester
                );

                final DbHelper dbHelper = DbHelper();

                // 2. Pass the Subject object to the insert method
                // (This assumes your dbHelper.insertSubject method expects a Subject object)
                await dbHelper.insertSubject(newSubject);

                Navigator.of(ctx).pop();
              }
            },
            child: Text('Simpan'),
          ),
        ],
      );
    },
  );
}

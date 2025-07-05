import 'package:MindCourse/main.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '/helpers/dbhelper.dart';
import '/models/subject.dart';

Future<List<Widget>> buildSubjectCards(
  BuildContext context,
  String userId,
) async {
  final DbHelper dbHelper = DbHelper();
  final subjects = await dbHelper.getSubjectsByUserId(userId);

  if (subjects.isEmpty) {
    return [Text('Belum ada subject.')];
  }

  return subjects.map((subject) {
    return InkWell(
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
      child: Card(
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
              Text('id: ${subject['subject_id']}'),
              Text('Ditambahkan: ${subject['date_added']}'),
              ElevatedButton(
                onPressed: () async {
                  await dbHelper.softDeleteSubject(subject['subject_id']);
                },
                child: Text("Delete"),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }).toList();
}

Future<bool?> showAddSubjectDialog(BuildContext context, String userId) async {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
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
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                ),
                SizedBox(height: 10),
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
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                var uuid = Uuid();
                String newUserId = uuid.v4();
                final name = nameController.text.trim();
                final desc = descriptionController.text.trim();
                final now = DateTime.now().toIso8601String().substring(0, 10);

                final newSubject = Subject(
                  newUserId,
                  name,
                  desc,
                  now,
                  0,
                  userId,
                  userSemester,
                );

                final DbHelper dbHelper = DbHelper();
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

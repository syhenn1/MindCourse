import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '/helpers/dbhelper.dart';
import '/models/course.dart';

Future<List<Widget>> buildCourseCards(String userId) async {
  final DbHelper dbHelper = DbHelper();
  final courses = await dbHelper.getCoursesByUserId(userId);

  if (courses.isEmpty) {
    return [Text('Belum ada course.')];
  }

  return courses.map((course) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(course['name'] ?? 'Tanpa Nama'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course['description'] != null &&
                course['description'].toString().isNotEmpty)
              Text(course['description']),
            Text(
              'Deadline: ${course['deadline_day']} ${course['deadline_time']}',
            ),
            Text('Status: ${course['status']}'),
          ],
        ),
        isThreeLine: true,
        leading: Icon(Icons.book),
      ),
    );
  }).toList();
}

Future<List<Widget>> buildCourseCardsbyId(String subjectId) async {
  final DbHelper dbHelper = DbHelper();
  final courses = await dbHelper.getCoursesBySubjectId(subjectId);

  if (courses.isEmpty) {
    return [Text('Belum ada course.')];
  }

  return courses.map((course) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(course['name'] ?? 'Tanpa Nama'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course['description'] != null &&
                course['description'].toString().isNotEmpty)
              Text(course['description']),
            Text(
              'Deadline: ${course['deadline_day']} ${course['deadline_time']}',
            ),
            Text('Status: ${course['status']}'),
          ],
        ),
        isThreeLine: true,
        leading: Icon(Icons.book),
      ),
    );
  }).toList();
}

Future<bool?> showAddCourseDialog(
  BuildContext context,
  String userId,
  String subjectId,
) async {
  final DbHelper dbHelper = DbHelper();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  return await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Tambah Course / Tugas'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama Course'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Deskripsi'),
                ),
                SizedBox(height: 10),
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? 'Pilih Tanggal Deadline'
                        : 'Deadline: ${selectedDate!.toIso8601String().split("T")[0]}',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      selectedDate = pickedDate;
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    selectedTime == null
                        ? 'Pilih Waktu Deadline'
                        : 'Waktu: ${selectedTime!.format(ctx)}',
                  ),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      selectedTime = pickedTime;
                    }
                  },
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
              if (_formKey.currentState!.validate() &&
                  selectedDate != null &&
                  selectedTime != null) {
                var uuid = Uuid();
                uuid.v4();
                final now = DateTime.now().toIso8601String();

                // Format tanggal: yyyy-MM-dd
                final formattedDate = selectedDate!.toIso8601String().split(
                  'T',
                )[0];

                // Format waktu: HH:mm:ss
                final formattedTime =
                    '${selectedTime!.hour.toString().padLeft(2, '0')}:'
                    '${selectedTime!.minute.toString().padLeft(2, '0')}:00';

                final newCourse = Course(
                  uuid.v4(), // courseId
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                  formattedDate, // yyyy-MM-dd
                  formattedTime, // HH:mm:ss
                  'Belum', // status
                  now, // dateAdded
                  0, // isDeleted
                  0, // isDone
                  userId,
                  subjectId,
                );

                await dbHelper.insertCourse(newCourse);

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

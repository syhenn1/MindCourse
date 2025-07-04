import 'package:flutter/material.dart';
import 'package:mindcourse/helpers/dbhelper.dart';

Future<List<Widget>> buildCourseCards(int userId) async {
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

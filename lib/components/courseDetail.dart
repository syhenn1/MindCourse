import 'package:flutter/material.dart';
import 'package:MindCourse/helpers/dbhelper.dart';

// Enum untuk merepresentasikan aksi yang dipilih pengguna
enum CourseAction { markedAsDone, deleted }

class CourseDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailBottomSheet({Key? key, required this.course})
    : super(key: key);

  // (Letakkan di bawah class CourseDetailBottomSheet)

  @override
  Widget build(BuildContext context) {
    final isDone = (course['status'] ?? 'Belum') == 'Selesai';

    return Padding(
      // Padding untuk memberi ruang di sekitar konten, termasuk area aman di bawah
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Membuat tinggi bottom sheet sesuai konten
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan judul dan handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Text(
            course['name'] ?? 'Detail Tugas',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 12),

          // Konten detail
          _buildDetailRow(
            Icons.description_outlined,
            'Deskripsi',
            course['description'] ?? '-',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Deadline',
            '${course['deadline_day']} ${course['deadline_time']}',
          ),
          const SizedBox(height: 12),

          // Status dengan Chip
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  course['status'] ?? 'Belum',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: isDone ? Colors.green : Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tombol Aksi
          if (!isDone)
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text(
                'Tandai Selesai',
                style: TextStyle(color: Colors.green),
              ),
              onTap: () {
                // Mengirim kembali hasil 'markedAsDone' saat ditutup
                Navigator.pop(context, CourseAction.markedAsDone);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Hapus Tugas',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Mengirim kembali hasil 'deleted' saat ditutup
              Navigator.pop(context, CourseAction.deleted);
            },
          ),
        ],
      ),
    );
  }

  // Helper widget untuk baris detail agar tidak duplikat kode
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(color: Colors.grey[800], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<bool> showCourseDetail(BuildContext context, String courseId) async {
  final DbHelper dbHelper = DbHelper();
  // Ambil data kursus terlebih dahulu
  final course = await dbHelper.getCourseById(courseId);

  if (course == null) {
    // Tampilkan pesan jika data tidak ditemukan
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tugas tidak ditemukan.')));
    return false;
  }

  // Tampilkan bottom sheet dan tunggu hasilnya
  final result = await showModalBottomSheet<CourseAction>(
    context: context,
    isScrollControlled:
        true, // Penting agar bottom sheet tidak tertutup keyboard
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return CourseDetailBottomSheet(course: course);
    },
  );

  // Lakukan aksi berdasarkan hasil dari bottom sheet
  if (result != null) {
    switch (result) {
      case CourseAction.markedAsDone:
        await dbHelper.markCourseAsDone(courseId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas ditandai selesai.'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case CourseAction.deleted:
        await dbHelper.softDeleteCourse(courseId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas telah dihapus.'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
    return true; // Return true jika ada perubahan data
  }

  return false; // Return false jika tidak ada aksi
}

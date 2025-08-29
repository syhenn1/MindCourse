import 'package:flutter/material.dart';
import 'package:MindCourse/helpers/dbhelper.dart';

class UnfinishedTaskCard extends StatefulWidget {
  const UnfinishedTaskCard({super.key});

  @override
  State<UnfinishedTaskCard> createState() => _UnfinishedTaskCardState();
}

class _UnfinishedTaskCardState extends State<UnfinishedTaskCard> {
  int jumlahBelumSelesai = 0;
  int jumlahSelesai = 0;
  int totalTugas = 0;

  @override
  void initState() {
    super.initState();
    _loadJumlahTugas();
  }

  Future<void> _loadJumlahTugas() async {
    final belumSelesai = await DbHelper().getJumlahBelumSelesai();
    final selesai = await DbHelper().getJumlahSelesai();
    final total = belumSelesai + selesai;

    setState(() {
      jumlahBelumSelesai = belumSelesai;
      jumlahSelesai = selesai;
      totalTugas = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    String message;
    Color messageColor = Colors.black;

    if (totalTugas == 0) {
      message = "Belum ada tugasnya nih!";
      messageColor = const Color.fromARGB(255, 255, 255, 255);
    } else if (jumlahBelumSelesai == 0) {
      message = "Horee tugas sudah selesai semua";
      messageColor = Colors.green;
    } else {
      message = "Waduh! $jumlahBelumSelesai tugas belum selesai";
      messageColor = Colors.red;
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF013237),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tugas yang Tersedia",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFamily: "Poppins",
                color: Colors.white,
              ),
            ),
            if (jumlahSelesai > 0)
              Text(
                "$jumlahSelesai tugas selesai",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: messageColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

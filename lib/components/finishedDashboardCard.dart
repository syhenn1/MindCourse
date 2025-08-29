import 'package:flutter/material.dart';
import 'package:MindCourse/helpers/dbhelper.dart';

class FinishedTaskCard extends StatefulWidget {
  const FinishedTaskCard({super.key});

  @override
  State<FinishedTaskCard> createState() => _FinishedTaskCardState();
}

class _FinishedTaskCardState extends State<FinishedTaskCard> {
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
    Color messageColor = Colors.white;

    if (totalTugas == 0) {
      message = "Belum ada tugasnya nih!";
      messageColor = Colors.white;
    } else if (jumlahBelumSelesai == 0) {
      message = "Horee semua tugas sudah selesai!";
      messageColor = Colors.green;
    } else if (jumlahSelesai > 0) {
      message = "Mantap! $jumlahSelesai tugas sudah selesai";
      messageColor = Colors.green;
    } else {
      message = ""; // kalau belum ada yang selesai, biarkan kosong
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
              "Tugas Terselesaikan",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFamily: "Poppins",
                color: Colors.white,
              ),
            ),
            if (jumlahSelesai > 0 && jumlahBelumSelesai > 0)
              Text(
                "$jumlahSelesai tugas selesai",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            const SizedBox(height: 8),
            if (message.isNotEmpty)
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

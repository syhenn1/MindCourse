import 'package:flutter/material.dart';

class FinishedTaskCard extends StatelessWidget {
  final int jumlahSelesai;
  final int jumlahBelumSelesai;

  const FinishedTaskCard({
    super.key,
    required this.jumlahSelesai,
    required this.jumlahBelumSelesai,
  });

  @override
  Widget build(BuildContext context) {
    final int totalTugas = jumlahSelesai + jumlahBelumSelesai;
    String message;
    Color messageColor = Colors.white;

    if (totalTugas == 0) {
      message = "Belum ada tugasnya nih!";
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
          mainAxisAlignment: MainAxisAlignment.center,
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
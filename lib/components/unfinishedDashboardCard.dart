import 'package:flutter/material.dart';

class UnfinishedTaskCard extends StatelessWidget {
  final int jumlahBelumSelesai;

  const UnfinishedTaskCard({super.key, required this.jumlahBelumSelesai});

  @override
  Widget build(BuildContext context) {
    String message;
    Color messageColor;

    if (jumlahBelumSelesai == 0) {
      message = "Kerja bagus! Semua tugas sudah selesai.";
      messageColor = Colors.green;
    } else {
      message = "Waduh! $jumlahBelumSelesai Tugas Belum Selesai";
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tugas Belum Selesai",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFamily: "Poppins",
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
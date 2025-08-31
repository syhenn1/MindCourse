import 'dart:async';
import 'package:flutter/material.dart';

class UpcomingDeadlineCard extends StatefulWidget {
  final List<Map<String, dynamic>> deadlines;
  const UpcomingDeadlineCard({super.key, required this.deadlines});

  @override
  State<UpcomingDeadlineCard> createState() => _UpcomingDeadlineCardState();
}

class _UpcomingDeadlineCardState extends State<UpcomingDeadlineCard> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupCarousel();
  }

  @override
  void didUpdateWidget(UpcomingDeadlineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika data dari parent berubah, setup ulang carousel
    if (widget.deadlines != oldWidget.deadlines) {
      _setupCarousel();
    }
  }

  void _setupCarousel() {
    _timer?.cancel(); // Batalkan timer lama
    if (widget.deadlines.length > 1) {
      _startCarouselTimer();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCarouselTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) return;
      if (_currentPage < widget.deadlines.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Widget _buildDeadlineCard(Map<String, dynamic> row) {
    final deadlineDay = row['deadline_day'];
    final deadlineTime = row['deadline_time'];
    final deadline = DateTime.parse("$deadlineDay $deadlineTime");
    final diff = deadline.difference(DateTime.now());

    String sisaWaktu;
    if (diff.isNegative) {
      sisaWaktu = "Deadline terlewat";
    } else {
      sisaWaktu = "${diff.inHours} jam ${diff.inMinutes.remainder(60)} menit lagi";
    }

    return Card(
      color: Colors.redAccent.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const Icon(Icons.timer, color: Colors.white),
        title: Text(
          row['name'] ?? 'Tanpa Nama',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          "Deadline: $deadlineDay $deadlineTime\nSisa waktu: $sisaWaktu",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deadlines.isEmpty) {
      return Card(
        color: const Color(0xFFDD78FF).withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const ListTile(
          leading: Icon(Icons.celebration, color: Colors.white),
          title: Text(
            "Horeee! Tidak ada tugas yang perlu dikerjakan.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(221, 255, 255, 255),
            ),
          ),
        ),
      );
    }
    
    if (widget.deadlines.length > 1) {
      return SizedBox(
        height: 95,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.deadlines.length,
          itemBuilder: (context, index) {
            return _buildDeadlineCard(widget.deadlines[index]);
          },
        ),
      );
    }
    
    return _buildDeadlineCard(widget.deadlines.first);
  }
}
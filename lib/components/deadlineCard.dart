import 'dart:async';
import 'package:MindCourse/helpers/dbhelper.dart';
import 'package:flutter/material.dart';

class UpcomingDeadlineCard extends StatefulWidget {
  const UpcomingDeadlineCard({super.key});

  @override
  State<UpcomingDeadlineCard> createState() => _UpcomingDeadlineCardState();
}

class _UpcomingDeadlineCardState extends State<UpcomingDeadlineCard> {
  final DbHelper dbHelper = DbHelper();
  List<Map<String, dynamic>> _deadlines = [];
  bool _hasError = false;
  bool _isLoading = true;

  // Controller and Timer for Carousel
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadDeadlines();
  }

  @override
  void dispose() {
    // Clean up the controller and timer to prevent memory leaks
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCarouselTimer() {
    // Start a periodic timer to auto-scroll the PageView
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (Timer timer) {
      if (_currentPage < _deadlines.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first page
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 3000),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> _loadDeadlines() async {
    try {
      final data = await dbHelper.getUpcomingDeadlines();
      if (!mounted) return;

      setState(() {
        _deadlines = data;
        _hasError = false;
        _isLoading = false;
      });

      // Start the carousel only if there are 2 or more items
      if (_deadlines.length > 1) {
        _startCarouselTimer();
      }
    } catch (e) {
      debugPrint("ERROR FETCH DEADLINES: $e");
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // Helper widget to build a single deadline card
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Card(
        color: Colors.red.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const ListTile(
          leading: Icon(Icons.error, color: Colors.white),
          title: Text(
            "Terjadi kesalahan.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (_deadlines.isEmpty) {
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

    // If there is more than one deadline, build a carousel
    if (_deadlines.length > 1) {
      return SizedBox(
        height: 95, // Constrain the height of the PageView
        child: PageView.builder(
          controller: _pageController,
          itemCount: _deadlines.length,
          itemBuilder: (context, index) {
            // Build each card inside the PageView
            return _buildDeadlineCard(_deadlines[index]);
          },
        ),
      );
    }

    // If there is only one deadline, show a single static card
    return _buildDeadlineCard(_deadlines.first);
  }
}
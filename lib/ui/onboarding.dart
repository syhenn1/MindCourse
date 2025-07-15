import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'titleParts': [
        {'text': 'Mind', 'color': const Color(0xFF4CA770)},
        {'text': 'Course', 'color': const Color(0xFF013237)},
      ],
      'description':
          'Rekan tugasmu yang akan selalu mengingatkanmu kapanpun dan dimanapun dirimu berada!',
      'icon': 'assets/images/mindcourse-4CA771.png',
      'lottiePath': null,
      'imagePath': 'assets/images/onboard-pict1.png',
      'team': null,
    },
    {
      'titleParts': [
        {'text': 'Harus ', 'color': const Color(0xFF013237)},
        {'text': 'Tepat\n', 'color': const Color(0xFF4CA770)},
        {'text': 'Waktu', 'color': const Color(0xFF013237)},
      ],
      'description':
          'Aplikasi ini disesuaikan dengan berbagai fitur yang dapat membantu anda agar tidak ketinggalan tugas serta deadlinenya!',
      'icon': 'assets/images/clock.png',
      'lottiePath': null,
      'imagePath': 'assets/images/onboard-pict2.png',
      'team': null,
    },
    {
      'titleParts': [
        {'text': 'Privasi Sudah\n', 'color': const Color(0xFF013237)},
        {'text': 'Pasti Aman', 'color': const Color(0xFF4CA770)},
        {'text': '!', 'color': const Color(0xFF013237)},
      ],
      'description':
          'Semua data tersimpan secara lokal di perangkat Anda, tanpa internet, tanpa cloud, dan tanpa perlu login. Privasi Anda adalah prioritas utama.',
      'icon': 'assets/images/privacy.png',
      'lottiePath': null,
      'imagePath': 'assets/images/onboard-pict3.png',
      'team': null,
    },
    {
      'titleParts': [
        {'text': 'Fokus pada\n', 'color': const Color(0xFF013237)},
        {'text': 'Produktivitas', 'color': const Color(0xFF4CA770)},
      ],
      'description':
          'Buat daftar tugas, atur pengingat, dan selesaikan satu per satu. MindCourse membantu Anda menyusun prioritas harian agar lebih terorganisir.',
      'icon': 'assets/images/productivity.png',
      'lottiePath': null,
      'imagePath': 'assets/images/onboard-pict4.png',
      'team': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set immersive fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // Status bar teks putih
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background Image dengan Transisi Fade
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: LayoutBuilder(
                  key: ValueKey<String>(
                    _onboardingData[_currentPage]['imagePath'],
                  ),
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: Image.asset(
                        _onboardingData[_currentPage]['imagePath'],
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Overlay Gradasi
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ),

            // Konten Halaman
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _onboardingData.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final data = _onboardingData[index];
                        return OnboardingSlide(
                          icon: data['icon'],
                          imagePath: data['imagePath'],
                          lottiePath: data['lottiePath'],
                          titleParts: data['titleParts'],
                          description: data['description'],
                          team: data['team'],
                        );
                      },
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => buildDot(index),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24, // left
                      16, // top
                      24, // right
                      24, // bottom
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage == _onboardingData.length - 1) {
                                _completeOnboarding();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ),
                              backgroundColor: const Color(0xFF013237),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              _currentPage == _onboardingData.length - 1
                                  ? 'Masuk'
                                  : 'Selanjutnya',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: Opacity(
                            opacity: _currentPage > 0 ? 1.0 : 0.0,
                            child: ElevatedButton(
                              onPressed: _currentPage > 0
                                  ? () => _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeInOut,
                                    )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  76,
                                  167,
                                  112,
                                  0.5,
                                ),
                                foregroundColor: const Color(0xFF013237),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: const Color.fromARGB(55, 1, 50, 55),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Kembali'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      height: 10,
      width: _currentPage == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index
            ? const Color(0xFF013237)
            : const Color(0xFFEAF9E7),
      ),
    );
  }
}

// ... OnboardingSlide dan TeamMemberBubble tetap seperti sebelumnya ...

class OnboardingSlide extends StatelessWidget {
  final String? icon;
  final String? imagePath;
  final String? lottiePath;
  final List<Map<String, dynamic>>? titleParts;
  final String? description;
  final List<Map<String, String>>? team;

  const OnboardingSlide({
    super.key,
    this.icon,
    this.imagePath,
    this.lottiePath,
    required this.titleParts,
    this.description,
    this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (lottiePath != null) Center(child: Text("Lottie Placeholder")),
          if (titleParts != null)
            RichText(
              text: TextSpan(
                children: titleParts!
                    .map(
                      (part) => TextSpan(
                        text: part['text'],
                        style: TextStyle(
                          color: part['color'],
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 25),
          if (icon != null)
            Center(
              child: Image.asset(
                icon!,
                width: MediaQuery.of(context).size.width * 0.65,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 25),
          if (description != null)
            Text(
              description!,
              style: const TextStyle(
                fontSize: 20,
                color: const Color(0xFF013237),
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (team != null)
            Center(
              child: Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                alignment: WrapAlignment.center,
                children: team!
                    .map(
                      (member) => TeamMemberBubble(
                        name: member['name']!,
                        imageUrl: member['image']!,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class TeamMemberBubble extends StatelessWidget {
  final String name;
  final String imageUrl;

  const TeamMemberBubble({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white24,
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

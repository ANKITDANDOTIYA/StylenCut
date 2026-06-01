import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_flow/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Find Salons Nearby',
      'subtitle':
          'Enable location access to see barbershops and real-time availability in your area.',
      'icon': 'location_on',
    },
    {
      'title': 'Real-time Availability',
      'subtitle':
          'See exactly who is free right now and book your spot in seconds. No more waiting in line.',
      'icon': 'schedule',
    },
    {
      'title': 'Ready for a Fresh Cut?',
      'subtitle':
          'Join the BarberFlow community and experience the future of barber booking. Your style, simplified.',
      'icon': 'content_cut',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  IconData _getIcon(String iconString) {
    switch (iconString) {
      case 'location_on':
        return Icons.location_on;
      case 'schedule':
        return Icons.schedule;
      case 'content_cut':
        return Icons.content_cut;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Top App Bar area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BarberFlow',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      if (_currentPage < _onboardingData.length - 1)
                        TextButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              _onboardingData.length - 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Skip',
                            style: GoogleFonts.poppins(
                              color: subtitleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (_currentPage == _onboardingData.length - 1)
                        const SizedBox(height: 48), // Spacer to match height
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIcon(_onboardingData[index]['icon']!),
                                  size: 80,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 48),
                              Text(
                                _onboardingData[index]['title']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _onboardingData[index]['subtitle']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: subtitleColor,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation Area
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? primaryColor
                                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _nextPage,
                          child: Text(
                            _currentPage == _onboardingData.length - 1
                                ? 'Get Started'
                                : 'Continue',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Optional Sign In Text on last page
                      if (_currentPage == _onboardingData.length - 1) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.poppins(
                                color: subtitleColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to Login
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.poppins(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

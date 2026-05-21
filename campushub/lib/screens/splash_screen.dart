import 'package:flutter/material.dart';
import 'login_screen.dart';

class CampusHubIntroScreen extends StatefulWidget {
  const CampusHubIntroScreen({super.key});

  static const Color primaryNavy = Color(0xFF142B47);
  static const Color secondaryLightBlue = Color(0xFF8BA6D5);

  @override
  State<CampusHubIntroScreen> createState() => _CampusHubIntroScreenState();
}

class _CampusHubIntroScreenState extends State<CampusHubIntroScreen> {
  bool _isNavigating = false;

  void _openLogin() {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    ).then((_) {
      if (!mounted) return;
      setState(() => _isNavigating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Campus',
                              style: TextStyle(
                                color: CampusHubIntroScreen.primaryNavy,
                              ),
                            ),
                            TextSpan(
                              text: 'Hub',
                              style: TextStyle(color: Color(0xFF1A56DB)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Everything Campus,\nAll in One Place.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 5,
                    child: Image.asset(
                      'assets/img/illustration.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _openLogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 21, 84, 194),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

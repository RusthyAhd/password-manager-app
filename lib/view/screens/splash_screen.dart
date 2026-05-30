import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_vault/view/widgets/glassmorphism_card.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.autoNavigate = true});

  final bool autoNavigate;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Ensure status bar icons are light on dark background
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );

    // Navigate to login after 5 seconds
    if (widget.autoNavigate) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF595959);
    const accentBlue = Color(0xFF0088FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main centered content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo: prefer asset image, fall back to a stylized widget
                  Image.asset(
                    'assets/logo.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 22),

                  // Title: "SECURE VAULT" with different colors
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'SECURE ',
                          style: TextStyle(
                            color: accentBlue,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const TextSpan(
                          text: 'VAULT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom caption
            Positioned(
              left: 0,
              right: 0,
              bottom: 36,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GlassmorphismCard(
                      icon: Icons.verified_user,
                      title: 'Premium Security',
                      description: 'FOR BETTER MANAGE',
                      borderRadius: 16,
                      padding: const EdgeInsets.all(14),
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFF0088FF), Color(0xFF4DB8FF)],
                      ),
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
}

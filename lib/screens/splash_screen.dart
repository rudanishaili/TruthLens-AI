import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController nameController;
  late AnimationController lineController;

  late Animation<double> nameScale;
  late Animation<double> nameOpacity;
  late Animation<Offset> lineSlide;
  late Animation<double> lineOpacity;

  @override
  void initState() {
    super.initState();

    nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    nameScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: nameController, curve: Curves.elasticOut),
    );

    nameOpacity = Tween<double>(begin: 0, end: 1).animate(nameController);

    lineSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: lineController, curve: Curves.easeOut),
    );

    lineOpacity = Tween<double>(begin: 0, end: 1).animate(lineController);

    nameController.forward();

    Future.delayed(const Duration(milliseconds: 900), () {
      lineController.forward();
    });

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              Color(0xff155E75),
              Color(0xff0F172A),
              Color(0xff020617),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              left: -70,
              child: _glowCircle(220, Colors.cyanAccent.withOpacity(0.15)),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: _glowCircle(260, Colors.blueAccent.withOpacity(0.18)),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: nameOpacity,
                    child: ScaleTransition(
                      scale: nameScale,
                      child: const Text(
                        "TruthLens",
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  FadeTransition(
                    opacity: lineOpacity,
                    child: SlideTransition(
                      position: lineSlide,
                      child: const Text(
                        "Making News Easier To Trust",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                        ),
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

  Widget _glowCircle(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 70,
          ),
        ],
      ),
    );
  }
}
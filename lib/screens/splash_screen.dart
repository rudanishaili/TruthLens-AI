import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController mainController;
  late AnimationController glowController;
  late AnimationController particleController;

  late Animation<double> nameScale;
  late Animation<double> nameOpacity;
  late Animation<Offset> tagSlide;
  late Animation<double> tagOpacity;

  @override
  void initState() {
    super.initState();

    mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    nameScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: Curves.easeOutBack),
    );

    nameOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: mainController, curve: const Interval(0.0, 0.7)),
    );

    tagSlide = Tween<Offset>(
      begin: const Offset(0, 0.55),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: mainController, curve: const Interval(0.45, 1.0)),
    );

    tagOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: mainController, curve: const Interval(0.45, 1.0)),
    );

    mainController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, animation, __) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    mainController.dispose();
    glowController.dispose();
    particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
      body: AnimatedBuilder(
        animation: Listenable.merge([glowController, particleController]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
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
                  top: -100 + glowController.value * 25,
                  left: -90,
                  child: _glowCircle(240, Colors.cyanAccent.withOpacity(0.14)),
                ),
                Positioned(
                  bottom: -130,
                  right: -90 + glowController.value * 30,
                  child: _glowCircle(290, Colors.blueAccent.withOpacity(0.16)),
                ),

                ...List.generate(18, (index) {
                  final angle =
                      (particleController.value * 2 * pi) + (index * 0.7);
                  final x = cos(angle) * (40 + index * 8);
                  final y = sin(angle) * (25 + index * 5);

                  return Positioned(
                    left: MediaQuery.of(context).size.width / 2 + x,
                    top: MediaQuery.of(context).size.height / 2 + y + 120,
                    child: Container(
                      height: 3,
                      width: 3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.cyanAccent.withOpacity(0.35),
                      ),
                    ),
                  );
                }),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: nameScale,
                        child: FadeTransition(
                          opacity: nameOpacity,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.cyanAccent.withOpacity(0.10),
                                  border: Border.all(
                                    color: Colors.cyanAccent.withOpacity(0.35),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(
                                        0.25 + glowController.value * 0.20,
                                      ),
                                      blurRadius: 45,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shield_rounded,
                                  color: Colors.cyanAccent,
                                  size: 54,
                                ),
                              ),

                              const SizedBox(height: 28),

                              const Text(
                                "TruthLens",
                                style: TextStyle(
                                  fontSize: 54,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      FadeTransition(
                        opacity: tagOpacity,
                        child: SlideTransition(
                          position: tagSlide,
                          child: const Text(
                            "Making News Easier To Trust",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 45),

                      FadeTransition(
                        opacity: tagOpacity,
                        child: SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            color: Colors.cyanAccent,
                            backgroundColor: Colors.white12,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
            blurRadius: 120,
            spreadRadius: 70,
          ),
        ],
      ),
    );
  }
}
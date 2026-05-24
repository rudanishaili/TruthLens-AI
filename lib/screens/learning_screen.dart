import 'dart:ui';
import 'package:flutter/material.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController glowController;

  int selectedQuiz = -1;
  bool quizAnswered = false;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroCard(),
                        const SizedBox(height: 18),
                        _lessonCard(
                          icon: Icons.warning_amber_rounded,
                          title: "What is fake news?",
                          color: Colors.orangeAccent,
                          points: const [
                            "Fake news is false or misleading information presented like real news.",
                            "It is often designed to create fear, anger, confusion, or quick sharing.",
                            "Not every wrong post is fake news; sometimes it is outdated, biased, or missing context.",
                          ],
                        ),
                        const SizedBox(height: 16),
                        _lessonCard(
                          icon: Icons.flag_rounded,
                          title: "Common red flags",
                          color: Colors.redAccent,
                          points: const [
                            "No clear source, author, date, or official reference.",
                            "Very emotional words like SHOCKING, URGENT, SECRET, EXPOSED.",
                            "Claims that sound extreme, magical, or too perfect to be true.",
                            "Messages asking you to forward/share immediately.",
                            "Screenshots without original links or trusted publisher names.",
                          ],
                        ),
                        const SizedBox(height: 16),
                        _lessonCard(
                          icon: Icons.psychology_rounded,
                          title: "Manipulation tricks",
                          color: Colors.cyanAccent,
                          points: const [
                            "Fear: making you panic before thinking.",
                            "Anger: blaming a group/person without proof.",
                            "Authority fakeout: using fake doctors, fake experts, or fake official logos.",
                            "Cherry-picking: showing only one side of the story.",
                            "Old news reuse: resharing old events as if they happened today.",
                          ],
                        ),
                        const SizedBox(height: 16),
                        _lessonCard(
                          icon: Icons.verified_rounded,
                          title: "How to verify news",
                          color: Colors.greenAccent,
                          points: const [
                            "Search the same claim on multiple trusted news sources.",
                            "Check official websites for government, exam, health, or finance updates.",
                            "Check the date carefully.",
                            "Avoid trusting only screenshots or forwarded messages.",
                            "Do not share until you can confirm the source.",
                          ],
                        ),
                        const SizedBox(height: 16),
                        _quizCard(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff020617),
                    Color(0xff0F172A),
                    Color(0xff063344),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: -100 + glowController.value * 25,
              right: -80,
              child: _glowCircle(250, Colors.cyanAccent.withOpacity(0.12)),
            ),
            Positioned(
              bottom: -120,
              left: -90 + glowController.value * 35,
              child: _glowCircle(280, Colors.blueAccent.withOpacity(0.12)),
            ),
          ],
        );
      },
    );
  }

  Widget _topBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.075),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.10)),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: _smallIcon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Learning Mode",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Become smarter than misinformation",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              _smallIcon(Icons.school_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return _glassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.25)),
            ),
            child: const Text(
              "NEWS LITERACY",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Learn how fake news tricks people.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "TruthLens does not only analyze news — it teaches you how to think before trusting or sharing information.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lessonCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> points,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)),
            child: _glassBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...points.map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: color,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _quizCard() {
    final options = [
      "It has many exclamation marks and says forward immediately",
      "It mentions date, source, and official reference",
      "It is reported by multiple trusted sources",
    ];

    final correctIndex = 0;

    return _glassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.quiz_rounded, color: Colors.cyanAccent),
              SizedBox(width: 10),
              Text(
                "Mini Quiz",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "Which one is the biggest fake-news warning sign?",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(options.length, (index) {
            final isSelected = selectedQuiz == index;
            final isCorrect = index == correctIndex;

            Color borderColor = Colors.white.withOpacity(0.10);
            Color bgColor = Colors.white.withOpacity(0.06);

            if (quizAnswered && isSelected && isCorrect) {
              borderColor = Colors.greenAccent;
              bgColor = Colors.greenAccent.withOpacity(0.12);
            } else if (quizAnswered && isSelected && !isCorrect) {
              borderColor = Colors.redAccent;
              bgColor = Colors.redAccent.withOpacity(0.12);
            } else if (isSelected) {
              borderColor = Colors.cyanAccent;
              bgColor = Colors.cyanAccent.withOpacity(0.10);
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedQuiz = index;
                  quizAnswered = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      quizAnswered && isSelected
                          ? (isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded)
                          : Icons.radio_button_unchecked_rounded,
                      color: quizAnswered && isSelected
                          ? (isCorrect ? Colors.greenAccent : Colors.redAccent)
                          : Colors.white54,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        options[index],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (quizAnswered) ...[
            const SizedBox(height: 8),
            Text(
              selectedQuiz == correctIndex
                  ? "Correct ✅ Urgent forwarding is a classic misinformation pattern."
                  : "Not quite. The biggest warning is content pressuring you to forward immediately.",
              style: TextStyle(
                color: selectedQuiz == correctIndex
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _glassBox({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.075),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.06),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _smallIcon(IconData icon) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Icon(icon, color: Colors.cyanAccent),
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

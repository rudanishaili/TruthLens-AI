import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final newsController = TextEditingController();

  bool isLoading = false;
  Map<String, dynamic>? result;

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  Future<void> analyzeNews() async {
    String news = newsController.text.trim();

    if (news.isEmpty) {
      showMessage("Please paste some news text first");
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      final aiResult = await GeminiService.analyzeNews(news);

      setState(() {
        result = aiResult;
      });
    } catch (e) {
      print(e);
      showMessage("AI limit reached or error occurred. Try again later.");
    }

    setState(() {
      isLoading = false;
    });
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xff0F172A),
        content: Text(msg),
      ),
    );
  }

  Color getRiskColor(String verdict) {
    String value = verdict.toLowerCase();

    if (value.contains("fake")) {
      return Colors.redAccent;
    } else if (value.contains("doubtful")) {
      return Colors.orangeAccent;
    } else {
      return Colors.greenAccent;
    }
  }

  IconData getRiskIcon(String verdict) {
    String value = verdict.toLowerCase();

    if (value.contains("fake")) {
      return Icons.warning_amber_rounded;
    } else if (value.contains("doubtful")) {
      return Icons.help_outline_rounded;
    } else {
      return Icons.verified_rounded;
    }
  }

  @override
  void dispose() {
    newsController.dispose();
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verdict = result?["verdict"]?.toString() ?? "";
    final trustScore = int.tryParse(result?["trust_score"]?.toString() ?? "0") ?? 0;
    final redFlags = result?["red_flags"] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xff020617),
      body: Stack(
        children: [
          _background(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),

                  const SizedBox(height: 26),

                  _heroCard(),

                  const SizedBox(height: 24),

                  _inputCard(),

                  const SizedBox(height: 18),

                  _analyzeButton(),

                  if (isLoading) ...[
                    const SizedBox(height: 28),
                    _loadingCard(),
                  ],

                  if (result != null) ...[
                    const SizedBox(height: 28),
                    _resultHeader(verdict, trustScore),
                    const SizedBox(height: 18),
                    _infoCard(
                      icon: Icons.article_rounded,
                      title: "Simple Explanation",
                      text: result?["simple_explanation"] ?? "",
                    ),
                    const SizedBox(height: 16),
                    _redFlagsCard(redFlags),
                    const SizedBox(height: 16),
                    _infoCard(
                      icon: Icons.psychology_rounded,
                      title: "AI Reasoning",
                      text: result?["ai_reasoning"] ?? "",
                    ),
                    const SizedBox(height: 16),
                    _infoCard(
                      icon: Icons.gavel_rounded,
                      title: "Final Decision",
                      text: result?["final_decision"] ?? "",
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
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
                    Color(0xff062A3A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            Positioned(
              top: -100 + glowController.value * 35,
              right: -90,
              child: _blurCircle(250, Colors.cyanAccent.withOpacity(0.18)),
            ),

            Positioned(
              bottom: -130,
              left: -100 + glowController.value * 45,
              child: _blurCircle(300, Colors.blueAccent.withOpacity(0.15)),
            ),

            Positioned(
              top: 300,
              left: 40,
              child: _blurCircle(120, Colors.tealAccent.withOpacity(0.08)),
            ),
          ],
        );
      },
    );
  }

  Widget _blurCircle(double size, Color color) {
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
            spreadRadius: 60,
          ),
        ],
      ),
    );
  }

  Widget _glassBox({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.075),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
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

  Widget _topBar() {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Colors.cyanAccent,
                Color(0xff38BDF8),
              ],
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.black,
            size: 28,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TruthLens",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                "Hello, ${widget.userName}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: const Icon(
            Icons.history_rounded,
            color: Colors.cyanAccent,
          ),
        ),
      ],
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
              "AI NEWS INTELLIGENCE",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "Analyze news before you trust it.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Paste any headline, article, or forwarded message. TruthLens will simplify it, detect red flags, and give an AI-based trust verdict.",
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

  Widget _inputCard() {
    return _glassBox(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: Colors.cyanAccent),
                SizedBox(width: 10),
                Text(
                  "Paste News Content",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          TextField(
            controller: newsController,
            maxLines: 10,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              height: 1.45,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(18),
              hintText:
                  "Example: Breaking news, WhatsApp forward, article paragraph, tweet, or headline...",
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _analyzeButton() {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        return Container(
          height: 58,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(
                  isLoading ? 0.1 : 0.25 + glowController.value * 0.18,
                ),
                blurRadius: 28,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : analyzeNews,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.cyanAccent.withOpacity(0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded),
                      SizedBox(width: 10),
                      Text(
                        "Analyze With AI",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _loadingCard() {
    return _glassBox(
      child: Column(
        children: [
          const Text(
            "TruthLens is analyzing...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Checking wording, claim quality, source clarity, and misinformation patterns.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          LinearProgressIndicator(
            color: Colors.cyanAccent,
            backgroundColor: Colors.white.withOpacity(0.08),
            minHeight: 7,
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
    );
  }

  Widget _resultHeader(String verdict, int trustScore) {
    final color = getRiskColor(verdict);

    return _glassBox(
      child: Row(
        children: [
          Container(
            height: 78,
            width: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.7), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Icon(
              getRiskIcon(verdict),
              color: color,
              size: 42,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verdict,
                  style: TextStyle(
                    color: color,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Trust Score: $trustScore%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: LinearProgressIndicator(
                    value: trustScore / 100,
                    minHeight: 8,
                    color: color,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return _glassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            text.toString(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _redFlagsCard(dynamic redFlags) {
    List flags = [];

    if (redFlags is List) {
      flags = redFlags;
    }

    return _glassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_rounded, color: Colors.orangeAccent),
              SizedBox(width: 10),
              Text(
                "Red Flags Found",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (flags.isEmpty)
            const Text(
              "No major red flags found.",
              style: TextStyle(color: Colors.white70),
            )
          else
            ...flags.map(
              (flag) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.orangeAccent.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "⚠ ",
                      style: TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        flag.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.4,
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
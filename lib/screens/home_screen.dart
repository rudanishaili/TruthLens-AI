import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/history_model.dart';
import '../services/fallback_analyzer.dart';
import '../services/gemini_service.dart';
import '../services/history_service.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'learning_screen.dart';

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
  final urlController = TextEditingController();

  bool isLoading = false;
  bool isListening = false;
  Map<String, dynamic>? result;

  late AnimationController glowController;
  Timer? loadingTimer;
  int loadingIndex = 0;

  final stt.SpeechToText speech = stt.SpeechToText();

  final List<String> loadingMessages = [
    "Reading news content...",
    "Detecting suspicious wording...",
    "Checking misinformation patterns...",
    "Calculating trust score...",
    "Generating final verdict...",
  ];

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  void startLoadingMessages() {
    loadingTimer?.cancel();
    loadingIndex = 0;

    loadingTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;

      setState(() {
        loadingIndex = (loadingIndex + 1) % loadingMessages.length;
      });
    });
  }

Widget _chatButton() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 650),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - value)),
          child: GestureDetector(
            onTap: result == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 600),
                        pageBuilder: (_, animation, __) => ChatScreen(
                          newsText: newsController.text.trim(),
                          analysisResult: result!,
                        ),
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
                  },
            child: AnimatedBuilder(
              animation: glowController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff67E8F9),
                        Colors.cyanAccent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(
                          0.25 + glowController.value * 0.18,
                        ),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.black,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Chat About This News",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

  void stopLoadingMessages() {
    loadingTimer?.cancel();
  }

  Future<void> analyzeNews() async {
    String news = newsController.text.trim();

    if (news.isEmpty) {
      showMessage("Please paste, extract, or speak some news text first");
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
    });

    startLoadingMessages();

    try {
      await Future.delayed(const Duration(seconds: 2));

      final aiResult = await GeminiService.analyzeNews(news);
      aiResult["analysis_type"] = "Gemini AI Analysis";

      setState(() {
        result = aiResult;
      });

      await saveToHistory(news, aiResult);
    } catch (e) {
      print(e);

      final fallbackResult = FallbackAnalyzer.analyze(news);

      setState(() {
        result = fallbackResult;
      });

      await saveToHistory(news, fallbackResult);

      showMessage("Gemini limit reached. Showing backup TruthLens analysis.");
    }

    stopLoadingMessages();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveToHistory(String news, Map<String, dynamic> data) async {
    await HistoryService.saveHistory(
      HistoryModel(
        news: news,
        verdict: data["verdict"] ?? "Unknown",
        trustScore: int.tryParse(data["trust_score"].toString()) ?? 0,
        time: DateTime.now().toString(),
      ),
    );
  }

  Future<void> pickAndReadScreenshot() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    setState(() {
      isLoading = true;
      result = null;
    });

    try {
      final inputImage = InputImage.fromFile(File(image.path));

      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      String extractedText = recognizedText.text.trim();

      if (extractedText.isEmpty) {
        showMessage("No readable text found in this screenshot");
      } else {
        newsController.text = extractedText;
        showMessage("Screenshot text extracted successfully");
      }
    } catch (e) {
      print(e);
      showMessage("Could not read text from screenshot");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchNewsFromUrl() async {
    final url = urlController.text.trim();

    if (url.isEmpty) {
      showMessage("Please enter a news URL first");
      return;
    }

    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      showMessage("Please enter a valid URL starting with http or https");
      return;
    }

    setState(() {
      isLoading = true;
      result = null;
    });

    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 12),
          );

      if (response.statusCode != 200) {
        showMessage("Could not open this URL");
      } else {
        final document = html_parser.parse(response.body);

        document.querySelectorAll("script, style, nav, footer, header").forEach(
              (element) => element.remove(),
            );

        final title = document.querySelector("title")?.text.trim() ?? "";
        final paragraphs = document
            .querySelectorAll("p")
            .map((p) => p.text.trim())
            .where((text) => text.length > 40)
            .take(12)
            .join("\n\n");

        final extractedText = "$title\n\n$paragraphs".trim();

        if (extractedText.length < 80) {
          showMessage("Could not extract enough article text from this URL");
        } else {
          newsController.text = extractedText;
          showMessage("Article text extracted from URL");
        }
      }
    } catch (e) {
      print(e);
      showMessage("URL extraction failed. Try another link.");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> startVoiceInput() async {
    if (isListening) {
      await speech.stop();
      setState(() {
        isListening = false;
      });
      return;
    }

    final available = await speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          if (mounted) {
            setState(() {
              isListening = false;
            });
          }
        }
      },
      onError: (error) {
        showMessage("Voice input error. Try again.");
        if (mounted) {
          setState(() {
            isListening = false;
          });
        }
      },
    );

    if (!available) {
      showMessage("Speech recognition is not available on this device");
      return;
    }

    setState(() {
      isListening = true;
    });

    await speech.listen(
      listenFor: const Duration(seconds: 40),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      onResult: (result) {
        setState(() {
          newsController.text = result.recognizedWords;
          newsController.selection = TextSelection.fromPosition(
            TextPosition(offset: newsController.text.length),
          );
        });
      },
    );
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
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

    if (value.contains("invalid")) {
      return Colors.grey;
    } else if (value.contains("fake")) {
      return Colors.redAccent;
    } else if (value.contains("doubtful")) {
      return Colors.orangeAccent;
    } else {
      return Colors.greenAccent;
    }
  }

  IconData getRiskIcon(String verdict) {
    String value = verdict.toLowerCase();

    if (value.contains("invalid")) {
      return Icons.error_outline_rounded;
    } else if (value.contains("fake")) {
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
    urlController.dispose();
    glowController.dispose();
    loadingTimer?.cancel();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verdict = result?["verdict"]?.toString() ?? "";
    final trustScore =
        int.tryParse(result?["trust_score"]?.toString() ?? "0") ?? 0;
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
                  const SizedBox(height: 16),
                  _learningButton(),
                  const SizedBox(height: 24),
                  _inputCard(),
                  const SizedBox(height: 14),
                  _toolsGrid(),
                  const SizedBox(height: 14),
                  _urlCard(),
                  const SizedBox(height: 18),
                  _analyzeButton(),
                  if (isLoading) ...[
                    const SizedBox(height: 28),
                    _loadingCard(),
                  ],
                  if (result != null) ...[
                    const SizedBox(height: 28),
                    _animatedResult(
                      child: Column(
                        children: [
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
                          const SizedBox(height: 18),
                          _chatButton(),
                        ],
                      ),
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
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HistoryScreen(),
              ),
            );
          },
          child: _topIcon(Icons.history_rounded),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: logoutUser,
          child: _topIcon(Icons.logout_rounded),
        ),
      ],
    );
  }

  Widget _topIcon(IconData icon) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: Icon(
        icon,
        color: Colors.cyanAccent,
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
            "Paste text, extract it from screenshots, fetch from URLs, or speak it directly. TruthLens detects red flags and gives a trust verdict.",
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


  Widget _learningButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (_, animation, __) => const LearningScreen(),
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
              },
              child: AnimatedBuilder(
                animation: glowController,
                builder: (context, child) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white.withOpacity(0.075),
                      border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(
                            0.07 + glowController.value * 0.06,
                          ),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          color: Colors.cyanAccent,
                          size: 28,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AI News Learning Mode",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Learn fake-news red flags, clickbait tricks, and verification steps.",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white54,
                          size: 18,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
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
                  "News Content",
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
            maxLines: 7,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              height: 1.45,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(18),
              hintText:
                  "Paste news, extract from screenshot, fetch from URL, or use voice input...",
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolsGrid() {
    return Row(
      children: [
        Expanded(
          child: _toolButton(
            icon: Icons.image_search_rounded,
            label: "Screenshot",
            onTap: isLoading ? null : pickAndReadScreenshot,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _toolButton(
            icon: isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
            label: isListening ? "Listening..." : "Voice",
            onTap: isLoading ? null : startVoiceInput,
            active: isListening,
          ),
        ),
      ],
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 54,
        decoration: BoxDecoration(
          color: active
              ? Colors.cyanAccent.withOpacity(0.20)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? Colors.cyanAccent
                : Colors.cyanAccent.withOpacity(0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 21),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _urlCard() {
    return _glassBox(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Paste news URL here...",
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.link_rounded,
                  color: Colors.cyanAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isLoading ? null : fetchNewsFromUrl,
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.download_rounded,
                color: Colors.black,
              ),
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
          const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.cyanAccent,
            size: 42,
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: Text(
              loadingMessages[loadingIndex],
              key: ValueKey(loadingMessages[loadingIndex]),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "TruthLens is preparing an intelligent analysis...",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
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

  Widget _animatedResult({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _resultHeader(String verdict, int trustScore) {
    final color = getRiskColor(verdict);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: trustScore / 100),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedScore, child) {
        return _glassBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 92,
                        width: 92,
                        child: CircularProgressIndicator(
                          value: animatedScore,
                          strokeWidth: 8,
                          color: color,
                          backgroundColor: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      Icon(
                        getRiskIcon(verdict),
                        color: color,
                        size: 36,
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          verdict,
                          style: TextStyle(
                            color: color,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          result?["analysis_type"] ?? "Gemini AI Analysis",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Trust Score: ${(animatedScore * 100).round()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: _glassBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.cyanAccent,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Text(
                      text.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15.8,
                        height: 1.65,
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

  Widget _redFlagsCard(dynamic redFlags) {
    List flags = [];

    if (redFlags is List) {
      flags = redFlags;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: _glassBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.report_problem_rounded,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Red Flags Found",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (flags.isEmpty)
                    const Text(
                      "No major red flags found.",
                      style: TextStyle(color: Colors.white70),
                    )
                  else
                    ...flags.asMap().entries.map(
                      (entry) {
                        int index = entry.key;
                        String flag = entry.value.toString();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.orangeAccent.withOpacity(0.22),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor:
                                    Colors.orangeAccent.withOpacity(0.18),
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  flag,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15.5,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

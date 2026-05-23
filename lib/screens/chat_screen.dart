import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/fallback_chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String newsText;
  final Map<String, dynamic> analysisResult;

  const ChatScreen({
    super.key,
    required this.newsText,
    required this.analysisResult,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final questionController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;

  late AnimationController glowController;

  List<ChatMessage> messages = [
    ChatMessage(
      text:
          "Hi 👋 I’m TruthLens Assistant. Ask me why this news is suspicious, what the trust score means, or whether you should believe it.",
      isUser: false,
    ),
  ];

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  Future<void> sendMessage() async {
    final question = questionController.text.trim();

    if (question.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: question, isUser: true));
      questionController.clear();
      isLoading = true;
    });

    scrollToBottom();

    try {
      final answer = await GeminiService.chatAboutNews(
        newsText: widget.newsText,
        analysisResult: widget.analysisResult,
        userQuestion: question,
      );

      setState(() {
        messages.add(ChatMessage(text: answer, isUser: false));
      });
    } catch (e) {
      print(e);

      final fallbackAnswer = FallbackChatService.reply(
        question: question,
        analysisResult: widget.analysisResult,
      );

      setState(() {
        messages.add(
          ChatMessage(
            text: fallbackAnswer,
            isUser: false,
          ),
        );
      });
    }

    setState(() {
      isLoading = false;
    });

    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    questionController.dispose();
    scrollController.dispose();
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verdict = widget.analysisResult["verdict"]?.toString() ?? "Unknown";
    final score = widget.analysisResult["trust_score"]?.toString() ?? "0";

    return Scaffold(
      backgroundColor: const Color(0xff020617),
      body: Stack(
        children: [
          _background(),

          SafeArea(
            child: Column(
              children: [
                _topBar(verdict, score),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 18 * (1 - value)),
                              child: _messageBubble(msg),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                if (isLoading) _thinkingIndicator(),

                _inputBar(),
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
              top: -100 + glowController.value * 30,
              right: -90,
              child: _glowCircle(240, Colors.cyanAccent.withOpacity(0.12)),
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

  Widget _topBar(String verdict, String score) {
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

              const SizedBox(width: 12),

              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withOpacity(0.13),
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.35),
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.cyanAccent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TruthLens Chat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "$verdict • Trust $score%",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(26),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xff0F172A).withOpacity(0.88),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: questionController,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Ask about this news...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.07),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) {
                    if (!isLoading) sendMessage();
                  },
                ),
              ),

              const SizedBox(width: 10),

              GestureDetector(
                onTap: isLoading ? null : sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: isLoading
                        ? Colors.cyanAccent.withOpacity(0.35)
                        : Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.25),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: msg.isUser
              ? const LinearGradient(
                  colors: [
                    Colors.cyanAccent,
                    Color(0xff67E8F9),
                  ],
                )
              : null,
          color: msg.isUser ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 20),
          ),
          border: Border.all(
            color: msg.isUser
                ? Colors.transparent
                : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.black : Colors.white70,
            fontSize: 15,
            height: 1.45,
            fontWeight: msg.isUser ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _thinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: const Text(
          "TruthLens is thinking...",
          style: TextStyle(color: Colors.white54, fontSize: 13),
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
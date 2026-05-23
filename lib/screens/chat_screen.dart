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

class _ChatScreenState extends State<ChatScreen> {
  final questionController = TextEditingController();

  bool isLoading = false;

  List<ChatMessage> messages = [
    ChatMessage(
      text:
          "Hi, I’m TruthLens Assistant. Ask me anything about this news analysis.",
      isUser: false,
    ),
  ];

  Future<void> sendMessage() async {
    final question = questionController.text.trim();

    if (question.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: question, isUser: true));
      questionController.clear();
      isLoading = true;
    });

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
  }

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
      appBar: AppBar(
        backgroundColor: const Color(0xff0F172A),
        title: const Text("TruthLens Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? Colors.cyanAccent
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.black : Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "TruthLens is thinking...",
                style: TextStyle(color: Colors.white54),
              ),
            ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff0F172A),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: questionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask about this news...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: isLoading ? null : sendMessage,
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent,
                      borderRadius: BorderRadius.circular(18),
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
        ],
      ),
    );
  }
}
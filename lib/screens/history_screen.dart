import 'package:flutter/material.dart';
import '../models/history_model.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryModel> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await HistoryService.getHistory();

    setState(() {
      history = data;
      isLoading = false;
    });
  }

  Future<void> clearHistory() async {
    await HistoryService.clearHistory();
    await loadHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("History cleared")),
    );
  }

  Color getColor(String verdict) {
    String value = verdict.toLowerCase();

    if (value.contains("fake")) {
      return Colors.redAccent;
    } else if (value.contains("doubtful")) {
      return Colors.orangeAccent;
    } else if (value.contains("invalid")) {
      return Colors.grey;
    } else {
      return Colors.greenAccent;
    }
  }

  String formatTime(String time) {
    try {
      DateTime date = DateTime.parse(time);
      return "${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),

      appBar: AppBar(
        backgroundColor: const Color(0xff0F172A),
        title: const Text("Analysis History"),
        actions: [
          IconButton(
            onPressed: history.isEmpty ? null : clearHistory,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            )
          : history.isEmpty
              ? const Center(
                  child: Text(
                    "No analysis history yet",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final color = getColor(item.verdict);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: color.withOpacity(0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  item.verdict,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              Text(
                                "${item.trustScore}%",
                                style: TextStyle(
                                  color: color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Text(
                            item.news,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            formatTime(item.time),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
class HistoryModel {

  final String news;
  final String verdict;
  final int trustScore;
  final String time;

  HistoryModel({
    required this.news,
    required this.verdict,
    required this.trustScore,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      "news": news,
      "verdict": verdict,
      "trustScore": trustScore,
      "time": time,
    };
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      news: json["news"],
      verdict: json["verdict"],
      trustScore: json["trustScore"],
      time: json["time"],
    );
  }
}
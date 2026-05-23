class FallbackAnalyzer {
  static Map<String, dynamic> analyze(String text) {

    final originalText = text.trim();
    final lowerText = originalText.toLowerCase();

    int riskScore = 0;
    List<String> redFlags = [];

    // VERY SHORT TEXT
    if (originalText.length < 25) {
      return {
        "verdict": "Invalid Input",
        "trust_score": 0,
        "simple_explanation":
            "The provided text is too short or incomplete for meaningful analysis.",
        "red_flags": [
          "Insufficient content detected.",
          "The text does not resemble a proper news statement."
        ],
        "ai_reasoning":
            "TruthLens could not detect enough meaningful information to classify this content as real or fake news.",
        "final_decision":
            "Please enter a proper headline, article, or news-related sentence.",
        "analysis_type": "Fallback Analysis"
      };
    }

    // GIBBERISH DETECTION
    bool looksLikeGibberish = _isGibberish(originalText);

    if (looksLikeGibberish) {
      return {
        "verdict": "Invalid News Content",
        "trust_score": 5,
        "simple_explanation":
            "The entered text appears to be random characters or meaningless content.",
        "red_flags": [
          "No meaningful sentence structure detected.",
          "Content appears non-news related."
        ],
        "ai_reasoning":
            "TruthLens detected that the text lacks understandable language patterns commonly found in news articles or headlines.",
        "final_decision":
            "Please enter valid news content for analysis.",
        "analysis_type": "Fallback Analysis"
      };
    }

    final emotionalWords = [
      "shocking",
      "breaking",
      "urgent",
      "viral",
      "exposed",
      "must share",
      "share this",
      "danger",
      "alert",
      "secret",
      "hidden truth",
      "100% true",
      "guaranteed",
      "miracle",
      "conspiracy",
      "banned",
      "you won't believe",
    ];

    for (String word in emotionalWords) {
      if (lowerText.contains(word)) {
        riskScore += 8;
      }
    }

    // CLICKBAIT
    if (lowerText.contains("must share") ||
        lowerText.contains("forward this")) {

      riskScore += 20;

      redFlags.add(
        "The content encourages urgent sharing behavior, which is common in misleading posts.",
      );
    }

    // ALL CAPS
    if (originalText == originalText.toUpperCase() &&
        originalText.length > 40) {

      riskScore += 15;

      redFlags.add(
        "Excessive capital letters detected.",
      );
    }

    // NO SOURCE
    if (!lowerText.contains("according to") &&
        !lowerText.contains("official") &&
        !lowerText.contains("reported") &&
        !lowerText.contains("source")) {

      riskScore += 15;

      redFlags.add(
        "No trusted or official source mentioned.",
      );
    }

    // EXTREME CLAIMS
    if (lowerText.contains("miracle") ||
        lowerText.contains("overnight") ||
        lowerText.contains("instant") ||
        lowerText.contains("cure")) {

      riskScore += 18;

      redFlags.add(
        "Extraordinary or unrealistic claims detected.",
      );
    }

    // TOO MANY EXCLAMATIONS
    int exclamationCount = '!'.allMatches(originalText).length;

    if (exclamationCount >= 3) {
      riskScore += 12;

      redFlags.add(
        "Excessive emotional punctuation detected.",
      );
    }

    // NO RED FLAGS
    if (redFlags.isEmpty) {
      redFlags.add(
        "No major misinformation patterns were strongly detected.",
      );
    }

    if (riskScore > 100) {
      riskScore = 100;
    }

    int trustScore = 100 - riskScore;

    String verdict;

    if (trustScore >= 75) {
      verdict = "Likely Real";
    } else if (trustScore >= 45) {
      verdict = "Doubtful";
    } else {
      verdict = "Likely Fake";
    }

    return {
      "verdict": verdict,
      "trust_score": trustScore,
      "simple_explanation":
          "TruthLens analyzed the structure, wording style, emotional intensity, and source credibility patterns within the submitted content.",
      "red_flags": redFlags,
      "ai_reasoning":
          "This fallback analysis system evaluates suspicious writing behavior commonly found in misinformation, including emotional manipulation, clickbait language, lack of evidence, unrealistic claims, and low credibility indicators.",
      "final_decision":
          "Based on detected patterns, the content is classified as $verdict with a trust score of $trustScore%.",
      "analysis_type": "Fallback Analysis"
    };
  }

  static bool _isGibberish(String text) {

    final cleaned = text.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    if (cleaned.length < 5) {
      return true;
    }

    int vowels = RegExp(r'[aeiouAEIOU]')
        .allMatches(cleaned)
        .length;

    double vowelRatio = vowels / cleaned.length;

    if (vowelRatio < 0.15) {
      return true;
    }

    return false;
  }
}
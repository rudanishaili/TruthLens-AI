class FallbackChatService {
  static String reply({
    required String question,
    required Map<String, dynamic> analysisResult,
  }) {
    final q = question.toLowerCase().trim();

    final verdict = analysisResult["verdict"]?.toString() ?? "Unknown";
    final score = analysisResult["trust_score"]?.toString() ?? "0";
    final explanation =
        analysisResult["simple_explanation"]?.toString() ?? "";
    final reasoning = analysisResult["ai_reasoning"]?.toString() ?? "";
    final decision = analysisResult["final_decision"]?.toString() ?? "";
    final analysisType =
        analysisResult["analysis_type"]?.toString() ?? "TruthLens Analysis";

    final redFlags = analysisResult["red_flags"];

    String redFlagText() {
      if (redFlags is List && redFlags.isNotEmpty) {
        return redFlags.map((e) => "• $e").join("\n");
      }
      return "No strong red flags were detected in this analysis.";
    }

    bool hasAny(List<String> words) {
      return words.any((word) => q.contains(word));
    }

    if (q.isEmpty) {
      return "Ask me anything about this news analysis, such as why it is marked $verdict, what the red flags mean, or how the trust score was calculated.";
    }

    if (hasAny(["hi", "hello", "hey", "hii"])) {
      return "Hello 👋 I’m TruthLens Assistant. I can explain the verdict, trust score, red flags, reasoning, and final decision for this news.";
    }

    if (hasAny(["what can you do", "help", "options", "features"])) {
      return """
You can ask me:
• Why is this marked $verdict?
• What does the trust score mean?
• What are the red flags?
• Is this fake or real?
• Explain this simply.
• Should I trust this news?
• What should I be careful about?
""";
    }

    if (hasAny(["verdict", "result", "conclusion", "final answer"])) {
      return "The verdict is: $verdict.\n\nFinal decision:\n$decision";
    }

    if (hasAny(["fake", "real", "true", "false", "trust this", "believe"])) {
      return "TruthLens classified this news as $verdict with a trust score of $score%.\n\nThis is not a legal or official fact-check, but it shows how trustworthy or suspicious the content appears based on the available analysis.";
    }

    if (hasAny(["why", "reason", "because", "basis"])) {
      return "Reason for this result:\n\n$reasoning";
    }

    if (hasAny(["score", "trust score", "percentage", "percent", "%"])) {
      return "The trust score is $score%.\n\nHigher score means the news appears more reliable. Lower score means the text contains more suspicious patterns such as weak sourcing, emotional wording, or unrealistic claims.";
    }

    if (hasAny(["red flag", "red flags", "suspicious", "warning", "problem"])) {
      return "Red flags found:\n\n${redFlagText()}";
    }

    if (hasAny(["simple", "explain", "summary", "summarize", "easy"])) {
      return "Simple explanation:\n\n$explanation";
    }

    if (hasAny(["source", "official", "proof", "evidence", "reference"])) {
      return "Source/evidence check:\n\nThis analysis looks at whether the text mentions official sources, references, reports, or clear evidence. If the content does not mention a credible source, it becomes less trustworthy.";
    }

    if (hasAny(["emotional", "clickbait", "sensational", "dramatic"])) {
      return "Emotional or clickbait language can make news suspicious because fake or misleading posts often use urgency, fear, anger, or shock to make people react quickly without verifying.";
    }

    if (hasAny(["share", "forward", "viral", "whatsapp"])) {
      return "Messages asking users to forward quickly or share with everyone are often suspicious. Reliable news usually informs; misleading content often pressures people to spread it.";
    }

    if (hasAny(["caps", "capital", "uppercase", "!!!", "exclamation"])) {
      return "Excessive capital letters or too many exclamation marks can indicate emotional manipulation. It does not automatically mean fake, but it is a warning sign.";
    }

    if (hasAny(["invalid", "gibberish", "random", "short", "not news"])) {
      return "If the input is too short, random, or not written like a news statement, TruthLens cannot classify it properly. Please enter a complete headline, article paragraph, or forwarded news message.";
    }

    if (hasAny(["safe", "danger", "risky", "risk"])) {
      return "Risk depends on the verdict:\n\n• Likely Real = lower risk\n• Doubtful = needs caution\n• Likely Fake = high risk\n• Invalid Input = not enough valid news content\n\nCurrent verdict: $verdict";
    }

    if (hasAny(["improve", "better", "verify", "check manually"])) {
      return """
To verify this better:
• Search the same claim on trusted news sites
• Check official government/company sources
• Compare dates and context
• Avoid trusting screenshots without source
• Be careful if it asks you to urgently forward it
""";
    }

    if (hasAny(["analysis type", "fallback", "gemini", "ai not working"])) {
      return "This result was generated using $analysisType. If Gemini is unavailable or quota is reached, TruthLens uses fallback analysis based on misinformation patterns.";
    }

    if (hasAny(["date", "old", "recent", "time"])) {
      return "Dates matter a lot in news verification. Old news is sometimes reshared as if it is recent, which can mislead people even if the original event was real.";
    }

    if (hasAny(["bias", "propaganda", "political"])) {
      return "Bias or propaganda may appear when content uses one-sided language, emotional attacks, missing context, or tries to influence opinion instead of presenting balanced facts.";
    }

    if (hasAny(["health", "medicine", "doctor", "cure", "disease"])) {
      return "Health-related claims need extra caution. If news talks about cures, medicines, or diseases without official medical sources, it should be treated as risky.";
    }

    if (hasAny(["money", "bank", "upi", "atm", "payment", "loan"])) {
      return "Finance or banking claims should be checked carefully through official bank, RBI, government, or company sources. Fake financial news can cause panic.";
    }

    if (hasAny(["government", "law", "policy", "exam", "result"])) {
      return "Government, law, exam, or policy-related news should be verified only from official websites or trusted news outlets because fake circulars and notices are very common.";
    }

    if (hasAny(["screenshot", "image", "photo"])) {
      return "Screenshots can be edited easily, so they are less reliable unless the original source, date, and publisher can be verified.";
    }

    if (hasAny(["url", "link", "website"])) {
      return "For URL-based news, reliability depends on the website reputation, article date, author/source details, and whether other trusted sources report the same claim.";
    }

    if (hasAny(["thank", "thanks"])) {
      return "You're welcome 😊 Keep verifying before trusting or sharing news.";
    }

    return """
Here is what I can say from the current analysis:

Verdict: $verdict
Trust Score: $score%

Simple explanation:
$explanation

Ask me things like:
• Why this verdict?
• What are the red flags?
• Should I trust it?
• Explain in simple words.
""";
  }
}
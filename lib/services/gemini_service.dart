import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = "KEY";

  static Future<Map<String, dynamic>> analyzeNews(String newsText) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey",
    );

    final prompt = """
Analyze this news and return JSON only.

News:
$newsText

Format:
{
  "verdict": "Likely Real / Doubtful / Likely Fake",
  "trust_score": 0,
  "simple_explanation": "",
  "red_flags": [],
  "ai_reasoning": "",
  "final_decision": ""
}
""";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "response_mime_type": "application/json",
          "temperature": 0.2,
          "maxOutputTokens": 700
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Gemini API Error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final text = data["candidates"][0]["content"]["parts"][0]["text"];

    return jsonDecode(text);
  }

  static Future<String> chatAboutNews({
    required String newsText,
    required Map<String, dynamic> analysisResult,
    required String userQuestion,
  }) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey",
    );

    final prompt = """
You are TruthLens AI Assistant.

User is asking a follow-up question about a news analysis.

Original News:
$newsText

Analysis Result:
Verdict: ${analysisResult["verdict"]}
Trust Score: ${analysisResult["trust_score"]}
Simple Explanation: ${analysisResult["simple_explanation"]}
Red Flags: ${analysisResult["red_flags"]}
AI Reasoning: ${analysisResult["ai_reasoning"]}
Final Decision: ${analysisResult["final_decision"]}

User Question:
$userQuestion

Reply in simple, clear language.
Do not claim live internet verification.
Keep answer short and helpful.
""";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.4,
          "maxOutputTokens": 400
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Gemini Chat Error: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data["candidates"][0]["content"]["parts"][0]["text"];
  }
}
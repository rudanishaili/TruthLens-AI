import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_model.dart';

class HistoryService {

  static const String historyKey = "analysis_history";

  static Future<void> saveHistory(
    HistoryModel item,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    List<String> history =
        prefs.getStringList(historyKey) ?? [];

    history.insert(
      0,
      jsonEncode(item.toJson()),
    );

    await prefs.setStringList(
      historyKey,
      history,
    );
  }

  static Future<List<HistoryModel>>
      getHistory() async {

    final prefs =
        await SharedPreferences.getInstance();

    List<String> history =
        prefs.getStringList(historyKey) ?? [];

    return history.map((e) {

      return HistoryModel.fromJson(
        jsonDecode(e),
      );

    }).toList();
  }

  static Future<void> clearHistory() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove(historyKey);
}
}
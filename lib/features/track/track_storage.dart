import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'track_model.dart';

class TrackStorage {
  static const key = "track_entries";

  static Future<void> saveEntry(TrackEntry entry) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> existing = prefs.getStringList(key) ?? [];

    existing.add(jsonEncode(entry.toJson()));

    await prefs.setStringList(key, existing);
  }

  static Future<List<TrackEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(key) ?? [];

    return data.map((e) {
      return TrackEntry.fromJson(jsonDecode(e));
    }).toList();
  }
}
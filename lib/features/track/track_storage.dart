import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'track_model.dart';

class TrackStorage {

  static Future<String> _getKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString("cached_username");

    // Fallback: decode from JWT token
    if (username == null) {
      final token = prefs.getString("access_token");
      if (token != null) {
        username = _decodeUsernameFromToken(token);
      }
    }

    final safeUsername = (username ?? 'guest').replaceAll(' ', '_').toLowerCase();
    return 'track_entries_$safeUsername';
  }

  static Future<void> saveEntry(TrackEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final existing = prefs.getStringList(key) ?? [];
    existing.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(key, existing);
  }

  static Future<List<TrackEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final data = prefs.getStringList(key) ?? [];
    return data.map((e) => TrackEntry.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    final existing = prefs.getStringList(key) ?? [];
    if (index >= 0 && index < existing.length) {
      existing.removeAt(index);
      await prefs.setStringList(key, existing);
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getKey();
    await prefs.remove(key);
  }

  static String? _decodeUsernameFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      String payload = parts[1]
          .replaceAll('-', '+')
          .replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2: payload += '=='; break;
        case 3: payload += '='; break;
      }
      final decoded = utf8.decode(base64.decode(payload));
      final Map<String, dynamic> json = jsonDecode(decoded);
      return json['username'] as String?;
    } catch (_) {
      return null;
    }
  }
}
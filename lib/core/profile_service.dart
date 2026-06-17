import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// ─────────────────────────────────────────────
///  PROFILE SERVICE
///  Talks to GET/PATCH /api/auth/profile/
///  Requires a valid access token (attaches it automatically).
/// ─────────────────────────────────────────────
class UserProfile {
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final int averageCycleLength;
  final int averagePeriodLength;
  final String? lastPeriodStartDate; // "YYYY-MM-DD" or null
  final int? currentCycleDay;
  final String? currentPhase;

  UserProfile({
    this.age,
    this.heightCm,
    this.weightKg,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.lastPeriodStartDate,
    this.currentCycleDay,
    this.currentPhase,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] as int?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      averageCycleLength: (json['average_cycle_length'] as int?) ?? 28,
      averagePeriodLength: (json['average_period_length'] as int?) ?? 5,
      lastPeriodStartDate: json['last_period_start_date'] as String?,
      currentCycleDay: json['current_cycle_day'] as int?,
      currentPhase: json['current_phase'] as String?,
    );
  }
}

class ProfileService {
  static const String baseUrl = AuthService.baseUrl;

  /// Fetches the current user's profile.
  static Future<UserProfile> getProfile() async {
    final token = await AuthService.getAccessToken();
    if (token == null) {
      throw AuthException("You're not logged in. Please sign in again.");
    }

    http.Response response;
    try {
      response = await http
          .get(
            Uri.parse("$baseUrl/api/auth/profile/"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw AuthException(
          "Couldn't reach the server. Check your connection and try again.");
    }

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 401) {
      throw AuthException("Your session expired. Please sign in again.");
    }
    throw AuthException("Couldn't load your profile. Please try again.");
  }

  /// Updates the current user's profile. Only non-null fields are sent.
  static Future<UserProfile> updateProfile({
    int? age,
    double? heightCm,
    double? weightKg,
    int? averageCycleLength,
    int? averagePeriodLength,
    String? lastPeriodStartDate, // "YYYY-MM-DD"
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null) {
      throw AuthException("You're not logged in. Please sign in again.");
    }

    final body = <String, dynamic>{};
    if (age != null) body['age'] = age;
    if (heightCm != null) body['height_cm'] = heightCm;
    if (weightKg != null) body['weight_kg'] = weightKg;
    if (averageCycleLength != null) {
      body['average_cycle_length'] = averageCycleLength;
    }
    if (averagePeriodLength != null) {
      body['average_period_length'] = averagePeriodLength;
    }
    if (lastPeriodStartDate != null) {
      body['last_period_start_date'] = lastPeriodStartDate;
    }

    http.Response response;
    try {
      response = await http
          .patch(
            Uri.parse("$baseUrl/api/auth/profile/"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw AuthException(
          "Couldn't reach the server. Check your connection and try again.");
    }

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 401) {
      throw AuthException("Your session expired. Please sign in again.");
    }
    throw AuthException(_parseError(response.body));
  }

  static String _parseError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final messages = <String>[];
        decoded.forEach((key, value) {
          if (value is List) {
            messages.add("$key: ${value.join(', ')}");
          } else {
            messages.add("$key: $value");
          }
        });
        if (messages.isNotEmpty) return messages.join('\n');
      }
    } catch (_) {
      // fall through
    }
    return "Couldn't save your profile. Please check your entries and try again.";
  }
}
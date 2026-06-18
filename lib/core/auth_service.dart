import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ─────────────────────────────────────────────
///  AUTH SERVICE
///  Talks to the Django backend's JWT auth API.
///  Endpoints expected:
///    POST /api/auth/register/   {username, email, password}
///    POST /api/auth/login/      {username, password} -> {access, refresh}
///    POST /api/auth/login/refresh/  {refresh} -> {access}
/// ─────────────────────────────────────────────
class AuthService {
  // Windows desktop app and the Django server run on the same machine,
  // so plain localhost works here. If you later test on an Android
  // emulator instead, switch this to "http://10.0.2.2:8000". For a
  // physical phone on the same WiFi, use your PC's LAN IP and run
  // `python manage.py runserver 0.0.0.0:8000`.
  static const String baseUrl = "http://192.168.1.144:8000" ;

  static const String _accessKey = "access_token";
  static const String _refreshKey = "refresh_token";
  static const String _usernameKey = "cached_username";

  /// Registers a new user. The app currently only collects a username +
  /// password at signup, so we derive a placeholder email automatically
  /// since Django's User model requires one. Swap this out for a real
  /// email field later if you add email verification or password reset.
  static Future<void> register({
    required String username,
    required String password,
    String? email,
  }) async {
    final uri = Uri.parse("$baseUrl/api/auth/register/");
    final resolvedEmail = email ?? "$username@shesync.local";

    http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": username,
              "email": resolvedEmail,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw AuthException(
          "Couldn't reach the server. Check your connection and try again.");
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    }

    throw AuthException(_parseError(response.body));
  }

  /// Logs in and persists the access/refresh tokens locally.
  /// Throws [AuthException] on failure.
  static Future<void> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse("$baseUrl/api/auth/login/");
    http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": username,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw AuthException(
          "Couldn't reach the server. Check your connection and try again.");
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = data["access"] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessKey, accessToken);
      await prefs.setString(_refreshKey, data["refresh"] as String);

      // Cache the username straight from the JWT payload (embedded by
      // CustomTokenObtainPairSerializer on the Django side) so we don't
      // need a separate request just to display "@username" in Settings.
      final decodedUsername = _decodeUsernameFromToken(accessToken);
      if (decodedUsername != null) {
        await prefs.setString(_usernameKey, decodedUsername);
      } else {
        // Fall back to what was typed, in case the token doesn't carry it.
        await prefs.setString(_usernameKey, username);
      }
      return;
    }

    throw AuthException(_parseError(response.body, isLogin: true));
  }

  /// Returns true if a stored access token exists (used for "stay logged in").
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey) != null;
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  /// Returns the locally cached username (set at login time), or null
  /// if no one is logged in / nothing was cached.
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_usernameKey);
    if (cached != null) return cached;

    // Fallback: try decoding straight from whatever access token is stored.
    final token = prefs.getString(_accessKey);
    if (token == null) return null;
    return _decodeUsernameFromToken(token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_usernameKey);
  }

  /// Decodes the middle segment of a JWT (the payload) and pulls out
  /// the "username" claim. JWTs are base64url-encoded JSON, no signature
  /// verification needed here since we're just reading our own token.
  static String? _decodeUsernameFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      // base64url uses '-'/'_' instead of '+'/'/' and may need padding.
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64.decode(payload));
      final Map<String, dynamic> json = jsonDecode(decoded);
      return json['username'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Attempts to extract a readable error message from a DRF error response.
  static String _parseError(String body, {bool isLogin = false}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        // SimpleJWT login failures look like {"detail": "..."}
        if (decoded["detail"] != null) {
          return isLogin
              ? "Incorrect username or password."
              : decoded["detail"].toString();
        }
        // DRF validation errors look like {"username": ["..."], "email": ["..."]}
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
      // fall through to generic message
    }
    return "Something went wrong. Please try again.";
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
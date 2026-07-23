import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey = 'token';
  static const String _emailKey = 'email';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'user_id';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  static Future<void> saveAuthSession({
    required String token,
    required String email,
    required String username,
    required String role,
    required int userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_roleKey, role);
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<Map<String, dynamic>> readUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString(_usernameKey),
      'role': prefs.getString(_roleKey),
      'user_id': prefs.getInt(_userIdKey),
    };
  }

  static Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String> requireToken() async {
    final token = await readToken();
    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in');
    }
    return token;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
  }
}

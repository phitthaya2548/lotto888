import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _kTokenKey = 'token';

  static Future<void> saveBackendToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kTokenKey, token);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kTokenKey);
  }

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kTokenKey);
  }

  /// ✅ ถือว่า “ล็อกอิน” เฉพาะมี token เท่านั้น
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    debugPrint('AuthService.isLoggedIn token=$token');
    return token != null && token.isNotEmpty;
  }
}

import 'package:lotto/models/response/res_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _kTokenKey = 'token';
  static const _kUserIdKey = 'user_id';
  static const _kUsernameKey = 'username';
  static const _kRoleKey = 'role';
  static const _kLoggedInKey = 'isLoggedIn';

  static Future<void> saveSession(Responselogin res) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kTokenKey, res.token);
    await p.setInt(_kUserIdKey, res.user.id);
    await p.setString(_kUsernameKey, res.user.username);
    await p.setString(_kRoleKey, res.user.role);
    await p.setBool(_kLoggedInKey, true);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }

  static Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kLoggedInKey) ?? false;
  }
}

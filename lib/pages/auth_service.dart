import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lotto/models/response/res_login.dart';
class AuthService {
  static const _kToken = 'token';
  static const _kUserId = 'user_id';
  static const _kUsername = 'session';
  static const _kRole = 'role';
  static const _kLoggedIn = 'isLoggedIn';
  static const _storage = FlutterSecureStorage();
  static Future<void> saveSession(Responselogin res) async {
    await _storage.write(key: _kToken, value: res.token);
    await _storage.write(key: _kUserId, value: res.user.id.toString());
    await _storage.write(key: _kUsername, value: res.user.username);
    await _storage.write(key: _kRole, value: res.user.role);
    await _storage.write(key: _kLoggedIn, value: 'true');
  }
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
  static Future<String?> getUsername() async{
    return await _storage.read(key: _kUsername);
  }
  static Future<String?> getId() async{
    return await _storage.read(key: _kUserId);
  }

  static Future<bool> isLoggedIn() async {
    return (await _storage.read(key: _kLoggedIn)) == 'true';
  }
  static Future<String?> getRole() async {
    return await _storage.read(key: _kRole);
  }
}

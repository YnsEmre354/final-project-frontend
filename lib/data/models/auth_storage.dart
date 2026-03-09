import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _tokenKey = 'token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() async => _storage.read(key: _tokenKey);

  Future<void> deleteToken() async => _storage.delete(key: _tokenKey);

  // ignore: unnecessary_null_comparison
  Future<bool> isLoggedIn() async => getToken() != null;
}

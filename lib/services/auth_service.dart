import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static const String tokenKey = 'auth_token';

  Future<void> login(String email, String password) async {
    try {
      final token = await _apiService.login(email, password);
      await _saveToken(token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      await _apiService.register(email, password, name);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
}

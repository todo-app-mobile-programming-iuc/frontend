import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final ApiService _apiService = ApiService();
  static const String tokenKey = 'auth_token';

  Future<String?> login(String email, String password) async {
    final url = Uri.parse('https://backend.ahmetcanisik5458675.workers.dev/user/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['token']; // Ensure the token is returned
      await _saveToken(token);
      return token;
    } else {
      throw Exception('Failed to login');
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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_clearance/api_service.dart'; // Adjust import path as needed

class AuthService {
  final ApiService _apiService = ApiService();

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<bool> validateToken(String token) async {
    return await _apiService.validateToken(token);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}

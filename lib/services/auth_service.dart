import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Use 10.0.2.2 for Android emulator, or actual IP for physical device.
  // Using localhost is fine for web/desktop or if proxying.
  static const String baseUrl = 'http://192.168.1.15:5000/api/auth';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', data['role'] ?? 'user');
        await prefs.setString('name', data['user']['name'] ?? '');
        final userId = data['user']['id'];
        if (userId != null) {
          await prefs.setInt('userId', userId is int ? userId : (int.tryParse(userId.toString()) ?? -1));
        }
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password, String role, {
    String? salonName,
    String? address,
    String? phoneNumber,
    String? openingTime,
    String? closingTime,
  }) async {
    try {
      final body = {'name': name, 'email': email, 'password': password, 'role': role};
      if (salonName != null && salonName.isNotEmpty) {
        body['salonName'] = salonName;
        if (address != null) body['address'] = address;
        if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
        if (openingTime != null) body['openingTime'] = openingTime;
        if (closingTime != null) body['closingTime'] = closingTime;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('name');
    await prefs.remove('userId');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    if (id == null || id == -1) return null;
    return id;
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'Guest Client';
  }
}

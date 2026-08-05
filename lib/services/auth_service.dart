import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class AuthService {
  // Use 10.0.2.2 for Android emulator, or actual IP for physical device.
  // Using localhost is fine for web/desktop or if proxying.
  static const String baseUrl = AppConstants.authBaseUrl;

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
        await prefs.setString('email', data['user']['email'] ?? '');
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
    await prefs.remove('email');
    await prefs.remove('userId');
    await prefs.remove('profile_pic');
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

  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? 'client@stylencut.com';
  }

  static Future<String?> getUserProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_pic');
  }

  static Future<void> saveUserProfilePic(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_pic', path);
  }

  static Future<bool> updateProfilePicOnServer({int? userId, String? email, required String profilePic}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile-pic'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (userId != null) 'userId': userId,
          if (email != null) 'email': email,
          'profilePic': profilePic,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating profile pic on server: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateName({
    required int userId,
    required String name,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-name'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'name': name,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

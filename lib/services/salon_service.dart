import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/salon.dart';

import '../constants.dart';

class SalonService {
  static const String baseUrl = AppConstants.salonBaseUrl;

  static Future<List<Salon>> getSalons() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['salons'] != null) {
          final List<dynamic> salonsJson = data['salons'];
          return salonsJson.map((json) => Salon.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching salons: $e');
      return [];
    }
  }

  static Future<Salon?> updateSalon(int salonId, int ownerId, String name, {String? address, String? phoneNumber, String? openingTime, String? closingTime, String? thumbnailPic}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$salonId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ownerId': ownerId,
          'name': name,
          'address': address,
          'phone_number': phoneNumber,
          'opening_time': openingTime,
          'closing_time': closingTime,
          'thumbnail_pic': thumbnailPic,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['salon'] != null) {
          return Salon.fromJson(data['salon']);
        }
      }
      return null;
    } catch (e) {
      print('Error updating salon: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getBarbers(int salonId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$salonId/barbers')).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['barbers'] != null) {
          return data['barbers'];
        }
      }
      return [];
    } catch (e) {
      print('Error fetching barbers: $e');
      return [];
    }
  }

  static Future<dynamic> createBarber(int salonId, String name, String email, String password, {int? experience, String? profilePic}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$salonId/barbers/new'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'experience': experience,
          'profile_pic': profilePic,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['barber'];
        }
      }
      return null;
    } catch (e) {
      print('Error creating barber: $e');
      return null;
    }
  }

  static Future<dynamic> updateBarber(int salonId, int barberId, String name, String email, {int? experience, String? profilePic}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$salonId/barbers/$barberId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'experience': experience,
          'profile_pic': profilePic,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['barber'];
        }
      }
      return null;
    } catch (e) {
      print('Error updating barber: $e');
      return null;
    }
  }

  static Future<String?> uploadThumbnail(String filePath) async {
    try {
      final uri = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // Resolve content type from file extension
      final extension = filePath.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      }

      print('Uploading file $filePath as $mimeType to $uri');
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail', 
          filePath,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload status code: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['url'] != null) {
          return data['url'];
        }
      }
      return null;
    } catch (e) {
      print('Error uploading thumbnail: $e');
      return null;
    }
  }

  static Future<bool> toggleSalonStatus(int salonId, bool isOpen) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$salonId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isOpen': isOpen}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error toggling salon status: $e');
      return false;
    }
  }

  static Future<bool> submitReview({
    required int salonId,
    required String customerName,
    required String barberName,
    required int salonRating,
    required int barberRating,
    required String salonReview,
    required String barberReview,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$salonId/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerName': customerName,
          'barberName': barberName,
          'salonRating': salonRating,
          'barberRating': barberRating,
          'salonReview': salonReview,
          'barberReview': barberReview,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }
}

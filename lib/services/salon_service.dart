import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/salon.dart';

class SalonService {
  static const String baseUrl = 'http://192.168.1.15:5000/api/salons';

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
}

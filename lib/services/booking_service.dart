import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';

class BookingService {
  static const String baseUrl = 'http://192.168.1.15:5000/api/salons';

  static Future<List<BookingModel>> fetchBookings(int salonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$salonId/bookings'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['bookings'] != null) {
          final List<dynamic> list = data['bookings'];
          return list.map((json) => BookingModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  static Future<bool> createBooking(int salonId, BookingModel booking) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$salonId/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(booking.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  static Future<List<BookingModel>> fetchCustomerBookings(String customerName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/customer/${Uri.encodeComponent(customerName)}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['bookings'] != null) {
          final List<dynamic> list = data['bookings'];
          return list.map((json) => BookingModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching customer bookings: $e');
      return [];
    }
  }

  static Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }
}

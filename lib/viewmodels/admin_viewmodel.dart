import 'package:flutter/foundation.dart';
import '../models/barber_model.dart';
import '../models/booking_model.dart';
import '../services/salon_service.dart';
import '../services/booking_service.dart';

class AdminViewModel extends ChangeNotifier {
  bool _isShopAccepting = true;
  bool get isShopAccepting => _isShopAccepting;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<BarberModel> _barbers = [];
  List<BarberModel> get barbers => _barbers;

  List<BookingModel> _todayBookings = [];
  List<BookingModel> get todayBookings => _todayBookings;

  // Stats
  int get todaysBookingsCount => _todayBookings.length;
  double get salesTotal => _todayBookings.fold(0.0, (sum, item) => sum + item.price);
  int get waitlistCount => _todayBookings.length > 2 ? 2 : _todayBookings.length;
  double get avgRating => 4.9;
  
  // Booking status counts
  int get totalBookings => _todayBookings.length;
  int get doneBookings => (_todayBookings.length * 0.75).round();
  int get leftBookings => _todayBookings.length - doneBookings;

  Future<void> initializeSalon(int salonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawBarbers = await SalonService.getBarbers(salonId);
      _barbers = rawBarbers.map((json) => BarberModel.fromJson(json)).toList();

      _todayBookings = await BookingService.fetchBookings(salonId);
    } catch (e) {
      print('Error initializing salon admin data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleShopStatus(bool value) {
    _isShopAccepting = value;
    notifyListeners();
  }

  void updateBarberStatus(String id, BarberStatus newStatus, [String? newDetails]) {
    final index = _barbers.indexWhere((b) => b.id == id);
    if (index != -1) {
      _barbers[index].status = newStatus;
      _barbers[index].details = newDetails;
      notifyListeners();
    }
  }
}

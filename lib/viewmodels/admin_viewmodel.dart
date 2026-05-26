import 'package:flutter/foundation.dart';
import '../models/salon.dart';
import '../models/barber_model.dart';
import '../models/booking_model.dart';
import '../services/salon_service.dart';
import '../services/booking_service.dart';

class AdminViewModel extends ChangeNotifier {
  int? _salonId;
  int? get salonId => _salonId;

  bool _isShopAccepting = true;
  bool get isShopAccepting => _isShopAccepting;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Salon? _salon;
  Salon? get salon => _salon;

  List<BarberModel> _barbers = [];
  List<BarberModel> get barbers => _barbers;

  List<BookingModel> _todayBookings = [];
  List<BookingModel> get todayBookings => _todayBookings;

  // Stats
  int get todaysBookingsCount => _todayBookings.length;
  
  // Real sales from completed bookings
  double get salesTotal => _todayBookings
      .where((b) => b.status == 'Completed')
      .fold(0.0, (sum, item) => sum + item.price);
  
  // Real waitlist from pending bookings
  int get waitlistCount => _todayBookings.where((b) => b.status == 'Pending').length;
  
  // Real average rating fetched from backend review system
  double get avgRating => _salon?.rating ?? 4.5;
  
  // Booking status counts
  int get totalBookings => _todayBookings.length;
  int get doneBookings => _todayBookings.where((b) => b.status == 'Completed').length;
  int get leftBookings => _todayBookings.where((b) => b.status != 'Completed').length;

  Future<void> initializeSalon(int salonId) async {
    _salonId = salonId;
    _isLoading = true;
    notifyListeners();

    try {
      final salons = await SalonService.getSalons();
      final currentSalon = salons.firstWhere((s) => s.id == salonId);
      _salon = currentSalon;
      _isShopAccepting = currentSalon.isOpen;

      final rawBarbers = await SalonService.getBarbers(salonId);
      _barbers = rawBarbers.map((json) => BarberModel.fromJson(json)).toList();

      _todayBookings = await BookingService.fetchBookings(salonId);
    } catch (e) {
      print('Error initializing salon admin data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateBookingStatus(int bookingId, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await BookingService.updateBookingStatus(bookingId, status);
      if (success) {
        final index = _todayBookings.indexWhere((b) => b.id == bookingId.toString());
        if (index != -1) {
          final b = _todayBookings[index];
          _todayBookings[index] = BookingModel(
            id: b.id,
            salonId: b.salonId,
            customerName: b.customerName,
            serviceName: b.serviceName,
            time: b.time,
            price: b.price,
            barberName: b.barberName,
            status: status,
            salonName: b.salonName,
          );
        }
      }
    } catch (e) {
      print('Error updating booking status: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleShopStatus(bool value) async {
    _isShopAccepting = value;
    notifyListeners();

    if (_salonId != null) {
      final success = await SalonService.toggleSalonStatus(_salonId!, value);
      if (!success) {
        // Revert on failure
        _isShopAccepting = !value;
        notifyListeners();
      }
    }
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

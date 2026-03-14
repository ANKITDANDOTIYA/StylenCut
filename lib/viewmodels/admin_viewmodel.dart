import 'package:flutter/foundation.dart';
import '../models/barber_model.dart';
import '../models/booking_model.dart';

class AdminViewModel extends ChangeNotifier {
  bool _isShopAccepting = true;
  bool get isShopAccepting => _isShopAccepting;

  final List<BarberModel> _barbers = [
    BarberModel(id: '1', name: 'Marco V.', status: BarberStatus.free),
    BarberModel(id: '2', name: 'James Sullivan', status: BarberStatus.withClient, details: 'Skin Fade'),
    BarberModel(id: '3', name: 'Elias Thorne', status: BarberStatus.busy, details: 'Busy until 2:30 PM'),
    BarberModel(id: '4', name: 'Sarah Jenkins', status: BarberStatus.free),
  ];

  List<BarberModel> get barbers => _barbers;

  final List<BookingModel> _todayBookings = [
    BookingModel(id: '1', customerName: 'David B.', serviceName: 'Classic Haircut', time: '09:00 AM', price: 30.0, barberName: 'Marcus Thorne'),
    BookingModel(id: '2', customerName: 'Sam R.', serviceName: 'Beard Trim', time: '10:30 AM', price: 20.0, barberName: 'Elias Thorne'),
    BookingModel(id: '3', customerName: 'Liam P.', serviceName: 'Classic Haircut', time: '11:30 AM', price: 30.0, barberName: 'Marco V.'),
    BookingModel(id: '4', customerName: 'Mike T.', serviceName: 'Full Service', time: '01:00 PM', price: 45.0, barberName: 'Sarah Jenkins'),
  ];

  List<BookingModel> get todayBookings => _todayBookings;

  // Stats
  int get todaysBookingsCount => _todayBookings.length;
  double get salesTotal => _todayBookings.fold(0, (sum, item) => sum + item.price);
  int get waitlistCount => 2;
  double get avgRating => 4.9;
  
  // Booking status counts
  int get totalBookings => 12;
  int get doneBookings => 8;
  int get leftBookings => 4;

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

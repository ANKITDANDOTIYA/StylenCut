
class BookingModel {
  final String id;
  final int salonId;
  final String customerName;
  final String serviceName;
  final String time;
  final String? bookingDate;
  final double price;
  final String barberName;
  final String status;
  final String salonName;
  final String? customerProfilePic;
  final String? barberProfilePic;

  BookingModel({
    required this.id,
    this.salonId = 0,
    required this.customerName,
    required this.serviceName,
    required this.time,
    this.bookingDate,
    required this.price,
    required this.barberName,
    this.status = 'Pending',
    this.salonName = '',
    this.customerProfilePic,
    this.barberProfilePic,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      salonId: json['salon_id'] != null ? int.tryParse(json['salon_id'].toString()) ?? 0 : 0,
      customerName: json['customer_name'] ?? '',
      serviceName: json['service_name'] ?? '',
      time: json['booking_time'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      barberName: json['barber_name'] ?? '',
      status: json['status'] ?? 'Pending',
      salonName: json['salon_name'] ?? '',
      customerProfilePic: json['customer_profile_pic'],
      barberProfilePic: json['barber_profile_pic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'serviceName': serviceName,
      'bookingDate': bookingDate ?? DateTime.now().toIso8601String().split('T')[0],
      'bookingTime': time,
      'price': price,
      'barberName': barberName,
      'status': status,
    };
  }
}

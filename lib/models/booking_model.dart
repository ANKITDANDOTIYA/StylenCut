class BookingModel {
  final String id;
  final String customerName;
  final String serviceName;
  final String time;
  final double price;
  final String barberName;

  BookingModel({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.time,
    required this.price,
    required this.barberName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      serviceName: json['service_name'] ?? '',
      time: json['booking_time'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      barberName: json['barber_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'serviceName': serviceName,
      'bookingDate': DateTime.now().toIso8601String().split('T')[0], // Use today's date formatted as YYYY-MM-DD
      'bookingTime': time,
      'price': price,
      'barberName': barberName,
    };
  }
}

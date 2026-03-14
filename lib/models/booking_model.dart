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
}

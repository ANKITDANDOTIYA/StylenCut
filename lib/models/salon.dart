class Salon {
  final int id;
  final int ownerId;
  final String name;
  final String? address;
  final String? phoneNumber;
  final bool isOpen;
  final String? openingTime;
  final String? closingTime;
  // TODO: Add ratings later
  final double rating;

  Salon({
    required this.id,
    required this.ownerId,
    required this.name,
    this.address,
    this.phoneNumber,
    this.isOpen = true,
    this.openingTime,
    this.closingTime,
    this.rating = 4.5, // Default for now until backend gives us ratings
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      isOpen: json['is_open'] ?? true,
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 4.5,
    );
  }
}

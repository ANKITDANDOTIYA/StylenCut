class Salon {
  final int id;
  final int ownerId;
  final String name;
  final String? address;
  final String? phoneNumber;
  final bool isOpen;
  final String? openingTime;
  final String? closingTime;
  final String? thumbnailPic;
  final double rating;
  final int reviewsCount;

  Salon({
    required this.id,
    required this.ownerId,
    required this.name,
    this.address,
    this.phoneNumber,
    this.isOpen = true,
    this.openingTime,
    this.closingTime,
    this.thumbnailPic,
    this.rating = 4.5,
    this.reviewsCount = 0,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] != null ? (int.tryParse(json['id'].toString()) ?? 0) : 0,
      ownerId: json['owner_id'] != null ? (int.tryParse(json['owner_id'].toString()) ?? 0) : 0,
      name: json['name'] ?? 'Unknown Salon',
      address: json['address'],
      phoneNumber: json['phone_number'],
      isOpen: json['is_open'] ?? true,
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      thumbnailPic: json['thumbnail_pic'],
      rating: json['rating'] != null ? (double.tryParse(json['rating'].toString()) ?? 4.5) : 4.5,
      reviewsCount: json['reviews_count'] != null ? (int.tryParse(json['reviews_count'].toString()) ?? 0) : 0,
    );
  }
}

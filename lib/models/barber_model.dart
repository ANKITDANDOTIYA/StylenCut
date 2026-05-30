 

import 'package:flutter/material.dart';


enum BarberStatus {
  free('Free'),
  withClient('With Client'),
  busy('Busy');

  final String label;
  const BarberStatus(this.label);

  Color get color {
    switch (this) {
      case BarberStatus.free:
        return Colors.green;
      case BarberStatus.withClient:
        return Colors.amber;
      case BarberStatus.busy:
        return Colors.red;
    }
  }
}

class BarberModel {
  final String id;
  final String name;
  BarberStatus status;
  String? details;
  final int? experience;
  final String? profilePic;
  final double rating;
  final int cuttingsCount;

  BarberModel({
    required this.id,
    required this.name,
    this.status = BarberStatus.free,
    this.details,
    this.experience,
    this.profilePic,
    this.rating = 5.0,
    this.cuttingsCount = 0,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      status: json['status'] != null
          ? BarberStatus.values.firstWhere(
              (e) => e.label.toLowerCase() == json['status'].toString().toLowerCase(),
              orElse: () => BarberStatus.free,
            )
          : BarberStatus.free,
      details: json['details'],
      experience: json['experience'] != null ? int.tryParse(json['experience'].toString()) : null,
      profilePic: json['profile_pic'],
      rating: json['rating'] != null ? (double.tryParse(json['rating'].toString()) ?? 5.0) : 5.0,
      cuttingsCount: json['cuttings_count'] != null ? (int.tryParse(json['cuttings_count'].toString()) ?? 0) : 0,
    );
  }
}

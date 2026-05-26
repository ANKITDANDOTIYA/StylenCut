// Barber Model Class - It is used to represent the barber model.

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

  BarberModel({
    required this.id,
    required this.name,
    this.status = BarberStatus.free,
    this.details,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      status: BarberStatus.free,
    );
  },
}

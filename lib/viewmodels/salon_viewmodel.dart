import 'package:flutter/material.dart';
import '../models/salon.dart';
import '../services/salon_service.dart';

class SalonViewModel extends ChangeNotifier {
  List<Salon> _salons = [];
  bool _isLoading = false;

  List<Salon> get salons => _salons;
  bool get isLoading => _isLoading;

  Future<void> fetchSalons() async {
    _isLoading = true;
    notifyListeners();

    _salons = await SalonService.getSalons();

    _isLoading = false;
    notifyListeners();
  }
}

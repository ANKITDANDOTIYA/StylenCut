import 'package:flutter/material.dart';
import '../models/salon.dart';
import '../services/salon_service.dart';

class SalonViewModel extends ChangeNotifier {
  List<Salon> _salons = [];
  bool _isLoading = false;
  Salon? _adminSalon;

  List<Salon> get salons => _salons;
  bool get isLoading => _isLoading;
  Salon? get adminSalon => _adminSalon;

  Future<void> fetchSalons() async {
    _isLoading = true;
    notifyListeners();

    _salons = await SalonService.getSalons();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAdminSalon(int adminId) async {
    _isLoading = true;
    notifyListeners();

    _salons = await SalonService.getSalons();
    try {
      _adminSalon = _salons.firstWhere((s) => s.ownerId == adminId);
    } catch (e) {
      _adminSalon = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setAdminSalon(Salon salon) {
    _adminSalon = salon;
    notifyListeners();
  }

  Future<Salon?> updateSalon(int salonId, int ownerId, String name, {String? address, String? phoneNumber, String? openingTime, String? closingTime, String? thumbnailPic}) async {
    _isLoading = true;
    notifyListeners();

    final updated = await SalonService.updateSalon(salonId, ownerId, name, address: address, phoneNumber: phoneNumber, openingTime: openingTime, closingTime: closingTime, thumbnailPic: thumbnailPic);
    
    if (updated != null) {
      final index = _salons.indexWhere((s) => s.id == salonId);
      if (index != -1) {
        _salons[index] = updated;
      }
      if (_adminSalon != null && _adminSalon!.id == salonId) {
        _adminSalon = updated;
      }
    }

    _isLoading = false;
    notifyListeners();
    return updated;
  }

  Future<List<dynamic>> fetchBarbers(int salonId) async {
    return await SalonService.getBarbers(salonId);
  }

  Future<bool> createBarber(int salonId, String name, String email, String password, {int? experience, String? profilePic}) async {
    _isLoading = true;
    notifyListeners();

    final barber = await SalonService.createBarber(salonId, name, email, password, experience: experience, profilePic: profilePic);

    _isLoading = false;
    notifyListeners();
    
    return barber != null;
  }

  Future<bool> updateBarber(int salonId, int barberId, String name, String email, {int? experience, String? profilePic}) async {
    _isLoading = true;
    notifyListeners();

    final barber = await SalonService.updateBarber(salonId, barberId, name, email, experience: experience, profilePic: profilePic);

    _isLoading = false;
    notifyListeners();
    
    return barber != null;
  }

  Future<String?> uploadSalonThumbnail(String? filePath, {List<int>? bytes, String? filename}) async {
    _isLoading = true;
    notifyListeners();

    final uploadedUrl = await SalonService.uploadThumbnail(filePath, bytes: bytes, filename: filename);

    _isLoading = false;
    notifyListeners();
    return uploadedUrl;
  }
}

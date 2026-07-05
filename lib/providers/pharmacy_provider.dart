import 'package:flutter/foundation.dart';
import '../models/pharmacy.dart';
import '../services/cached_pharmacy_data_service.dart';
import '../services/eczane_api_service.dart';
import '../services/overpass_service.dart';
import '../utils/distance_calculator.dart';
import '../utils/city_centers.dart';

class PharmacyProvider extends ChangeNotifier {
  PharmacyProvider(this._eczaneApi, this._overpass, this._cachedData);
  final EczaneApiService _eczaneApi;
  final OverpassService _overpass;
  final CachedPharmacyDataService _cachedData;
  List<Pharmacy> pharmacies = [];
  bool loading = false;
  String? error;
  bool showList = false;
  bool usingDailyCache = false;
  double? centerLatitude;
  double? centerLongitude;

  void toggleView() {
    showList = !showList;
    notifyListeners();
  }

  Future<void> loadByRegion({required String city, String? district}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final cached = await _cachedData.fetch(city: city, district: district);
      usingDailyCache = cached.isNotEmpty;
      pharmacies = cached;
      final cityCenter = CityCenters.byCity(city);
      centerLatitude = cityCenter.latitude;
      centerLongitude = cityCenter.longitude;
      if (pharmacies.isEmpty) {
        error = 'Bu bölge için veri bulunamadı. Bölgeyi değiştirip tekrar deneyin.';
      } else {
        _sortByDistance(centerLatitude!, centerLongitude!);
      }
    } catch (_) {
      error = 'Şu anda veri alınamıyor, lütfen internet bağlantınızı kontrol edin.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadByLocation({required double latitude, required double longitude, String? city, String? district}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final cached = await _cachedData.fetch(city: city, district: district);
      if (cached.isNotEmpty) {
        usingDailyCache = true;
        pharmacies = cached;
      } else {
        usingDailyCache = false;
        final results = await Future.wait([
          _eczaneApi.fetchDutyPharmaciesByCity(city ?? 'İstanbul', district: district),
          _overpass.fetchNearbyPharmacies(latitude: latitude, longitude: longitude),
        ]);
        pharmacies = [...results[0], ...results[1]];
      }
      centerLatitude = latitude;
      centerLongitude = longitude;
      _sortByDistance(latitude, longitude);
      if (pharmacies.isEmpty) error = 'Şu anda veri alınamıyor, lütfen internet bağlantınızı kontrol edin.';
    } catch (_) {
      error = 'Şu anda veri alınamıyor, lütfen internet bağlantınızı kontrol edin.';
    }
    loading = false;
    notifyListeners();
  }

  void _sortByDistance(double latitude, double longitude) {
    for (final p in pharmacies) {
      p.distanceKm = DistanceCalculator.betweenKm(latitude, longitude, p.latitude, p.longitude);
    }
    pharmacies.sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
  }
}

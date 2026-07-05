import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider(this._service);
  final LocationService _service;
  Position? position;
  bool loading = false;
  bool deniedForever = false;
  String? message;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      final result = await _service.currentPosition();
      position = result.position;
      deniedForever = result.deniedForever;
      message = result.message;
    } catch (_) {
      position = null;
      deniedForever = false;
      message = 'Konum alınamadı. İl / ilçe seçerek devam edebilirsiniz.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  Future<void> openSettings() => _service.openSettings();
}

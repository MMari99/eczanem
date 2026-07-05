import 'package:geolocator/geolocator.dart';

class LocationResult {
  const LocationResult({this.position, this.deniedForever = false, this.message});
  final Position? position;
  final bool deniedForever;
  final String? message;
}

class LocationService {
  Future<LocationResult> currentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled().timeout(const Duration(seconds: 5), onTimeout: () => true);
      if (!enabled) return const LocationResult(message: 'Konum servisleri kapalı.');

      var permission = await Geolocator.checkPermission().timeout(const Duration(seconds: 5), onTimeout: () => LocationPermission.denied);
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(const Duration(seconds: 10), onTimeout: () => LocationPermission.denied);
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(deniedForever: true, message: 'Konum izni kalıcı olarak reddedildi.');
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult(message: 'Konum izni verilmedi.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      ).timeout(const Duration(seconds: 12));
      return LocationResult(position: position);
    } catch (_) {
      return const LocationResult(message: 'Konum alınamadı. İl / ilçe seçerek devam edebilirsiniz.');
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}

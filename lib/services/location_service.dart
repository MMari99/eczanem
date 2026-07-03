import 'package:geolocator/geolocator.dart';

class LocationResult {
  const LocationResult({this.position, this.deniedForever = false, this.message});
  final Position? position;
  final bool deniedForever;
  final String? message;
}

class LocationService {
  Future<LocationResult> currentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return const LocationResult(message: 'Konum servisleri kapalı.');
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return const LocationResult(deniedForever: true, message: 'Konum izni kalıcı olarak reddedildi.');
    if (permission == LocationPermission.denied) return const LocationResult(message: 'Konum izni verilmedi.');
    final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)));
    return LocationResult(position: position);
  }
  Future<void> openSettings() => Geolocator.openAppSettings();
}

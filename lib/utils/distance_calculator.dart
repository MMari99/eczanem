import 'dart:math';

class DistanceCalculator {
  const DistanceCalculator._();
  static double betweenKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return earthRadiusKm * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
  static double _rad(double degree) => degree * pi / 180;
  static String label(double? km) {
    if (km == null) return '';
    if (km < 1) return '${(km * 1000).round()} m uzaklıkta';
    return '${km.toStringAsFixed(1)} km uzaklıkta';
  }
}

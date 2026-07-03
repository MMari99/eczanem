import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pharmacy.dart';

class OverpassService {
  OverpassService({http.Client? client}) : _client = client ?? http.Client();
  static const endpoint = 'https://overpass-api.de/api/interpreter';
  final http.Client _client;

  Future<List<Pharmacy>> fetchNearbyPharmacies({required double latitude, required double longitude, int radiusMeters = 3000}) async {
    final query = '[out:json][timeout:10];node["amenity"="pharmacy"](around:$radiusMeters,$latitude,$longitude);out body;';
    try {
      final response = await _client.post(Uri.parse(endpoint), headers: {'User-Agent': 'Eczanem/1.0 (OpenStreetMap flutter_map app)'}, body: {'data': query}).timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = (decoded['elements'] as List? ?? const []);
      return elements.map((raw) {
        final item = raw as Map<String, dynamic>;
        final tags = (item['tags'] as Map?) ?? const {};
        return Pharmacy(id: 'osm-${item['id']}', name: '${tags['name'] ?? 'Eczane'}', address: _address(tags), phone: '${tags['phone'] ?? tags['contact:phone'] ?? ''}', latitude: (item['lat'] as num).toDouble(), longitude: (item['lon'] as num).toDouble(), isOnDuty: false, workingHours: tags['opening_hours']?.toString());
      }).toList();
    } catch (_) {
      return [];
    }
  }

  String _address(Map tags) {
    final parts = [tags['addr:street'], tags['addr:housenumber'], tags['addr:district'], tags['addr:city']].where((e) => e != null && e.toString().trim().isNotEmpty).join(' ');
    return parts.isEmpty ? 'Adres bilgisi yok' : parts;
  }
}

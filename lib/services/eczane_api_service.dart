import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/pharmacy.dart';

class EczaneApiService {
  EczaneApiService({http.Client? client}) : _client = client ?? http.Client();
  static const baseUrl = 'https://api.eczaneleri.net';
  static const cityDutyEndpoint = '/v1/pharmacies/duty';
  final http.Client _client;

  Future<List<Pharmacy>> fetchDutyPharmaciesByCity(String city, {String? district}) async {
    final apiKey = dotenv.maybeGet('API_KEY') ?? '';
    if (apiKey.isEmpty) return [];
    final uri = Uri.parse('$baseUrl$cityDutyEndpoint').replace(queryParameters: {'city': city, if (district != null && district.isNotEmpty) 'district': district});
    try {
      final response = await _client.get(uri, headers: {'X-Api-Key': apiKey, 'Accept': 'application/json'}).timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) return [];
      final decoded = jsonDecode(response.body);
      final items = decoded is List ? decoded : (decoded['data'] ?? decoded['result'] ?? []) as List;
      return items.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Pharmacy _fromJson(Map<String, dynamic> json) {
    final coordinates = (json['coordinates'] as Map?) ?? const {};
    final lat = double.tryParse('${coordinates['lat'] ?? json['lat'] ?? 0}') ?? 0;
    final lon = double.tryParse('${coordinates['lon'] ?? coordinates['lng'] ?? json['lon'] ?? json['lng'] ?? 0}') ?? 0;
    return Pharmacy(id: 'duty-${json['id'] ?? json['title'] ?? lat}', name: '${json['title'] ?? json['name'] ?? 'Eczane'}', address: '${json['address'] ?? ''}', phone: '${json['phone'] ?? ''}', latitude: lat, longitude: lon, isOnDuty: true, workingHours: json['workingHours']?.toString(), city: json['city']?.toString(), district: json['district']?.toString());
  }
}

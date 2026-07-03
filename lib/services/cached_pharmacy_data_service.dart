import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/pharmacy.dart';

class CachedPharmacyDataService {
  CachedPharmacyDataService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const bundledAsset = 'public/data/pharmacies_latest.json';

  Future<List<Pharmacy>> fetch({String? city, String? district}) async {
    final remoteUrl = dotenv.maybeGet('PHARMACY_DATA_URL') ?? '';
    final raw = remoteUrl.trim().isNotEmpty ? await _fetchRemote(remoteUrl.trim()) : await _fetchBundled();
    if (raw == null || raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final items = (decoded['pharmacies'] as List? ?? const []);
    return items
        .map((item) => _fromJson(item as Map<String, dynamic>))
        .where((pharmacy) => _matches(pharmacy, city, district))
        .toList();
  }

  Future<String?> _fetchRemote(String url) async {
    try {
      final response = await _client.get(Uri.parse(url), headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) return response.body;
    } catch (_) {}
    return _fetchBundled();
  }

  Future<String?> _fetchBundled() async {
    try {
      return rootBundle.loadString(bundledAsset);
    } catch (_) {
      return null;
    }
  }

  bool _matches(Pharmacy pharmacy, String? city, String? district) {
    final cityOk = city == null || city.isEmpty || pharmacy.city?.toLowerCase() == city.toLowerCase();
    final districtOk = district == null || district.isEmpty || pharmacy.district?.toLowerCase() == district.toLowerCase();
    return cityOk && districtOk;
  }

  Pharmacy _fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse('${json['latitude'] ?? json['lat'] ?? 0}') ?? 0;
    final lon = double.tryParse('${json['longitude'] ?? json['lon'] ?? json['lng'] ?? 0}') ?? 0;
    return Pharmacy(
      id: '${json['id'] ?? json['name'] ?? lat}',
      name: '${json['name'] ?? json['title'] ?? 'Eczane'}',
      address: '${json['address'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      latitude: lat,
      longitude: lon,
      isOnDuty: json['isOnDuty'] == true,
      workingHours: json['workingHours']?.toString(),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
    );
  }
}

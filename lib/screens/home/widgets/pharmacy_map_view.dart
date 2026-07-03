import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/pharmacy.dart';
import '../../../theme/app_colors.dart';
import 'pharmacy_detail_sheet.dart';

class PharmacyMapView extends StatelessWidget {
  const PharmacyMapView({super.key, required this.center, required this.pharmacies});
  final LatLng center;
  final List<Pharmacy> pharmacies;
  @override
  Widget build(BuildContext context) {
    return FlutterMap(options: MapOptions(initialCenter: center, initialZoom: 14), children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.eczanem.app'), MarkerLayer(markers: [Marker(point: center, width: 36, height: 36, child: Container(decoration: BoxDecoration(color: Colors.blue, border: Border.all(color: Colors.white, width: 3), shape: BoxShape.circle))), ...pharmacies.map((p) => Marker(point: LatLng(p.latitude, p.longitude), width: 48, height: 48, child: GestureDetector(onTap: () => PharmacyDetailSheet.show(context, p), child: CircleAvatar(backgroundColor: p.isOnDuty ? AppColors.onDuty : AppColors.pharmacy, child: const Icon(Icons.local_pharmacy, color: Colors.white)))))]), RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')])]);
  }
}

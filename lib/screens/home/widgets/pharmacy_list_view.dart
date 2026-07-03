import 'package:flutter/material.dart';
import '../../../models/pharmacy.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/distance_calculator.dart';
import 'pharmacy_detail_sheet.dart';

class PharmacyListView extends StatelessWidget {
  const PharmacyListView({super.key, required this.pharmacies});
  final List<Pharmacy> pharmacies;
  @override
  Widget build(BuildContext context) => ListView.separated(padding: const EdgeInsets.all(16), itemCount: pharmacies.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, index) { final p = pharmacies[index]; return Card(child: ListTile(minTileHeight: 64, onTap: () => PharmacyDetailSheet.show(context, p), leading: CircleAvatar(backgroundColor: p.isOnDuty ? AppColors.onDuty : AppColors.pharmacy, child: const Icon(Icons.local_pharmacy, color: Colors.white)), title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(DistanceCalculator.label(p.distanceKm)), trailing: const Icon(Icons.chevron_right))); });
}

import 'package:flutter/material.dart';

import '../../../models/pharmacy.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/distance_calculator.dart';
import 'pharmacy_detail_sheet.dart';

class PharmacyListView extends StatelessWidget {
  const PharmacyListView({super.key, required this.pharmacies});

  final List<Pharmacy> pharmacies;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pharmacies.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final pharmacy = pharmacies[index];
        return Card(
          child: ListTile(
            minTileHeight: 64,
            onTap: () => PharmacyDetailSheet.show(context, pharmacy),
            leading: CircleAvatar(
              backgroundColor: pharmacy.isOnDuty ? AppColors.onDuty : AppColors.pharmacy,
              child: const Icon(Icons.local_pharmacy, color: Colors.white),
            ),
            title: Text(pharmacy.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(DistanceCalculator.label(pharmacy.distanceKm)),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

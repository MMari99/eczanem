import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/pharmacy.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/distance_calculator.dart';

class PharmacyDetailSheet extends StatelessWidget {
  const PharmacyDetailSheet({super.key, required this.pharmacy});
  final Pharmacy pharmacy;
  static void show(BuildContext context, Pharmacy pharmacy) => showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => PharmacyDetailSheet(pharmacy: pharmacy));
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [if (pharmacy.isOnDuty) Chip(label: const Text('NÖBETÇİ'), backgroundColor: AppColors.onDuty.withValues(alpha: .12), labelStyle: const TextStyle(color: AppColors.onDuty, fontWeight: FontWeight.w800)), Text(pharmacy.name, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 10), Text(pharmacy.address), if (pharmacy.workingHours?.isNotEmpty == true) Padding(padding: const EdgeInsets.only(top: 8), child: Text(pharmacy.workingHours!)), const SizedBox(height: 8), Text(DistanceCalculator.label(pharmacy.distanceKm)), const SizedBox(height: 16), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: pharmacy.phone.isEmpty ? null : () => launchUrl(Uri.parse('tel:${pharmacy.phone}')), icon: const Icon(Icons.call), label: const Text('Ara'))), const SizedBox(width: 12), Expanded(child: FilledButton.icon(onPressed: () => launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${pharmacy.latitude},${pharmacy.longitude}'), mode: LaunchMode.externalApplication), icon: const Icon(Icons.directions), label: const Text('Yol Tarifi Al')))]),])));
  }
}

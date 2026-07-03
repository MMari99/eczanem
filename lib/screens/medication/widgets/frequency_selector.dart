import 'package:flutter/material.dart';
import '../../../models/medication.dart';

class FrequencySelector extends StatelessWidget {
  const FrequencySelector({super.key, required this.value, required this.onChanged});
  final MedicationFrequency value;
  final ValueChanged<MedicationFrequency> onChanged;
  @override
  Widget build(BuildContext context) => SegmentedButton<MedicationFrequency>(segments: const [ButtonSegment(value: MedicationFrequency.daily, label: Text('Her gün')), ButtonSegment(value: MedicationFrequency.specificDays, label: Text('Belirli günler')), ButtonSegment(value: MedicationFrequency.everyXDays, label: Text('X günde bir'))], selected: {value}, onSelectionChanged: (set) => onChanged(set.first));
}

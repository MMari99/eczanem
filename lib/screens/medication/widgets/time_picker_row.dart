import 'package:flutter/material.dart';
import '../../../utils/date_formatter.dart';

class TimePickerRow extends StatelessWidget {
  const TimePickerRow({super.key, required this.times, required this.onAdd, required this.onRemove});
  final List<TimeOfDay> times;
  final VoidCallback onAdd;
  final ValueChanged<TimeOfDay> onRemove;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Wrap(spacing: 8, runSpacing: 8, children: times.map((time) => InputChip(label: Text(DateFormatter.time(time)), onDeleted: () => onRemove(time))).toList()), const SizedBox(height: 8), OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Saat Ekle'))]);
}

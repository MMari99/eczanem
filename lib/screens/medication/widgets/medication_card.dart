import 'package:flutter/material.dart';
import '../../../models/medication.dart';
import '../../../utils/date_formatter.dart';

class MedicationCard extends StatelessWidget {
  const MedicationCard({super.key, required this.medication, required this.onToggle, required this.onEdit, required this.onDelete});
  final Medication medication;
  final void Function(String key, bool value) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Card(child: InkWell(onLongPress: () => showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Wrap(children: [ListTile(leading: const Icon(Icons.edit), title: const Text('Düzenle'), onTap: () { Navigator.pop(context); onEdit(); }), ListTile(leading: const Icon(Icons.delete_outline), title: const Text('Sil'), onTap: () { Navigator.pop(context); onDelete(); })]))), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(medication.name, style: Theme.of(context).textTheme.titleMedium), if (medication.note?.isNotEmpty == true) Text(medication.note!), const SizedBox(height: 8), ...medication.reminderTimes.map((time) { final key = DateFormatter.logKey(today, time); final taken = medication.takenLog[key] ?? false; return CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(DateFormatter.time(time)), subtitle: Text(taken ? 'Alındı' : 'Bekliyor'), value: taken, onChanged: (v) => onToggle(key, v ?? false)); })]))));
  }
}

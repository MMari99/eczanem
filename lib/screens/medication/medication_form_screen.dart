import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medication.dart';
import '../../providers/medication_provider.dart';
import 'widgets/frequency_selector.dart';
import 'widgets/time_picker_row.dart';

class MedicationFormScreen extends StatefulWidget {
  const MedicationFormScreen({super.key, this.existing});
  final Medication? existing;
  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final noteController = TextEditingController();
  final everyController = TextEditingController(text: '2');
  List<TimeOfDay> times = [];
  MedicationFrequency frequency = MedicationFrequency.daily;
  List<int> selectedDays = [];

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    if (m != null) { nameController.text = m.name; noteController.text = m.note ?? ''; times = [...m.reminderTimes]; frequency = m.frequency; selectedDays = [...?m.specificDays]; everyController.text = (m.everyXDays ?? 2).toString(); }
  }
  @override
  void dispose() { nameController.dispose(); noteController.dispose(); everyController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.existing == null ? 'İlaç Ekle' : 'İlacı Düzenle')), body: SafeArea(child: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(20), children: [TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'İlaç adı'), validator: (v) => v == null || v.trim().isEmpty ? 'Bu alan boş bırakılamaz' : null), const SizedBox(height: 18), Text('Hatırlatma saatleri', style: Theme.of(context).textTheme.titleMedium), TimePickerRow(times: times, onAdd: _addTime, onRemove: (time) => setState(() => times.remove(time))), const SizedBox(height: 18), FrequencySelector(value: frequency, onChanged: (v) => setState(() => frequency = v)), if (frequency == MedicationFrequency.specificDays) _days(), if (frequency == MedicationFrequency.everyXDays) Padding(padding: const EdgeInsets.only(top: 12), child: TextFormField(controller: everyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kaç günde bir?'), validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Geçerli bir sayı girin' : null)), const SizedBox(height: 18), TextFormField(controller: noteController, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Not (opsiyonel)')), const SizedBox(height: 24), FilledButton(onPressed: _save, child: const Text('Kaydet'))]))));
  }
  Widget _days() {
    const labels = {1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cmt', 7: 'Paz'};
    return Padding(padding: const EdgeInsets.only(top: 12), child: Wrap(spacing: 8, children: labels.entries.map((e) => FilterChip(label: Text(e.value), selected: selectedDays.contains(e.key), onSelected: (value) => setState(() { value ? selectedDays.add(e.key) : selectedDays.remove(e.key); }))).toList()));
  }
  Future<void> _addTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => times.add(picked));
  }
  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;
    if (times.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('En az bir hatırlatma saati ekleyin'))); return; }
    if (frequency == MedicationFrequency.specificDays && selectedDays.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('En az bir gün seçin'))); return; }
    final current = widget.existing;
    final medication = Medication(id: current?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), name: nameController.text.trim(), reminderTimes: times, frequency: frequency, specificDays: frequency == MedicationFrequency.specificDays ? selectedDays : null, everyXDays: frequency == MedicationFrequency.everyXDays ? int.parse(everyController.text) : null, note: noteController.text.trim().isEmpty ? null : noteController.text.trim(), createdAt: current?.createdAt ?? DateTime.now(), takenLog: current?.takenLog ?? {});
    await context.read<MedicationProvider>().save(medication);
    if (mounted) Navigator.pop(context);
  }
}

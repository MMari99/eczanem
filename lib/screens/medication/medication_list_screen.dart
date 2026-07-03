import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medication_provider.dart';
import '../shared/empty_state_widget.dart';
import 'medication_form_screen.dart';
import 'widgets/medication_card.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicationProvider>();
    return Scaffold(appBar: AppBar(title: const Text('İlaç Takibi')), body: Column(children: [if (!provider.notificationsAllowed) MaterialBanner(content: const Text('Bildirimler kapalı, hatırlatma alamayabilirsiniz.'), actions: [TextButton(onPressed: () {}, child: const Text('Tamam'))]), Expanded(child: provider.medications.isEmpty ? EmptyStateWidget(message: 'Henüz ilaç eklemediniz', actionLabel: 'İlaç Ekle', onAction: () => _openForm(context)) : ListView.separated(padding: const EdgeInsets.all(16), itemCount: provider.medications.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, index) { final med = provider.medications[index]; return MedicationCard(medication: med, onToggle: (key, value) => provider.toggleTaken(med, key, value), onEdit: () => _openForm(context, medication: med), onDelete: () => provider.delete(med.id)); }))]), floatingActionButton: FloatingActionButton.extended(onPressed: () => _openForm(context), icon: const Icon(Icons.add), label: const Text('İlaç Ekle')));
  }
  void _openForm(BuildContext context, {medication}) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MedicationFormScreen(existing: medication)));
}

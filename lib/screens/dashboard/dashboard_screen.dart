import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/pharmacy_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/distance_calculator.dart';
import '../feedback/feedback_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final app = context.read<AppStateProvider>();
    final city = app.city;
    if (city == null || city.isEmpty) return;
    await context.read<PharmacyProvider>().loadByRegion(city: city, district: app.district);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();
    final pharmacies = context.watch<PharmacyProvider>();
    final meds = context.watch<MedicationProvider>();
    final duty = pharmacies.pharmacies.where((p) => p.isOnDuty).take(4).toList();
    final reminders = meds.medications
        .expand((m) => m.reminderTimes.map((time) => '${m.name} - ${DateFormatter.time(time)}'))
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F5),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HeroHeader(
              name: app.displayName,
              region: app.regionLabel,
              onFeedback: _openFeedback,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetricCard(
                            title: 'Takipteki ilaç',
                            value: '${meds.medications.length}',
                            icon: Icons.medication,
                            color: AppColors.primary,
                          ),
                          _MetricCard(
                            title: 'Bölgendeki nöbetçi',
                            value: pharmacies.loading ? '...' : '${pharmacies.pharmacies.length}',
                            icon: Icons.local_pharmacy,
                            color: AppColors.onDuty,
                          ),
                          _MetricCard(
                            title: 'Seçili bölge',
                            value: app.city ?? '-',
                            icon: Icons.location_on,
                            color: const Color(0xFF386FA4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 820;
                          final panelWidth = wide ? (constraints.maxWidth - 14) / 2 : constraints.maxWidth;
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              _Panel(
                                width: panelWidth,
                                child: _MedicationPreview(
                                  reminders: reminders,
                                  empty: meds.medications.isEmpty,
                                  onTap: () => widget.onOpenTab(2),
                                ),
                              ),
                              _Panel(
                                width: panelWidth,
                                child: _DutyPreview(
                                  loading: pharmacies.loading,
                                  pharmacies: duty,
                                  onTap: () => widget.onOpenTab(1),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _ActionBand(
                        onMap: () => widget.onOpenTab(1),
                        onMedicine: () => widget.onOpenTab(2),
                        onFeedback: _openFeedback,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFeedback() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackScreen()));
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.name, required this.region, required this.onFeedback});

  final String name;
  final String region;
  final VoidCallback onFeedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 42, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF185B4C), Color(0xFF2F9D82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.health_and_safety, color: AppColors.primary, size: 34),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba, $name',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bugünkü ilaçların, seçili bölgen ve nöbetçi eczaneler tek ekranda.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: onFeedback,
                    icon: const Icon(Icons.feedback_outlined),
                    tooltip: 'Geri bildirim',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Chip(label: Text(region), avatar: const Icon(Icons.place, size: 18), backgroundColor: Colors.white),
                  const Chip(label: Text('Günlük veri aktif'), avatar: Icon(Icons.cloud_done, size: 18), backgroundColor: Colors.white),
                  const Chip(label: Text('Harita bölgeye odaklanır'), avatar: Icon(Icons.map, size: 18), backgroundColor: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(padding: const EdgeInsets.all(18), child: child),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: .12), child: Icon(icon, color: color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicationPreview extends StatelessWidget {
  const _MedicationPreview({required this.reminders, required this.empty, required this.onTap});

  final List<String> reminders;
  final bool empty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.medication, title: 'Bugünkü ilaçlar', color: AppColors.primary),
        const SizedBox(height: 12),
        if (empty)
          const _SoftMessage(
            icon: Icons.add_alarm,
            text: 'Henüz ilaç eklenmedi. İlk ilacını ekleyince saatleri burada görünecek.',
          )
        else
          ...reminders.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.schedule),
              title: Text(item),
            ),
          ),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: onTap, icon: const Icon(Icons.add), label: const Text('İlaç ekle / düzenle')),
      ],
    );
  }
}

class _DutyPreview extends StatelessWidget {
  const _DutyPreview({required this.loading, required this.pharmacies, required this.onTap});

  final bool loading;
  final List pharmacies;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.local_pharmacy, title: 'Bu bölgedeki nöbetçi eczaneler', color: AppColors.onDuty),
        const SizedBox(height: 12),
        if (loading)
          const LinearProgressIndicator()
        else if (pharmacies.isEmpty)
          const _SoftMessage(
            icon: Icons.search_off,
            text: 'Bu bölgede kayıt bulunamadı. Merkez seçiliyse il geneli gösterilir; yine boşsa günlük veri yenilenmelidir.',
          )
        else
          ...pharmacies.map(
            (p) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.onDuty,
                child: Icon(Icons.local_pharmacy, color: Colors.white, size: 18),
              ),
              title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(p.address.toString().isEmpty ? DistanceCalculator.label(p.distanceKm) : p.address),
            ),
          ),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: onTap, icon: const Icon(Icons.map), label: const Text('Haritada göster')),
      ],
    );
  }
}

class _ActionBand extends StatelessWidget {
  const _ActionBand({required this.onMap, required this.onMedicine, required this.onFeedback});

  final VoidCallback onMap;
  final VoidCallback onMedicine;
  final VoidCallback onFeedback;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFE7F3EF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const SizedBox(
              width: 320,
              child: Text(
                'Eksik ilçe, hatalı eczane ya da aklına gelen yeni fikir varsa bize bildir. Uygulama gerçek kullanımla güzelleşecek.',
              ),
            ),
            OutlinedButton.icon(onPressed: onMap, icon: const Icon(Icons.map_outlined), label: const Text('Haritaya git')),
            OutlinedButton.icon(onPressed: onMedicine, icon: const Icon(Icons.medication_outlined), label: const Text('İlaçlarım')),
            FilledButton.icon(onPressed: onFeedback, icon: const Icon(Icons.chat_bubble_outline), label: const Text('Geri bildirim yaz')),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, required this.color});

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: .12), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
      ],
    );
  }
}

class _SoftMessage extends StatelessWidget {
  const _SoftMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF6FAF9), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

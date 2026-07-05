import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/pharmacy_provider.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();
    final meds = context.watch<MedicationProvider>();
    final pharmacies = context.watch<PharmacyProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profil ve Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.primaryLight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.displayName, style: Theme.of(context).textTheme.titleMedium),
                        Text(app.isGuest ? 'Misafir hesap' : 'Bağlı profil'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(icon: Icons.place, title: 'Seçili bölge', subtitle: app.regionLabel),
          _SettingsTile(
            icon: Icons.local_pharmacy,
            title: 'Nöbetçi eczane verisi',
            subtitle: pharmacies.usingDailyCache ? 'Günlük veri kullanılıyor' : 'Veri kaynağı bekleniyor',
          ),
          _SettingsTile(
            icon: Icons.medication,
            title: 'İlaç takibi',
            subtitle: meds.medications.isEmpty ? 'Henüz ilaç eklenmedi' : '${meds.medications.length} ilaç kayıtlı',
          ),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Bildirimler',
            subtitle: meds.notificationsAllowed ? 'Hatırlatmalar açık' : 'Bildirim izni kapalı veya webde desteklenmiyor',
          ),
          const _SettingsTile(icon: Icons.security, title: 'Gizlilik', subtitle: 'İlaç bilgileri bu cihazda saklanır'),
          const _SettingsTile(icon: Icons.cloud_sync, title: 'Yedekleme', subtitle: 'Google/Apple bulut yedekleme sonraki aşamada bağlanacak'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: app.signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış yap ve giriş ekranına dön'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        minTileHeight: 64,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

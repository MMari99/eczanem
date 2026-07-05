import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/location_provider.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  int page = 0;
  Map<String, List<String>> cityData = {};
  String? selectedCity;
  String? selectedDistrict;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    controller.dispose();
    firstName.dispose();
    lastName.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    final raw = await rootBundle.loadString('assets/data/il_ilce.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    setState(() {
      cityData = data.map((key, value) => MapEntry(key, (value as List).cast<String>()));
      selectedCity = cityData.keys.isNotEmpty ? cityData.keys.first : null;
      selectedDistrict = cityData[selectedCity]?.first;
    });
  }

  void _next() => controller.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged: (value) => setState(() => page = value),
                children: [_welcome(), _nameStep(), _accountStep(), _regionStep()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= page ? AppColors.primary : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcome() => _Slide(
        step: '1 / 4',
        icon: Icons.local_pharmacy,
        title: 'Eczanem’e hoş geldin',
        text: 'Nöbetçi eczaneler, ilaç saatleri ve seçtiğin bölge tek yerde dursun.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BenefitRow(icon: Icons.map_outlined, text: 'Harita seçtiğin ile odaklanır.'),
            const _BenefitRow(icon: Icons.alarm, text: 'İlaç hatırlatmalarını kaydedebilirsin.'),
            const _BenefitRow(icon: Icons.cloud_done_outlined, text: 'Nöbetçi eczane verisi günde bir kez yenilenir.'),
            const SizedBox(height: 18),
            FilledButton(onPressed: _next, child: const Text('Başlayalım')),
          ],
        ),
      );

  Widget _nameStep() => _Slide(
        step: '2 / 4',
        icon: Icons.badge_outlined,
        title: 'Seni nasıl çağıralım?',
        text: 'Ana sayfa ve profil ekranı sana özel görünsün diye adını kaydedelim.',
        child: Column(
          children: [
            TextField(controller: firstName, decoration: const InputDecoration(labelText: 'Ad')),
            const SizedBox(height: 12),
            TextField(controller: lastName, decoration: const InputDecoration(labelText: 'Soyad')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await context.read<AppStateProvider>().saveName(first: firstName.text, last: lastName.text);
                  _next();
                },
                child: const Text('Devam et'),
              ),
            ),
          ],
        ),
      );

  Widget _accountStep() => _Slide(
        step: '3 / 4',
        icon: Icons.login,
        title: 'Giriş yöntemini seç',
        text: 'Şimdilik hesap seçenekleri hazırlık modunda. İstersen misafir olarak da devam edebilirsin.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LoginButton(label: 'Google ile devam et', icon: Icons.g_mobiledata, onTap: _placeholderLogin),
            _LoginButton(label: 'Apple ile devam et', icon: Icons.apple, onTap: _placeholderLogin),
            _LoginButton(label: 'Facebook ile devam et', icon: Icons.facebook, onTap: _placeholderLogin),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () async {
                await context.read<AppStateProvider>().continueAsGuest();
                _next();
              },
              child: const Text('Hesap bağlamadan misafir devam et'),
            ),
          ],
        ),
      );

  Widget _regionStep() {
    final app = context.watch<AppStateProvider>();
    final location = context.watch<LocationProvider>();
    return _Slide(
      step: '4 / 4',
      icon: Icons.map_outlined,
      title: 'Bölgeni seç',
      text: 'İl ve ilçeyi seçince harita sadece o bölgeye odaklanır. Konum izni zorunlu değil.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedCity,
            decoration: const InputDecoration(labelText: 'İl'),
            items: cityData.keys.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
            onChanged: (value) => setState(() {
              selectedCity = value;
              selectedDistrict = cityData[value]?.first;
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(selectedCity),
            initialValue: selectedDistrict,
            decoration: const InputDecoration(labelText: 'İlçe'),
            items: (cityData[selectedCity] ?? const <String>[])
                .map((district) => DropdownMenuItem(value: district, child: Text(district)))
                .toList(),
            onChanged: (value) => setState(() => selectedDistrict = value),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: location.loading ? null : () => context.read<LocationProvider>().load(),
            icon: const Icon(Icons.my_location),
            label: Text(location.loading ? 'Konum deneniyor...' : 'Konumumu kullan'),
          ),
          if (location.message != null && location.position == null)
            Padding(padding: const EdgeInsets.only(top: 8), child: Text(location.message!)),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: app.signedIn && selectedCity != null
                ? () => app.saveRegion(selectedCity: selectedCity!, selectedDistrict: selectedDistrict)
                : null,
            child: const Text('Uygulamaya gir'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeholderLogin() async {
    await context.read<AppStateProvider>().continueWithGooglePlaceholder();
    _next();
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.step, required this.icon, required this.title, required this.text, required this.child});

  final String step;
  final IconData icon;
  final String title;
  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF185B4C), Color(0xFF39A98D)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(icon, size: 32, color: AppColors.primary)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(text, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 22),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 17, backgroundColor: AppColors.primaryLight, child: Icon(icon, size: 18, color: AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 54), alignment: Alignment.centerLeft),
      ),
    );
  }
}

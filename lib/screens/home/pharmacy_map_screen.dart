import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/pharmacy_provider.dart';
import '../shared/error_state_widget.dart';
import '../shared/loading_widget.dart';
import 'widgets/map_list_toggle_button.dart';
import 'widgets/map_search_bar.dart';
import 'widgets/pharmacy_list_view.dart';
import 'widgets/pharmacy_map_view.dart';

class PharmacyMapScreen extends StatefulWidget {
  const PharmacyMapScreen({super.key});
  @override
  State<PharmacyMapScreen> createState() => _PharmacyMapScreenState();
}

class _PharmacyMapScreenState extends State<PharmacyMapScreen> {
  LatLng? center;
  String city = 'İstanbul';
  String? district;
  Map<String, List<String>> cityData = {};

  @override
  void initState() { super.initState(); _loadCities(); WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap()); }
  Future<void> _loadCities() async { final raw = await rootBundle.loadString('assets/data/il_ilce.json'); final data = jsonDecode(raw) as Map<String, dynamic>; setState(() => cityData = data.map((k, v) => MapEntry(k, (v as List).cast<String>()))); }
  Future<void> _bootstrap() async {
    final location = context.read<LocationProvider>();
    if (location.position != null) {
      center = LatLng(location.position!.latitude, location.position!.longitude);
      await context.read<PharmacyProvider>().loadByLocation(latitude: center!.latitude, longitude: center!.longitude);
      setState(() {});
    }
  }
  Future<void> _loadManual() async {
    center = const LatLng(41.0082, 28.9784);
    await context.read<PharmacyProvider>().loadByLocation(latitude: center!.latitude, longitude: center!.longitude, city: city, district: district);
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final pharmacy = context.watch<PharmacyProvider>();
    if (location.loading && center == null) return const LoadingWidget(message: 'Konum alınıyor...');
    if (location.position != null && center == null && !pharmacy.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
    }
    if (location.position == null && center == null) return _manualLocation(location);
    final mapCenter = center ?? LatLng(location.position!.latitude, location.position!.longitude);
    return Scaffold(appBar: AppBar(title: const Text('Eczanem'), actions: [MapListToggleButton(showList: pharmacy.showList, onPressed: pharmacy.toggleView), const SizedBox(width: 8)]), body: Stack(children: [if (pharmacy.loading) const LoadingWidget(message: 'Eczaneler aranıyor...') else if (pharmacy.error != null) ErrorStateWidget(message: pharmacy.error!, onRetry: () => _loadManual()) else if (pharmacy.showList) PharmacyListView(pharmacies: pharmacy.pharmacies) else PharmacyMapView(center: mapCenter, pharmacies: pharmacy.pharmacies), Positioned(left: 12, right: 12, top: 12, child: MapSearchBar(onSearch: (_) => _loadManual()))]));
  }
  Widget _manualLocation(LocationProvider location) => Scaffold(appBar: AppBar(title: const Text('İl / İlçe Seç')), body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [if (location.deniedForever) ErrorStateWidget(message: 'Konum izni kalıcı reddedilmiş. Ayarlardan açabilirsiniz.', actionLabel: 'Ayarlara Git', onRetry: location.openSettings), DropdownButtonFormField<String>(value: cityData.containsKey(city) ? city : null, decoration: const InputDecoration(labelText: 'İl'), items: cityData.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() { city = v ?? city; district = null; })), const SizedBox(height: 12), DropdownButtonFormField<String>(value: district, decoration: const InputDecoration(labelText: 'İlçe'), items: (cityData[city] ?? const <String>[]).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => district = v)), const SizedBox(height: 20), FilledButton(onPressed: _loadManual, child: const Text('Eczaneleri Göster'))])));
}

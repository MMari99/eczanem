import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRegion());
  }

  Future<void> _loadRegion() async {
    final app = context.read<AppStateProvider>();
    if (app.city == null) return;
    await context.read<PharmacyProvider>().loadByRegion(city: app.city!, district: app.district);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();
    final pharmacy = context.watch<PharmacyProvider>();
    final center = LatLng(pharmacy.centerLatitude ?? 39.0, pharmacy.centerLongitude ?? 35.0);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.regionLabel),
        actions: [MapListToggleButton(showList: pharmacy.showList, onPressed: pharmacy.toggleView), const SizedBox(width: 8)],
      ),
      body: Stack(children: [
        if (pharmacy.loading)
          const LoadingWidget(message: 'Eczaneler hazırlanıyor...')
        else if (pharmacy.error != null)
          ErrorStateWidget(message: pharmacy.error!, onRetry: _loadRegion)
        else if (pharmacy.showList)
          PharmacyListView(pharmacies: pharmacy.pharmacies)
        else
          PharmacyMapView(center: center, pharmacies: pharmacy.pharmacies),
        Positioned(left: 12, right: 12, top: 12, child: MapSearchBar(onSearch: (_) => _loadRegion())),
      ]),
    );
  }
}

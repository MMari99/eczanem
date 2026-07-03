import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'models/medication.dart';
import 'models/pharmacy.dart';
import 'navigation/main_navigation_shell.dart';
import 'providers/location_provider.dart';
import 'providers/medication_provider.dart';
import 'providers/pharmacy_provider.dart';
import 'services/cached_pharmacy_data_service.dart';
import 'services/eczane_api_service.dart';
import 'services/location_service.dart';
import 'services/medication_storage_service.dart';
import 'services/notification_service.dart';
import 'services/overpass_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('tr_TR');
  await Hive.initFlutter();
  Hive
    ..registerAdapter(PharmacyAdapter())
    ..registerAdapter(MedicationFrequencyAdapter())
    ..registerAdapter(MedicationAdapter())
    ..registerAdapter(TimeOfDayAdapter());
  await Hive.openBox<Medication>(MedicationStorageService.boxName);
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(EczanemApp(notificationService: notificationService));
}

class EczanemApp extends StatelessWidget {
  const EczanemApp({super.key, required this.notificationService});
  final NotificationService notificationService;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider(LocationService())..load()),
        ChangeNotifierProvider(create: (_) => PharmacyProvider(EczaneApiService(), OverpassService(), CachedPharmacyDataService())),
        ChangeNotifierProvider(create: (_) => MedicationProvider(MedicationStorageService(), notificationService)..load()),
      ],
      child: MaterialApp(title: 'Eczanem', debugShowCheckedModeBanner: false, theme: AppTheme.light(), home: const MainNavigationShell()),
    );
  }
}

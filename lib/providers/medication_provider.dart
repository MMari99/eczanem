import 'package:flutter/foundation.dart';
import '../models/medication.dart';
import '../services/medication_storage_service.dart';
import '../services/notification_service.dart';

class MedicationProvider extends ChangeNotifier {
  MedicationProvider(this._storage, this._notifications);
  final MedicationStorageService _storage;
  final NotificationService _notifications;
  List<Medication> medications = [];
  bool notificationsAllowed = true;

  Future<void> load() async {
    medications = await _storage.all();
    await _notifications.rescheduleEveryXDaysIfNeeded(medications);
    notifyListeners();
  }

  Future<void> save(Medication medication) async {
    notificationsAllowed = await _notifications.requestPermission();
    await _storage.save(medication);
    if (notificationsAllowed) await _notifications.scheduleMedication(medication);
    await load();
  }

  Future<void> delete(String id) async {
    await _notifications.cancelMedication(id);
    await _storage.delete(id);
    await load();
  }

  Future<void> toggleTaken(Medication medication, String key, bool value) async {
    final log = Map<String, bool>.from(medication.takenLog)..[key] = value;
    await _storage.save(medication.copyWith(takenLog: log));
    await load();
  }
}

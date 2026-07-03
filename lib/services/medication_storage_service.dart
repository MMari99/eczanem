import 'package:hive/hive.dart';
import '../models/medication.dart';

class MedicationStorageService {
  static const boxName = 'medications';
  Future<Box<Medication>> get _box async => Hive.isBoxOpen(boxName) ? Hive.box<Medication>(boxName) : Hive.openBox<Medication>(boxName);
  Future<List<Medication>> all() async => (await _box).values.toList();
  Future<void> save(Medication medication) async => (await _box).put(medication.id, medication);
  Future<void> delete(String id) async => (await _box).delete(id);
}

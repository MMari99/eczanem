import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'medication.g.dart';

@HiveType(typeId: 2)
enum MedicationFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  specificDays,
  @HiveField(2)
  everyXDays,
}

@HiveType(typeId: 3)
class Medication {
  Medication({required this.id, required this.name, required this.reminderTimes, required this.frequency, this.specificDays, this.everyXDays, this.note, required this.createdAt, required this.takenLog});

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<TimeOfDay> reminderTimes;
  @HiveField(3)
  final MedicationFrequency frequency;
  @HiveField(4)
  final List<int>? specificDays;
  @HiveField(5)
  final int? everyXDays;
  @HiveField(6)
  final String? note;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final Map<String, bool> takenLog;

  Medication copyWith({String? id, String? name, List<TimeOfDay>? reminderTimes, MedicationFrequency? frequency, List<int>? specificDays, int? everyXDays, String? note, DateTime? createdAt, Map<String, bool>? takenLog}) {
    return Medication(id: id ?? this.id, name: name ?? this.name, reminderTimes: reminderTimes ?? this.reminderTimes, frequency: frequency ?? this.frequency, specificDays: specificDays ?? this.specificDays, everyXDays: everyXDays ?? this.everyXDays, note: note ?? this.note, createdAt: createdAt ?? this.createdAt, takenLog: takenLog ?? this.takenLog);
  }
}

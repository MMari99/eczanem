// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'medication.dart';

class MedicationFrequencyAdapter extends TypeAdapter<MedicationFrequency> {
  @override
  final int typeId = 2;
  @override
  MedicationFrequency read(BinaryReader reader) {
    final index = reader.readByte();
    if (index < 0 || index >= MedicationFrequency.values.length) return MedicationFrequency.daily;
    return MedicationFrequency.values[index];
  }
  @override
  void write(BinaryWriter writer, MedicationFrequency obj) => writer.writeByte(obj.index);
}

class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 4;
  @override
  TimeOfDay read(BinaryReader reader) => TimeOfDay(hour: reader.readInt(), minute: reader.readInt());
  @override
  void write(BinaryWriter writer, TimeOfDay obj) => writer..writeInt(obj.hour)..writeInt(obj.minute);
}

class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final int typeId = 3;
  @override
  Medication read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Medication(id: f[0] as String, name: f[1] as String, reminderTimes: (f[2] as List).cast<TimeOfDay>(), frequency: f[3] as MedicationFrequency, specificDays: (f[4] as List?)?.cast<int>(), everyXDays: f[5] as int?, note: f[6] as String?, createdAt: f[7] as DateTime, takenLog: (f[8] as Map).cast<String, bool>());
  }
  @override
  void write(BinaryWriter writer, Medication obj) {
    writer..writeByte(9)..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.name)..writeByte(2)..write(obj.reminderTimes)..writeByte(3)..write(obj.frequency)..writeByte(4)..write(obj.specificDays)..writeByte(5)..write(obj.everyXDays)..writeByte(6)..write(obj.note)..writeByte(7)..write(obj.createdAt)..writeByte(8)..write(obj.takenLog);
  }
}

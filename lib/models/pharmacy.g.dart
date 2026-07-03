// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'pharmacy.dart';

class PharmacyAdapter extends TypeAdapter<Pharmacy> {
  @override
  final int typeId = 1;
  @override
  Pharmacy read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Pharmacy(id: f[0] as String, name: f[1] as String, address: f[2] as String, phone: f[3] as String, latitude: f[4] as double, longitude: f[5] as double, isOnDuty: f[6] as bool, workingHours: f[7] as String?, distanceKm: f[8] as double?, city: f[9] as String?, district: f[10] as String?);
  }
  @override
  void write(BinaryWriter writer, Pharmacy obj) {
    writer..writeByte(11)..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.name)..writeByte(2)..write(obj.address)..writeByte(3)..write(obj.phone)..writeByte(4)..write(obj.latitude)..writeByte(5)..write(obj.longitude)..writeByte(6)..write(obj.isOnDuty)..writeByte(7)..write(obj.workingHours)..writeByte(8)..write(obj.distanceKm)..writeByte(9)..write(obj.city)..writeByte(10)..write(obj.district);
  }
}

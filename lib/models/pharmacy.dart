import 'package:hive/hive.dart';

part 'pharmacy.g.dart';

@HiveType(typeId: 1)
class Pharmacy {
  Pharmacy({required this.id, required this.name, required this.address, required this.phone, required this.latitude, required this.longitude, required this.isOnDuty, this.workingHours, this.distanceKm, this.city, this.district});

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String address;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final double latitude;
  @HiveField(5)
  final double longitude;
  @HiveField(6)
  final bool isOnDuty;
  @HiveField(7)
  final String? workingHours;
  @HiveField(8)
  double? distanceKm;
  @HiveField(9)
  final String? city;
  @HiveField(10)
  final String? district;
}

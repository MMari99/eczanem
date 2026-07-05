import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class AppStateProvider extends ChangeNotifier {
  AppStateProvider(this._box) {
    _load();
  }

  static const boxName = 'app_settings';
  final Box _box;

  bool ready = false;
  bool signedIn = false;
  bool isGuest = true;
  String displayName = 'Misafir';
  String firstName = '';
  String lastName = '';
  String? city;
  String? district;

  bool get hasRegion => city != null && city!.isNotEmpty;
  bool get canEnterApp => signedIn && hasRegion;
  String get regionLabel => district?.isNotEmpty == true ? '$city / $district' : city ?? 'Bölge seçilmedi';

  void _load() {
    signedIn = _box.get('signedIn', defaultValue: false) as bool;
    isGuest = _box.get('isGuest', defaultValue: true) as bool;
    displayName = _box.get('displayName', defaultValue: 'Misafir') as String;
    firstName = _box.get('firstName', defaultValue: '') as String;
    lastName = _box.get('lastName', defaultValue: '') as String;
    city = _box.get('city') as String?;
    district = _box.get('district') as String?;
    ready = true;
  }

  Future<void> saveName({required String first, required String last}) async {
    firstName = first.trim();
    lastName = last.trim();
    displayName = [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
    if (displayName.isEmpty) displayName = 'Misafir';
    await _box.putAll({'firstName': firstName, 'lastName': lastName, 'displayName': displayName});
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    signedIn = true;
    isGuest = true;
    if (displayName.isEmpty || displayName == 'Google Kullanıcısı') displayName = 'Misafir';
    await _box.putAll({'signedIn': true, 'isGuest': true, 'displayName': displayName});
    notifyListeners();
  }

  Future<void> continueWithGooglePlaceholder() async {
    signedIn = true;
    isGuest = false;
    if (displayName.isEmpty || displayName == 'Misafir') displayName = 'Google Kullanıcısı';
    await _box.putAll({'signedIn': true, 'isGuest': false, 'displayName': displayName});
    notifyListeners();
  }

  Future<void> saveRegion({required String selectedCity, String? selectedDistrict}) async {
    city = selectedCity;
    district = selectedDistrict;
    await _box.putAll({'city': city, 'district': district});
    notifyListeners();
  }

  Future<void> signOut() async {
    signedIn = false;
    isGuest = true;
    displayName = 'Misafir';
    await _box.putAll({'signedIn': false, 'isGuest': true, 'displayName': displayName});
    notifyListeners();
  }
}

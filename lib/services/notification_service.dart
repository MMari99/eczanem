import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medication.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const channelId = 'medication_reminders';

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final zoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zoneName));
    } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(const AndroidNotificationChannel(channelId, 'İlaç Hatırlatmaları', description: 'İlaç saatleri için yerel hatırlatmalar', importance: Importance.high));
  }

  Future<bool> requestPermission() async {
    final android = await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    final ios = await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? true;
  }

  Future<void> scheduleMedication(Medication medication) async {
    await cancelMedication(medication.id);
    for (final time in medication.reminderTimes) {
      final id = _id(medication.id, time);
      final details = const NotificationDetails(android: AndroidNotificationDetails(channelId, 'İlaç Hatırlatmaları', importance: Importance.high, priority: Priority.high), iOS: DarwinNotificationDetails());
      final when = _next(time, medication);
      await _plugin.zonedSchedule(id, 'İlaç Vakti 💊', medication.note?.isNotEmpty == true ? '${medication.name} - ${medication.note}' : medication.name, when, details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, matchDateTimeComponents: _match(medication), payload: medication.id);
    }
  }

  Future<void> cancelMedication(String medicationId) async {
    for (var i = 0; i < 24 * 60; i++) {
      await _plugin.cancel(medicationId.hashCode ^ i);
    }
  }

  Future<void> rescheduleEveryXDaysIfNeeded(List<Medication> medications) async {
    for (final medication in medications.where((m) => m.frequency == MedicationFrequency.everyXDays)) {
      await scheduleMedication(medication);
    }
  }

  DateTimeComponents? _match(Medication medication) {
    switch (medication.frequency) {
      case MedicationFrequency.daily:
        return DateTimeComponents.time;
      case MedicationFrequency.specificDays:
        return DateTimeComponents.dayOfWeekAndTime;
      case MedicationFrequency.everyXDays:
        return null;
    }
  }

  tz.TZDateTime _next(TimeOfDay time, Medication medication) {
    var scheduled = tz.TZDateTime(tz.local, DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) scheduled = scheduled.add(const Duration(days: 1));
    if (medication.frequency == MedicationFrequency.specificDays && medication.specificDays?.isNotEmpty == true) {
      while (!medication.specificDays!.contains(scheduled.weekday)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }
    if (medication.frequency == MedicationFrequency.everyXDays) {
      final step = medication.everyXDays ?? 1;
      while (scheduled.difference(medication.createdAt).inDays % step != 0) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }
    return scheduled;
  }

  int _id(String medicationId, TimeOfDay time) => medicationId.hashCode ^ (time.hour * 60 + time.minute);
}

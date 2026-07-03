import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();
  static final _date = DateFormat('yyyy-MM-dd', 'tr_TR');
  static String logKey(DateTime day, TimeOfDay time) => '${_date.format(day)}_${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  static String time(TimeOfDay value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

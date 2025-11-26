import 'package:flutter/material.dart';

enum ShiftType { day, night, off }

class DailySchedule {
  final DateTime date;
  final ShiftType shiftType;
  final TimeOfDay? shiftStart;
  final TimeOfDay? shiftEnd;

  DailySchedule({
    required this.date,
    required this.shiftType,
    this.shiftStart,
    this.shiftEnd,
  });
}

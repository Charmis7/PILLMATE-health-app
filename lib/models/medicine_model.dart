import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IntakeSlot {
  final TimeOfDay time;
  final int       dose;
  final String    label;

  const IntakeSlot({
    required this.time,
    required this.dose,
    required this.label,
  });
//d->f
  Map<String, dynamic> toMap() => {
    'hour'  : time.hour,
    'minute': time.minute,
    'dose'  : dose,
    'label' : label,
  };
//f->d
  factory IntakeSlot.fromMap(Map<String, dynamic> m) => IntakeSlot(
    time : TimeOfDay(hour: m['hour'], minute: m['minute']),
    dose : m['dose'],
    label: m['label'],
  );
}

class MedicineEntry {
  final String           id;
  final String           name;
  final String           unit;
  final String           condition;
  final String           frequency;
  final DateTime         startDate;
  final List<IntakeSlot> intakes;
  final List<String>     takenDates;

  const MedicineEntry({
    required this.id,
    required this.name,
    required this.unit,
    required this.condition,
    required this.frequency,
    required this.startDate,
    required this.intakes,
    this.takenDates = const [],
  });

  bool isTakenToday() {
    final today =
        '${DateTime.now().year}-'
        '${DateTime.now().month.toString().padLeft(2, '0')}-'
        '${DateTime.now().day.toString().padLeft(2, '0')}';
    return takenDates.contains(today);
  }

  //d->f
  Map<String, dynamic> toMap() => {
    'name'      : name,
    'unit'      : unit,
    'condition' : condition,
    'frequency' : frequency,
    'startDate' : Timestamp.fromDate(startDate),
    'intakes'   : intakes.map((i) => i.toMap()).toList(),
    'takenDates': takenDates,
  };

  //f->d
  factory MedicineEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicineEntry(
      id        : doc.id,
      name      : data['name']      ?? '',
      unit      : data['unit']      ?? '',
      condition : data['condition'] ?? '',
      frequency : data['frequency'] ?? '',
      startDate : (data['startDate'] as Timestamp).toDate(),
      intakes   : (data['intakes'] as List)
          .map((i) => IntakeSlot.fromMap(i as Map<String, dynamic>))
          .toList(),
      takenDates: List<String>.from(data['takenDates'] ?? []),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IntakeSlot {
  final TimeOfDay time;
  final int dose;
  final String label;

  const IntakeSlot({
    required this.time,
    required this.dose,
    required this.label,
  });

  Map<String, dynamic> toMap() => {
    'hour': time.hour,
    'minute': time.minute,
    'dose': dose,
    'label': label,
  };

  factory IntakeSlot.fromMap(Map<String, dynamic> map) => IntakeSlot(
    time: TimeOfDay(hour: map['hour'], minute: map['minute']),
    dose: map['dose'],
    label: map['label'],
  );
}

class MedicineEntry {
  final String id;         // Firestore doc ID
  final String name;
  final String unit;
  final String condition;
  final String frequency;
  final DateTime startDate;
  final List<IntakeSlot> intakes;
  final List<String> takenDates; // list of "yyyy-MM-dd" when marked taken

  MedicineEntry({
    required this.id,
    required this.name,
    required this.unit,
    required this.condition,
    required this.frequency,
    required this.startDate,
    required this.intakes,
    this.takenDates = const [],
  });

  // Check if taken today
  bool isTakenToday() {
    final today = _dateKey(DateTime.now());
    return takenDates.contains(today);
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
    'name': name,
    'unit': unit,
    'condition': condition,
    'frequency': frequency,
    'startDate': Timestamp.fromDate(startDate),
    'intakes': intakes.map((i) => i.toMap()).toList(),
    'takenDates': takenDates,
  };

  factory MedicineEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicineEntry(
      id: doc.id,
      name: data['name'] ?? '',
      unit: data['unit'] ?? '',
      condition: data['condition'] ?? '',
      frequency: data['frequency'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      intakes: (data['intakes'] as List)
          .map((i) => IntakeSlot.fromMap(i))
          .toList(),
      takenDates: List<String>.from(data['takenDates'] ?? []),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackerEntry {
  final String id;
  final String title;       // e.g. "Walking" or "Blood pressure"
  final String type;        // "activity" or "measurement"
  final String frequency;
  final List<TimeOfDay> times;

  TrackerEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.frequency,
    required this.times,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'type': type,
    'frequency': frequency,
    'times': times.map((t) => {'hour': t.hour, 'minute': t.minute}).toList(),
  };

  factory TrackerEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrackerEntry(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      frequency: data['frequency'] ?? '',
      times: (data['times'] as List)
          .map((t) => TimeOfDay(hour: t['hour'], minute: t['minute']))
          .toList(),
    );
  }
}
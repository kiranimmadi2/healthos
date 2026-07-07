import 'package:flutter/material.dart';

class DoctorPatient {
  const DoctorPatient({
    required this.id,
    required this.name,
    required this.initials,
    required this.age,
    required this.gender,
    required this.condition,
    required this.carePlan,
    required this.lastVisit,
    required this.color,
    this.needsFollowUp = false,
  });

  final String id;
  final String name;
  final String initials;
  final int age;
  final String gender;
  final String condition;
  final String carePlan;
  final String lastVisit;
  final Color color;
  final bool needsFollowUp;
}

class DiagnosticReport {
  const DiagnosticReport({
    required this.id,
    required this.type,
    required this.patient,
    required this.ordered,
    required this.summary,
    required this.status,
    required this.priority,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String id;
  final String type;
  final String patient;
  final String ordered;
  final String summary;
  final String status;
  final String priority;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}

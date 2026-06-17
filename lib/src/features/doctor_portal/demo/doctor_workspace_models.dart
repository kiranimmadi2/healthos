import 'package:flutter/material.dart';

class DoctorAppointment {
  const DoctorAppointment({
    required this.time,
    required this.name,
    required this.reason,
    required this.type,
    required this.status,
    required this.initials,
    required this.color,
    required this.statusColor,
    required this.statusBackground,
  });

  final String time;
  final String name;
  final String reason;
  final String type;
  final String status;
  final String initials;
  final Color color;
  final Color statusColor;
  final Color statusBackground;
}

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

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    required this.sentByDoctor,
  });

  final String text;
  final String time;
  final bool sentByDoctor;
}

class Conversation {
  const Conversation({
    required this.name,
    required this.initials,
    required this.role,
    required this.preview,
    required this.time,
    required this.color,
    required this.messages,
    this.unread = 0,
    this.online = false,
  });

  final String name;
  final String initials;
  final String role;
  final String preview;
  final String time;
  final Color color;
  final List<ChatMessage> messages;
  final int unread;
  final bool online;
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

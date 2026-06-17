import 'package:flutter/material.dart';

class HealthDestination {
  const HealthDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

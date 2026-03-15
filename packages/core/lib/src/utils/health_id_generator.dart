import 'dart:math';

import 'package:core/src/constants/app_constants.dart';

class HealthIdGenerator {
  HealthIdGenerator._();

  static final _random = Random.secure();
  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String generate() {
    final year = DateTime.now().year;
    final suffix = List.generate(
      4,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
    return '${AppConstants.healthIdPrefix}-$year-$suffix';
  }

  static bool isValid(String healthId) {
    return RegExp(AppConstants.healthIdPattern).hasMatch(healthId);
  }

  static String format(String rawId) {
    final cleaned = rawId.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.length < 11) return rawId;
    return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7, 11)}';
  }
}

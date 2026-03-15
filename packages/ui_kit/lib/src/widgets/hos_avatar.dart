import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HosAvatar extends StatelessWidget {
  const HosAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
  });

  final String? imageUrl;
  final String? name;
  final double radius;

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

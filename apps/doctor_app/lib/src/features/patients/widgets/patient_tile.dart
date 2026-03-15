import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A list tile that shows patient name, health ID, and last visit date.
class PatientTile extends StatelessWidget {
  const PatientTile({
    super.key,
    required this.patient,
    this.lastVisitDate,
    this.isSelected = false,
    this.onTap,
  });

  final Patient patient;
  final DateTime? lastVisitDate;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withOpacity(0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: AppSpacing.listItemPadding,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
              bottom: const BorderSide(
                color: AppColors.divider,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              HosAvatar(
                name: patient.fullName ?? 'Unknown',
                imageUrl: patient.avatarUrl,
                radius: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName ?? 'Unknown Patient',
                      style: AppTypography.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        HosHealthIdBadge(healthId: patient.healthId),
                      ],
                    ),
                    if (lastVisitDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Last visit: ${AppDateUtils.timeAgo(lastVisitDate!)}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

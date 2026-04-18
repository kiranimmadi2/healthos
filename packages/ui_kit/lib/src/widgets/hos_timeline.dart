import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'hos_card.dart';

/// Vertical timeline with a connecting line, colored dot per entry, and
/// a card for the content. Used on PatientDetail timeline tab, Home activity,
/// and family-member activity.
class HosTimeline extends StatelessWidget {
  const HosTimeline({
    super.key,
    required this.entries,
  });

  final List<HosTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _Row(
            entry: entries[i],
            isFirst: i == 0,
            isLast: i == entries.length - 1,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final HosTimelineEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = entry.dotColor ?? theme.colorScheme.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                SizedBox(
                  height: 18,
                  child: isFirst
                      ? const SizedBox()
                      : Center(
                          child: Container(
                            width: 2,
                            color: theme.dividerColor,
                          ),
                        ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: theme.dividerColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 4,
                bottom: isLast ? 0 : AppSpacing.md,
              ),
              child: HosCard(
                onTap: entry.onTap,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(entry.title, style: AppTypography.h4),
                        ),
                        if (entry.trailing != null) entry.trailing!,
                      ],
                    ),
                    if (entry.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.subtitle!,
                        style: AppTypography.caption,
                      ),
                    ],
                    if (entry.body != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      entry.body!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HosTimelineEntry {
  const HosTimelineEntry({
    required this.title,
    this.subtitle,
    this.body,
    this.trailing,
    this.dotColor,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? body;
  final Widget? trailing;
  final Color? dotColor;
  final VoidCallback? onTap;
}

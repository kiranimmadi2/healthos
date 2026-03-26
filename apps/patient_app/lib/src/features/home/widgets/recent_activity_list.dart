import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/recent_activity_provider.dart';

class RecentActivityList extends ConsumerWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);

    return activityAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const HosCard(
            child: HosEmptyState(
              message: 'No recent activity',
              icon: Icons.history,
            ),
          );
        }
        return Column(
          children: items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: HosCard(
              onTap: item.routePath != null
                  ? () => context.go(item.routePath!)
                  : null,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: AppTypography.label),
                        Text(item.subtitle, style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Text(
                    AppDateUtils.formatDate(item.date),
                    style: AppTypography.caption,
                  ),
                  if (item.routePath != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
                  ],
                ],
              ),
            ),
          )).toList(),
        );
      },
      loading: () => const HosLoading(),
      error: (error, _) => HosError(
        message: error.toString(),
        onRetry: () => ref.invalidate(recentActivityProvider),
      ),
    );
  }
}

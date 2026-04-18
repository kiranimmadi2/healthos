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
            child: SizedBox(
              height: 180,
              child: HosEmptyState(
                icon: HosIcons.pending,
                title: 'No recent activity',
                message: 'Visits, lab results, and appointments will appear here.',
              ),
            ),
          );
        }
        return Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: HosCard(
                    onTap: item.routePath != null
                        ? () => context.go(item.routePath!)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.borderRadiusSm),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: AppTypography.label),
                              const SizedBox(height: 2),
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
                          const Icon(
                            HosIcons.forward,
                            size: HosIcons.sizeSm,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
      loading: () => Column(
        children: const [
          HosSkeletonListTile(),
          SizedBox(height: AppSpacing.sm),
          HosSkeletonListTile(),
          SizedBox(height: AppSpacing.sm),
          HosSkeletonListTile(),
        ],
      ),
      error: (error, _) => HosError(
        message: error.toString(),
        onRetry: () => ref.invalidate(recentActivityProvider),
      ),
    );
  }
}

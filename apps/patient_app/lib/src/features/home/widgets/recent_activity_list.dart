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
        return HosCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    color: AppColors.divider,
                    height: 1,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: items[i].routePath != null
                        ? () => context.go(items[i].routePath!)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: items[i].color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.borderRadiusSm),
                            ),
                            child: Icon(items[i].icon,
                                color: items[i].color, size: 18),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(items[i].title,
                                    style: AppTypography.label),
                                const SizedBox(height: 2),
                                Text(items[i].subtitle,
                                    style: AppTypography.caption),
                              ],
                            ),
                          ),
                          Text(
                            AppDateUtils.formatDate(items[i].date),
                            style: AppTypography.caption,
                          ),
                          if (items[i].routePath != null) ...[
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
                ),
              ],
            ],
          ),
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

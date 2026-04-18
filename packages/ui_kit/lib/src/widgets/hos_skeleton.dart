import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shimmer skeleton loaders. Use these instead of `CircularProgressIndicator`
/// for list/card loading states so the layout doesn't jump when data arrives.
class HosSkeleton extends StatelessWidget {
  const HosSkeleton.box({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = AppSpacing.borderRadiusSm,
  }) : _kind = _Kind.box;

  const HosSkeleton.line({
    super.key,
    this.width = double.infinity,
    this.height = 12,
    this.radius = 6,
  }) : _kind = _Kind.line;

  const HosSkeleton.circle({
    super.key,
    double size = 40,
  })  : width = size,
        height = size,
        radius = size / 2,
        _kind = _Kind.circle;

  final double width;
  final double height;
  final double radius;
  final _Kind _kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final base = isDark ? AppColors.darkDivider : AppColors.divider;
    final highlight = isDark
        ? AppColors.darkDivider.withValues(alpha: 0.6)
        : AppColors.background;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
          shape: _kind == _Kind.circle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

enum _Kind { box, line, circle }

/// Composite skeleton that mimics a list row: circle avatar + 2 text lines.
class HosSkeletonListTile extends StatelessWidget {
  const HosSkeletonListTile({super.key, this.withAvatar = true});

  final bool withAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          if (withAvatar) ...[
            const HosSkeleton.circle(size: 44),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                HosSkeleton.line(width: 160, height: 14),
                SizedBox(height: AppSpacing.xs),
                HosSkeleton.line(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Composite skeleton that mimics a card (title + body lines + footer chip).
class HosSkeletonCard extends StatelessWidget {
  const HosSkeletonCard({super.key, this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HosSkeleton.box(width: 180, height: 18),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < lines; i++) ...[
            HosSkeleton.line(
              width: i == lines - 1 ? 140 : double.infinity,
              height: 12,
            ),
            if (i < lines - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

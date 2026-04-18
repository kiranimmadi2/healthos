import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standard rounded-top bottom sheet wrapper with a grabber handle.
/// Use this instead of raw `showModalBottomSheet` to keep the visual style
/// (grabber, padding, sharp-scroll behavior) identical across all apps.
Future<T?> showHosBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isScrollControlled = true,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: Colors.transparent,
    builder: (ctx) => HosBottomSheet(title: title, child: child),
  );
}

class HosBottomSheet extends StatelessWidget {
  const HosBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.padding,
  });

  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.borderRadiusXl),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            // Grabber
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: AppTypography.h4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: Padding(
                padding:
                    padding ?? const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

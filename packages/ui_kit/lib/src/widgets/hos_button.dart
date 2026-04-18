import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum HosButtonVariant { primary, secondary, tertiary, destructive }

enum HosButtonSize { sm, md, lg }

/// Core button for the HealthOS design system.
///
/// Prefer the named factories — `HosButton.primary`, `.secondary`, `.tertiary`,
/// `.destructive`, `.icon` — for new code. The positional default constructor
/// is kept for legacy callers and maps to the primary/secondary variants via
/// the `isOutlined` flag.
class HosButton extends StatelessWidget {
  const HosButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.iconRight,
    this.width,
    this.size = HosButtonSize.md,
    this.expand = false,
    HosButtonVariant? variant,
  }) : _variant = variant;

  const HosButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconRight,
    this.isLoading = false,
    this.width,
    this.size = HosButtonSize.md,
    this.expand = false,
  })  : isOutlined = false,
        _variant = HosButtonVariant.primary;

  const HosButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconRight,
    this.isLoading = false,
    this.width,
    this.size = HosButtonSize.md,
    this.expand = false,
  })  : isOutlined = true,
        _variant = HosButtonVariant.secondary;

  const HosButton.tertiary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconRight,
    this.isLoading = false,
    this.width,
    this.size = HosButtonSize.md,
    this.expand = false,
  })  : isOutlined = false,
        _variant = HosButtonVariant.tertiary;

  const HosButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconRight,
    this.isLoading = false,
    this.width,
    this.size = HosButtonSize.md,
    this.expand = false,
  })  : isOutlined = false,
        _variant = HosButtonVariant.destructive;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final IconData? iconRight;
  final double? width;
  final HosButtonSize size;
  final bool expand;
  final HosButtonVariant? _variant;

  HosButtonVariant get _effectiveVariant =>
      _variant ??
      (isOutlined ? HosButtonVariant.secondary : HosButtonVariant.primary);

  double get _height => switch (size) {
        HosButtonSize.sm => 40,
        HosButtonSize.md => 48,
        HosButtonSize.lg => 56,
      };

  EdgeInsetsGeometry get _padding => switch (size) {
        HosButtonSize.sm => const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        HosButtonSize.md => const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        HosButtonSize.lg => const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variant = _effectiveVariant;

    final Color foreground = switch (variant) {
      HosButtonVariant.primary => AppColors.white,
      HosButtonVariant.secondary => theme.colorScheme.primary,
      HosButtonVariant.tertiary => theme.colorScheme.primary,
      HosButtonVariant.destructive => AppColors.white,
    };

    final child = isLoading
        ? SizedBox(
            height: HosIcons.sizeMd,
            width: HosIcons.sizeMd,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: HosIcons.sizeMd),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (iconRight != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(iconRight, size: HosIcons.sizeMd),
              ],
            ],
          );

    final ButtonStyle style = switch (variant) {
      HosButtonVariant.primary => ElevatedButton.styleFrom(
          minimumSize: Size(0, _height),
          padding: _padding,
          foregroundColor: AppColors.white,
          backgroundColor: theme.colorScheme.primary,
          disabledBackgroundColor: AppColors.disabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
        ),
      HosButtonVariant.secondary => OutlinedButton.styleFrom(
          minimumSize: Size(0, _height),
          padding: _padding,
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
        ),
      HosButtonVariant.tertiary => TextButton.styleFrom(
          minimumSize: Size(0, _height),
          padding: _padding,
          foregroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
        ),
      HosButtonVariant.destructive => ElevatedButton.styleFrom(
          minimumSize: Size(0, _height),
          padding: _padding,
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.error,
          disabledBackgroundColor: AppColors.disabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          ),
        ),
    };

    final Widget button = switch (variant) {
      HosButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        ),
      HosButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        ),
      HosButtonVariant.tertiary => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        ),
      HosButtonVariant.destructive => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        ),
    };

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// Square icon-only button used across the apps for AppBar actions,
/// inline controls, and compact toolbars. Ensures a consistent hit target
/// and icon size everywhere.
class HosIconButton extends StatelessWidget {
  const HosIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 40,
    this.iconSize,
    this.color,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double? iconSize;
  final Color? color;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;
    final button = SizedBox(
      width: size,
      height: size,
      child: IconButton(
        icon: Icon(icon, size: iconSize ?? HosIcons.sizeMd),
        onPressed: onPressed,
        tooltip: tooltip,
        color: effectiveColor,
        padding: EdgeInsets.zero,
      ),
    );

    if (badgeCount == null || badgeCount == 0) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            alignment: Alignment.center,
            child: Text(
              badgeCount! > 99 ? '99+' : '$badgeCount',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

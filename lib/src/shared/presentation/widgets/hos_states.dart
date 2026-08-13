import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../domain/app_failure.dart';

/// Set to false in tests. Repeating animations (shimmer, typing dots) never
/// settle, so `pumpAndSettle()` hangs forever while they run.
///
/// Override in a test with:
/// `ProviderScope(overrides: [hosMotionEnabledProvider.overrideWithValue(false)])`
final hosMotionEnabledProvider = Provider<bool>((ref) => true);

/// Whether repeating decorative animation should run in this subtree.
///
/// Falls back to "on" when no [ProviderScope] is in scope, so these widgets
/// stay usable outside the app's provider tree.
bool hosMotionEnabled(BuildContext context) {
  try {
    return ProviderScope.containerOf(
      context,
      listen: false,
    ).read(hosMotionEnabledProvider);
  } catch (_) {
    return true;
  }
}

/// Placeholder shown when a list or panel has no content *and no error*.
///
/// Replaces five near-identical private implementations that had drifted apart.
class HosEmptyState extends StatelessWidget {
  const HosEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.compact = false,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// Optional call to action, e.g. a button or a row of suggestion chips.
  final Widget? action;

  /// Tighter spacing for use inside a card or dialog rather than a full page.
  final bool compact;

  /// Overrides the medallion tint. Defaults to the brand colour.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;
    final theme = Theme.of(context);
    final tint = accent ?? hos.brand;
    final medallion = compact ? 64.0 : 100.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: medallion,
              height: medallion,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [hos.brandSoft, hos.surfaceMuted],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tint.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, size: compact ? 30 : 48, color: tint),
            ),
            SizedBox(height: compact ? 16 : 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: (compact
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.headlineSmall)
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: hos.textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hos.textMuted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: compact ? 16 : 28),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Failure placeholder.
///
/// Never renders the raw exception in release — screens previously showed
/// `Text('Error: $e')`, leaking internals into a medical UI. The underlying
/// error stays visible in debug builds only.
class HosErrorState extends StatelessWidget {
  const HosErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
    this.compact = false,
  });

  final Object? error;
  final VoidCallback? onRetry;
  final String? title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;
    final detail = debugDetail(error);

    return HosEmptyState(
      compact: compact,
      accent: hos.dangerFg,
      icon: Icons.cloud_off_rounded,
      title: title ?? 'Something went wrong',
      message: describeFailure(error),
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null)
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          if (detail != null) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                detail,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: hos.textMuted,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One shimmering placeholder block.
class HosSkeleton extends StatelessWidget {
  const HosSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  const HosSkeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = 0,
        shape = BoxShape.circle;

  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;
    final block = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: hos.surfaceMuted,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
      ),
    );

    if (!hosMotionEnabled(context)) return block;

    return block
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: hos.surfaceElevated,
        );
  }
}

/// Placeholder shaped like a typical list card: leading avatar, two text lines.
class HosSkeletonCard extends StatelessWidget {
  const HosSkeletonCard({super.key, this.hasLeading = true});

  final bool hasLeading;

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hos.glassFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: hos.glassBorder, width: 1.5),
      ),
      child: Row(
        children: [
          if (hasLeading) ...[
            const HosSkeleton(width: 56, height: 56, borderRadius: 18),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HosSkeleton(width: 160, height: 14),
                const SizedBox(height: 10),
                const HosSkeleton(width: 100, height: 12),
                const SizedBox(height: 10),
                HosSkeleton(width: 220, height: 12, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A short run of [HosSkeletonCard]s, for list loading states.
class HosSkeletonList extends StatelessWidget {
  const HosSkeletonList({
    super.key,
    this.count = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.itemBuilder,
  });

  final int count;
  final EdgeInsetsGeometry padding;
  final Widget Function(BuildContext, int)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: count,
      itemBuilder: itemBuilder ?? (_, __) => const HosSkeletonCard(),
    );
  }
}

/// Three pulsing dots, shown while the AI assistant is composing a reply.
class HosTypingIndicator extends StatefulWidget {
  const HosTypingIndicator({super.key, this.label});

  final String? label;

  @override
  State<HosTypingIndicator> createState() => _HosTypingIndicatorState();
}

class _HosTypingIndicatorState extends State<HosTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    // Deferred so the ProviderScope lookup has a mounted element to walk.
    // Left un-started when motion is disabled, which keeps pumpAndSettle from
    // hanging on this never-ending animation in tests.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && hosMotionEnabled(context)) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hos = context.hos;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.only(right: i == 2 ? 0 : 6),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = Interval(
                  i * 0.2,
                  0.6 + i * 0.2,
                  curve: Curves.easeInOut,
                ).transform(_controller.value);
                final wave = (t <= 0.5 ? t : 1 - t) * 2;
                return Transform.translate(
                  offset: Offset(0, -3 * wave),
                  child: Opacity(opacity: 0.4 + 0.6 * wave, child: child),
                );
              },
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: hos.brand,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        if (widget.label != null) ...[
          const SizedBox(width: 12),
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: hos.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// Renders an [AsyncValue] with consistent loading and error treatment.
///
/// Collapses the repeated `.when(loading:, error:, data:)` blocks — and their
/// inconsistent error handling — into a single call.
extension HosAsyncValueX<T> on AsyncValue<T> {
  Widget hosWhen({
    required Widget Function(T value) data,
    Widget Function()? loading,
    VoidCallback? onRetry,
    String? errorTitle,
    bool compact = false,
  }) {
    return when(
      data: data,
      loading: loading ?? () => const HosSkeletonList(),
      error: (error, _) => HosErrorState(
        error: error,
        onRetry: onRetry,
        title: errorTitle,
        compact: compact,
      ),
    );
  }
}

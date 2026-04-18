import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Multi-action floating button. Tapping the FAB toggles open a stacked list
/// of labeled mini-actions (reverse-chronological bottom-up).
class HosSpeedDial extends StatefulWidget {
  const HosSpeedDial({
    super.key,
    required this.actions,
    this.icon = HosIcons.add,
    this.activeIcon = HosIcons.close,
    this.tooltip,
  });

  final List<HosSpeedDialAction> actions;
  final IconData icon;
  final IconData activeIcon;
  final String? tooltip;

  @override
  State<HosSpeedDial> createState() => _HosSpeedDialState();
}

class _HosSpeedDialState extends State<HosSpeedDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  bool _open = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < widget.actions.length; i++)
          AnimatedOpacity(
            opacity: _open ? 1 : 0,
            duration: Duration(milliseconds: 150 + i * 50),
            child: IgnorePointer(
              ignoring: !_open,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.borderRadiusSm),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.actions[i].label,
                        style: AppTypography.label,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FloatingActionButton.small(
                      heroTag: 'hsd_${widget.actions[i].label}',
                      onPressed: () {
                        _toggle();
                        widget.actions[i].onPressed();
                      },
                      backgroundColor:
                          widget.actions[i].color ?? theme.colorScheme.secondary,
                      foregroundColor: AppColors.white,
                      child: Icon(widget.actions[i].icon, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        FloatingActionButton(
          heroTag: 'hsd_main',
          onPressed: _toggle,
          tooltip: widget.tooltip,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: AppColors.white,
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 220),
            child: Icon(_open ? widget.activeIcon : widget.icon),
          ),
        ),
      ],
    );
  }
}

class HosSpeedDialAction {
  const HosSpeedDialAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
}

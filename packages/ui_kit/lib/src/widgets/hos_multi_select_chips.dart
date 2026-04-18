import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Multi-select wrap of chips — used for allergies, conditions, tags.
/// Pairs well with a "Add custom" free-text sibling widget if needed.
class HosMultiSelectChips extends StatelessWidget {
  const HosMultiSelectChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.label,
    this.helperText,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final String? label;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
        ],
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(option),
                selected: selected.contains(option),
                showCheckmark: false,
                avatar: selected.contains(option)
                    ? Icon(HosIcons.success,
                        size: 16, color: theme.colorScheme.primary)
                    : null,
                onSelected: (isSelected) {
                  final next = Set<String>.from(selected);
                  if (isSelected) {
                    next.add(option);
                  } else {
                    next.remove(option);
                  }
                  onChanged(next);
                },
              ),
          ],
        ),
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(helperText!, style: AppTypography.caption),
        ],
      ],
    );
  }
}

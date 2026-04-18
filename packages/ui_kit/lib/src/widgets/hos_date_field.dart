import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A date picker field with the DS outlined-input look.
/// Call via `HosDateField(label: 'DOB', value: ..., onChanged: ...)`.
class HosDateField extends StatelessWidget {
  const HosDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hint,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hint;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = value == null
        ? (hint ?? 'Select date')
        : '${_monthShort(value!.month)} ${value!.day}, ${value!.year}';
    final hasValue = value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: enabled ? () => _pick(context) : null,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              prefixIcon: const Icon(HosIcons.calendar, size: HosIcons.sizeMd),
              enabled: enabled,
            ),
            child: Text(
              formatted,
              style: AppTypography.bodyMedium.copyWith(
                color: hasValue
                    ? theme.textTheme.bodyMedium?.color
                    : theme.hintColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(now.year + 10),
    );
    if (picked != null) onChanged(picked);
  }

  static String _monthShort(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m - 1];
  }
}

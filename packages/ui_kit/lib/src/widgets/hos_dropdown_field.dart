import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Dropdown form field with the DS outlined-input look.
/// `options` is a map: display label → value of type [T].
class HosDropdownField<T> extends StatelessWidget {
  const HosDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final T? value;
  final List<HosDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            enabled: enabled,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item.value,
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(item.icon, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTypography.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class HosDropdownItem<T> {
  const HosDropdownItem({required this.label, required this.value, this.icon});

  final String label;
  final T value;
  final IconData? icon;
}

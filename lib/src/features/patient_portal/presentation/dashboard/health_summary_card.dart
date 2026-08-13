part of 'dashboard_content.dart';

class _HealthSummaryCard extends ConsumerWidget {
  const _HealthSummaryCard();

  /// Patient-facing wording for a BMI band. Deliberately gentler than the
  /// clinical wording used in the AI prompt ("Normal weight").
  static const _bmiLabels = {
    BmiCategory.underweight: 'Underweight',
    BmiCategory.normal: 'Healthy',
    BmiCategory.overweight: 'Overweight',
    BmiCategory.obese: 'Obese',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final height = profile?.heightCm;
    final weight = profile?.weightKg;
    final bmi = profile?.bmi;
    final bmiStatus = _bmiLabels[profile?.bmiCategory] ?? '—';

    return GlassContainer(
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Personal vital indicators',
            style: TextStyle(color: context.hos.textMuted, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.xl),
          _MetricRow(
            icon: Icons.straighten_rounded,
            iconColor: AppColors.primary,
            label: 'Height',
            value: height != null ? '${height.toStringAsFixed(0)} cm' : '—',
            status: '',
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(
            icon: Icons.scale_rounded,
            iconColor: AppColors.secondary,
            label: 'Weight',
            value: weight != null ? '${weight.toStringAsFixed(0)} kg' : '—',
            status: '',
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(
            icon: Icons.monitor_heart_rounded,
            iconColor: AppColors.error,
            label: 'BMI',
            value: bmi != null ? bmi.toStringAsFixed(1) : '—',
            status: bmiStatus,
          ),
        ],
      ),
    );
  }
}


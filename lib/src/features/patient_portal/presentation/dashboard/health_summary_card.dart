part of 'dashboard_content.dart';

class _HealthSummaryCard extends ConsumerWidget {
  const _HealthSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final height = (profile?['height'] as num?)?.toDouble();
    final weight = (profile?['weight'] as num?)?.toDouble();
    double? bmi;
    if (height != null && weight != null && height > 0) {
      final heightM = height / 100;
      bmi = weight / (heightM * heightM);
    }

    String bmiStatus = '—';
    if (bmi != null) {
      bmiStatus = bmi < 18.5
          ? 'Underweight'
          : bmi < 25
          ? 'Healthy'
          : bmi < 30
          ? 'Overweight'
          : 'Obese';
    }

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
          const Text(
            'Personal vital indicators',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
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


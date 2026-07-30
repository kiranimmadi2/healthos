import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';

/// Design System Icon Facade
class HosIcons {
  static const IconData medical = Icons.medical_services_rounded;
  static const IconData stethoscope = Icons.health_and_safety_rounded;
  static const IconData pill = Icons.medication_rounded;
  static const IconData fileText = Icons.description_rounded;
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData user = Icons.person_rounded;
  static const IconData userAdd = Icons.person_add_rounded;
  static const IconData alertCircle = Icons.error_outline_rounded;
  static const IconData activity = Icons.monitor_heart_rounded;
  static const IconData shield = Icons.shield_rounded;
  static const IconData check = Icons.check_circle_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData hospital = Icons.local_hospital_rounded;
  static const IconData clock = Icons.access_time_rounded;
  static const IconData settings = Icons.settings_rounded;
}

/// Sleek animated loading spinner
class HosLoading extends StatelessWidget {
  const HosLoading({
    super.key,
    this.size = 24.0,
    this.color = AppColors.primary,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

/// Responsive Stat Card for Metrics & Dashboards
class HosStatCard extends StatelessWidget {
  const HosStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor = AppColors.primary,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vitals Card displaying vital parameters
class HosVitalsCard extends StatelessWidget {
  const HosVitalsCard({
    super.key,
    required this.heartRate,
    required this.bloodPressure,
    required this.spo2,
    this.temperature,
  });

  final String heartRate;
  final String bloodPressure;
  final String spo2;
  final String? temperature;

  @override
  Widget build(BuildContext context) {
    final vitals = [
      ('Heart Rate', heartRate, HosIcons.activity, AppColors.error),
      ('Blood Pressure', bloodPressure, HosIcons.stethoscope, AppColors.primary),
      ('SpO2', spo2, HosIcons.medical, AppColors.secondary),
      if (temperature != null)
        ('Temperature', temperature!, HosIcons.alertCircle, AppColors.warning),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: vitals.map((v) {
          return Column(
            children: [
              Icon(v.$3, color: v.$4, size: 20),
              const SizedBox(height: 4),
              Text(
                v.$2,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                v.$1,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Prescription Summary Card Component
class HosPrescriptionCard extends StatelessWidget {
  const HosPrescriptionCard({
    super.key,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.notes,
  });

  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primarySoft,
                child: Icon(HosIcons.pill, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  medicationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Dosage: $dosage · Frequency: $frequency',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Instructions: $notes',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

/// Timeline Item Data Model
class HosTimelineItem {
  HosTimelineItem({
    required this.title,
    required this.subtitle,
    required this.date,
    this.icon = HosIcons.calendar,
    this.color = AppColors.primary,
  });

  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color color;
}

/// Interactive Timeline Component
class HosTimeline extends StatelessWidget {
  const HosTimeline({
    super.key,
    required this.items,
  });

  final List<HosTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: item.color.withValues(alpha: 0.15),
                  child: Icon(item.icon, color: item.color, size: 14),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    color: AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          item.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Responsive Data Table Component
class HosDataTable<T> extends StatelessWidget {
  const HosDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.rowBuilder,
  });

  final List<String> columns;
  final List<T> data;
  final List<Widget> Function(T item) rowBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.background),
          columns: columns
              .map(
                (col) => DataColumn(
                  label: Text(
                    col,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          rows: data.map((item) {
            final cells = rowBuilder(item);
            return DataRow(
              cells: cells.map((w) => DataCell(w)).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

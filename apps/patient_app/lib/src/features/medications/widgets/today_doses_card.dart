import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';
import '../providers/medications_provider.dart';

/// Compact card shown on the home feed listing today's upcoming doses with
/// "Mark taken" buttons.
class TodayDosesCard extends ConsumerWidget {
  const TodayDosesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doses = ref.watch(todayDosesProvider);
    final logs = ref.watch(todayLogMapProvider);

    return doses.when(
      loading: () => const HosSkeletonCard(lines: 2),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        final theme = Theme.of(context);
        return HosCard(
          onTap: () => context.go('/medications'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(HosIcons.prescription,
                      size: HosIcons.sizeSm, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Today\'s medications',
                        style: AppTypography.h4),
                  ),
                  Text(
                    '${items.length} doses',
                    style: AppTypography.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...items.take(3).map((d) {
                return logs.maybeWhen(
                  data: (m) => _DoseRow(dose: d, log: m[d.key]),
                  orElse: () => _DoseRow(dose: d, log: null),
                );
              }),
              if (items.length > 3) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '+${items.length - 3} more',
                  style: AppTypography.caption.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DoseRow extends ConsumerWidget {
  const _DoseRow({required this.dose, required this.log});

  final TodayDose dose;
  final MedicationLog? log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = log?.status ?? 'pending';
    final h = dose.scheduledAt.hour;
    final m = dose.scheduledAt.minute;
    final time =
        '${(h == 0 ? 12 : h > 12 ? h - 12 : h).toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} ${h >= 12 ? 'PM' : 'AM'}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _statusColor(status),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dose.schedule.drugName,
                  style: AppTypography.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${dose.schedule.dosage} · $time',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          if (status == 'pending')
            HosButton.tertiary(
              label: 'Mark taken',
              size: HosButtonSize.sm,
              onPressed: () => _mark(ref, 'taken'),
            )
          else
            HosStatusChip(
              label: _statusLabel(status),
              color: _statusColor(status),
              icon: status == 'taken' ? HosIcons.success : HosIcons.close,
            ),
        ],
      ),
    );
  }

  Future<void> _mark(WidgetRef ref, String status) async {
    final patient = ref.read(currentPatientProvider).valueOrNull;
    if (patient == null) return;
    final repo = ref.read(medicationRepoProvider);
    await repo.logDose(
      scheduleId: dose.schedule.id,
      patientId: patient.id,
      scheduledAt: dose.scheduledAt,
      status: status,
    );
    ref.invalidate(todayLogMapProvider);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'taken':
        return AppColors.success;
      case 'skipped':
      case 'missed':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'taken':
        return 'Taken';
      case 'skipped':
        return 'Skipped';
      case 'missed':
        return 'Missed';
      default:
        return 'Pending';
    }
  }
}

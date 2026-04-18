import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/medications_provider.dart';
import '../widgets/today_doses_card.dart';

class MedicationsListScreen extends ConsumerWidget {
  const MedicationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activeSchedulesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: const Text('Medications'),
        actions: [
          HosIconButton(
            icon: HosIcons.add,
            tooltip: 'Add medication',
            onPressed: () => context.go('/medications/add'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeSchedulesProvider);
          ref.invalidate(todayDosesProvider);
          ref.invalidate(todayLogMapProvider);
        },
        child: async.when(
          loading: () => ListView(
            padding: AppSpacing.screenPadding,
            children: const [
              HosSkeletonCard(lines: 3),
              SizedBox(height: AppSpacing.md),
              HosSkeletonCard(lines: 2),
              SizedBox(height: AppSpacing.md),
              HosSkeletonCard(lines: 2),
            ],
          ),
          error: (e, _) => HosError(
            message: e.toString(),
            onRetry: () => ref.invalidate(activeSchedulesProvider),
          ),
          data: (schedules) {
            if (schedules.isEmpty) {
              return HosEmptyState(
                icon: HosIcons.prescription,
                title: 'No active medications',
                message: 'Add a medication schedule to start tracking doses '
                    'and get reminders.',
                actionLabel: 'Add medication',
                actionIcon: HosIcons.add,
                onAction: () => context.go('/medications/add'),
              );
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screenPadding,
              children: [
                const TodayDosesCard(),
                const SizedBox(height: AppSpacing.lg),
                Text('Active medications', style: AppTypography.h4),
                const SizedBox(height: AppSpacing.sm),
                ...schedules.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ScheduleCard(schedule: s),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  const _ScheduleCard({required this.schedule});

  final MedicationSchedule schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HosPrescriptionCard(
      drugName: schedule.drugName,
      dosage: schedule.dosage,
      frequency: _frequencyLabel(schedule),
      duration: schedule.endedOn == null
          ? null
          : 'until ${_fmt(schedule.endedOn!)}',
      instructions: schedule.instructions,
      trailing: PopupMenuButton<String>(
        icon: const Icon(HosIcons.more, size: HosIcons.sizeMd),
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'stop',
            child: Text('Stop schedule'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
        onSelected: (action) async {
          final repo = ref.read(medicationRepoProvider);
          if (action == 'stop') {
            await repo.stopSchedule(schedule.id);
          } else if (action == 'delete') {
            await repo.deleteSchedule(schedule.id);
          }
          ref.invalidate(activeSchedulesProvider);
          ref.invalidate(todayDosesProvider);
        },
      ),
    );
  }

  String _frequencyLabel(MedicationSchedule s) {
    if (s.doseTimes.isEmpty) return 'As needed';
    final count = s.doseTimes.length;
    if (s.weekdays.isEmpty || s.weekdays.length == 7) {
      return '$count× daily · at ${s.doseTimes.join(', ')}';
    }
    return '$count× on ${s.weekdays.length} days';
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
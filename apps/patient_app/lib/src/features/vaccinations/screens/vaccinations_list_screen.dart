import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/vaccinations_provider.dart';

class VaccinationsListScreen extends ConsumerWidget {
  const VaccinationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vaccinationsProvider);
    final upcoming = ref.watch(upcomingVaccinationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: const Text('Vaccinations'),
        actions: [
          HosIconButton(
            icon: HosIcons.add,
            tooltip: 'Add vaccine',
            onPressed: () => context.go('/vaccinations/add'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(vaccinationsProvider);
          ref.invalidate(upcomingVaccinationsProvider);
        },
        child: async.when(
          loading: () => ListView(
            padding: AppSpacing.screenPadding,
            children: const [
              HosSkeletonListTile(),
              HosSkeletonListTile(),
              HosSkeletonListTile(),
            ],
          ),
          error: (e, _) => HosError(
            message: e.toString(),
            onRetry: () => ref.invalidate(vaccinationsProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return HosEmptyState(
                icon: HosIcons.injection,
                title: 'No vaccinations recorded',
                message: 'Keep your immunisation record in one place.',
                actionLabel: 'Add vaccine',
                actionIcon: HosIcons.add,
                onAction: () => context.go('/vaccinations/add'),
              );
            }
            final upList = upcoming.valueOrNull ?? const [];
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screenPadding,
              children: [
                if (upList.isNotEmpty) ...[
                  Text('Upcoming due', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  ...upList.map((v) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _NextDueCard(vaccination: v),
                      )),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text('History', style: AppTypography.h4),
                const SizedBox(height: AppSpacing.sm),
                HosTimeline(
                  entries: items
                      .map(
                        (v) => HosTimelineEntry(
                          title: v.vaccineName,
                          subtitle: DateFormat.yMMMd().format(v.dateGiven),
                          dotColor: AppColors.secondary,
                          body: _bodyFor(v),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget? _bodyFor(Vaccination v) {
    final lines = <String>[];
    if (v.doseNumber != null && v.totalDoses != null) {
      lines.add('Dose ${v.doseNumber} of ${v.totalDoses}');
    }
    if (v.manufacturer != null) lines.add(v.manufacturer!);
    if (v.administeredAt != null) lines.add('at ${v.administeredAt}');
    if (v.lotNumber != null) lines.add('Lot ${v.lotNumber}');
    if (lines.isEmpty) return null;
    return Text(lines.join(' · '),
        style: AppTypography.caption);
  }
}

class _NextDueCard extends StatelessWidget {
  const _NextDueCard({required this.vaccination});
  final Vaccination vaccination;

  @override
  Widget build(BuildContext context) {
    final due = vaccination.nextDue!;
    final daysAway = due.difference(DateTime.now()).inDays;
    final urgent = daysAway <= 14;
    return HosCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (urgent ? AppColors.warning : AppColors.secondary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(HosIcons.injection,
                color: urgent ? AppColors.warning : AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vaccination.vaccineName, style: AppTypography.label),
                const SizedBox(height: 2),
                Text(
                  'Due ${DateFormat.yMMMd().format(due)} '
                  '(${daysAway <= 0 ? 'overdue' : 'in $daysAway days'})',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          HosStatusChip(
            label: urgent ? 'Due soon' : 'Upcoming',
            color: urgent ? AppColors.warning : AppColors.info,
            icon: urgent ? HosIcons.warning : HosIcons.pending,
          ),
        ],
      ),
    );
  }
}
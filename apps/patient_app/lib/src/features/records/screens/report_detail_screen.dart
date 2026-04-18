import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/reports_provider.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  ConsumerState<ReportDetailScreen> createState() =>
      _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  int _selectedBiomarker = 0;

  @override
  Widget build(BuildContext context) {
    final biomarkersAsync =
        ref.watch(reportBiomarkersProvider(widget.reportId));

    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: const Text('Report details'),
        actions: [
          HosIconButton(
            icon: HosIcons.share,
            tooltip: 'Share',
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: biomarkersAsync.when(
        loading: () => ListView(
          padding: AppSpacing.screenPadding,
          children: const [
            HosSkeletonCard(lines: 2),
            SizedBox(height: AppSpacing.md),
            HosSkeleton.box(height: 220),
            SizedBox(height: AppSpacing.md),
            HosSkeletonListTile(withAvatar: false),
            HosSkeletonListTile(withAvatar: false),
            HosSkeletonListTile(withAvatar: false),
          ],
        ),
        error: (error, _) => HosError(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(reportBiomarkersProvider(widget.reportId)),
        ),
        data: (biomarkers) {
          if (biomarkers.isEmpty) {
            return const HosEmptyState(
              icon: HosIcons.labReport,
              title: 'No biomarker data',
              message: 'This report hasn\'t been processed yet.',
            );
          }

          // Group by biomarker name for tabbed trend view.
          final grouped = <String, List<Biomarker>>{};
          for (final b in biomarkers) {
            grouped.putIfAbsent(b.name, () => []).add(b);
          }
          final names = grouped.keys.toList();
          final safeIndex = _selectedBiomarker.clamp(0, names.length - 1);
          final activeName = names[safeIndex];
          final activeSet = grouped[activeName]!;
          final latest = activeSet.first;

          final abnormalCount =
              biomarkers.where((b) => !b.isNormal).length;

          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              _SummaryCard(
                total: biomarkers.length,
                abnormal: abnormalCount,
                recordedAt: biomarkers.first.recordedAt,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (names.length > 1) ...[
                Text('Select biomarker', style: AppTypography.h4),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: names.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.xs),
                    itemBuilder: (ctx, i) {
                      final n = names[i];
                      final selected = i == safeIndex;
                      return ChoiceChip(
                        label: Text(n),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedBiomarker = i),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _BiomarkerHeader(biomarker: latest),
              const SizedBox(height: AppSpacing.md),
              HosCard(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: BiomarkerLineChart(
                  biomarkers: activeSet.reversed.toList(), // chronological
                  height: 220,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('All biomarkers', style: AppTypography.h4),
              const SizedBox(height: AppSpacing.sm),
              ...biomarkers.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _BiomarkerRow(biomarker: b),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.abnormal,
    required this.recordedAt,
  });

  final int total;
  final int abnormal;
  final DateTime recordedAt;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            ),
            child:
                const Icon(HosIcons.labReport, color: AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$total biomarkers',
                    style: AppTypography.h4),
                Text(DateFormat.yMMMd().format(recordedAt),
                    style: AppTypography.caption),
              ],
            ),
          ),
          if (abnormal > 0)
            HosStatusChip(
              label: '$abnormal abnormal',
              color: AppColors.error,
              icon: HosIcons.warning,
            )
          else
            HosStatusChip(
              label: 'All normal',
              color: AppColors.success,
              icon: HosIcons.success,
            ),
        ],
      ),
    );
  }
}

class _BiomarkerHeader extends StatelessWidget {
  const _BiomarkerHeader({required this.biomarker});
  final Biomarker biomarker;

  @override
  Widget build(BuildContext context) {
    final color = biomarker.isNormal
        ? AppColors.biomarkerNormal
        : biomarker.isHigh
            ? AppColors.biomarkerHigh
            : AppColors.biomarkerLow;
    return HosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(biomarker.name, style: AppTypography.h3),
              ),
              HosStatusChip(
                label: biomarker.statusLabel,
                color: color,
                icon: biomarker.isNormal
                    ? HosIcons.success
                    : HosIcons.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            text: TextSpan(
              style: AppTypography.h1.copyWith(color: color, height: 1.1),
              children: [
                TextSpan(text: biomarker.value.toStringAsFixed(1)),
                if (biomarker.unit != null)
                  TextSpan(
                    text: ' ${biomarker.unit!}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reference range: ${biomarker.referenceRange}',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _BiomarkerRow extends StatelessWidget {
  const _BiomarkerRow({required this.biomarker});
  final Biomarker biomarker;

  @override
  Widget build(BuildContext context) {
    final color = biomarker.isNormal
        ? AppColors.biomarkerNormal
        : biomarker.isHigh
            ? AppColors.biomarkerHigh
            : AppColors.biomarkerLow;
    return HosCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(biomarker.name, style: AppTypography.label),
                const SizedBox(height: 2),
                Text('Ref: ${biomarker.referenceRange}',
                    style: AppTypography.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                biomarker.displayValue,
                style: AppTypography.h4.copyWith(color: color),
              ),
              const SizedBox(height: 2),
              HosStatusChip(
                label: biomarker.statusLabel,
                color: color,
                icon: biomarker.isNormal
                    ? HosIcons.success
                    : HosIcons.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
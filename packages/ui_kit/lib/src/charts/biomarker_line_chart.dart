import 'package:core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class BiomarkerLineChart extends StatelessWidget {
  const BiomarkerLineChart({
    super.key,
    required this.biomarkers,
    this.height = 250,
    this.showNormalRange = true,
  });

  final List<Biomarker> biomarkers;
  final double height;
  final bool showNormalRange;

  @override
  Widget build(BuildContext context) {
    if (biomarkers.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No data available')),
      );
    }

    final spots = biomarkers.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final minY = biomarkers.map((b) => b.value).reduce((a, b) => a < b ? a : b) * 0.8;
    final maxY = biomarkers.map((b) => b.value).reduce((a, b) => a > b ? a : b) * 1.2;

    final normalMin = biomarkers.first.normalMin;
    final normalMax = biomarkers.first.normalMax;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md, top: AppSpacing.sm),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.divider,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < biomarkers.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          AppDateUtils.formatDate(biomarkers[index].recordedAt),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            rangeAnnotations: showNormalRange && normalMin != null && normalMax != null
                ? RangeAnnotations(
                    horizontalRangeAnnotations: [
                      HorizontalRangeAnnotation(
                        y1: normalMin,
                        y2: normalMax,
                        color: AppColors.biomarkerNormal.withValues(alpha: 0.1),
                      ),
                    ],
                  )
                : null,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    final biomarker = biomarkers[index];
                    final color = biomarker.isNormal
                        ? AppColors.biomarkerNormal
                        : biomarker.isHigh
                            ? AppColors.biomarkerHigh
                            : AppColors.biomarkerLow;
                    return FlDotCirclePainter(
                      radius: 4,
                      color: color,
                      strokeWidth: 2,
                      strokeColor: AppColors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

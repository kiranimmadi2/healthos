import 'package:flutter/material.dart';

import '../icons/hos_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'hos_empty_state.dart';
import 'hos_skeleton.dart';

/// Web-friendly data table used across hospital_portal and lab_portal.
/// Wraps Flutter's `DataTable` with a search bar + filter slot + empty/loading
/// states and DS-consistent header styling.
class HosDataTable extends StatefulWidget {
  const HosDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.searchEnabled = true,
    this.searchHint = 'Search…',
    this.searchMatcher,
    this.onSearchChanged,
    this.trailingFilter,
    this.emptyTitle = 'No results',
    this.emptyMessage,
    this.rowsPerPage = 20,
    this.onRowTap,
  });

  final List<HosDataColumn> columns;
  final List<HosDataRow> rows;
  final bool isLoading;
  final bool searchEnabled;
  final String searchHint;
  /// Optional client-side search filter — given the search query + row,
  /// return true to keep the row.
  final bool Function(String query, HosDataRow row)? searchMatcher;
  final ValueChanged<String>? onSearchChanged;
  final Widget? trailingFilter;
  final String emptyTitle;
  final String? emptyMessage;
  final int rowsPerPage;
  final ValueChanged<int>? onRowTap;

  @override
  State<HosDataTable> createState() => _HosDataTableState();
}

class _HosDataTableState extends State<HosDataTable> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = widget.searchMatcher == null || _query.isEmpty
        ? widget.rows
        : widget.rows
            .where((r) => widget.searchMatcher!(_query.toLowerCase(), r))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.searchEnabled || widget.trailingFilter != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                if (widget.searchEnabled)
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        prefixIcon: const Icon(HosIcons.search, size: 20),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        setState(() => _query = v);
                        widget.onSearchChanged?.call(v);
                      },
                    ),
                  ),
                if (widget.trailingFilter != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  widget.trailingFilter!,
                ],
              ],
            ),
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              child: widget.isLoading
                  ? _buildSkeletons()
                  : filtered.isEmpty
                      ? HosEmptyState(
                          icon: HosIcons.search,
                          title: widget.emptyTitle,
                          message: widget.emptyMessage,
                        )
                      : _buildTable(theme, filtered),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletons() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: 8,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, _) => const HosSkeletonListTile(),
    );
  }

  Widget _buildTable(ThemeData theme, List<HosDataRow> filtered) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width -
              AppSpacing.md * 2 -
              2, // accounts for border
        ),
        child: DataTable(
          showCheckboxColumn: false,
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ),
          headingTextStyle: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.4,
          ),
          dataTextStyle: AppTypography.bodyMedium,
          dividerThickness: 1,
          columnSpacing: AppSpacing.xl,
          horizontalMargin: AppSpacing.lg,
          columns: [
            for (final col in widget.columns)
              DataColumn(
                label: Text(col.label.toUpperCase()),
                numeric: col.numeric,
              ),
          ],
          rows: [
            for (var i = 0; i < filtered.length; i++)
              DataRow(
                onSelectChanged: widget.onRowTap == null
                    ? null
                    : (_) => widget.onRowTap!(i),
                cells: [
                  for (final cell in filtered[i].cells) DataCell(cell),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class HosDataColumn {
  const HosDataColumn({required this.label, this.numeric = false});
  final String label;
  final bool numeric;
}

class HosDataRow {
  const HosDataRow({required this.cells, this.searchText});
  final List<Widget> cells;

  /// Concatenated lower-case text used by the default search matcher.
  final String? searchText;
}

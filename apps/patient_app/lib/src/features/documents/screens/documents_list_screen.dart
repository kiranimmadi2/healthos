import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/documents_provider.dart';

class DocumentsListScreen extends ConsumerWidget {
  const DocumentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(patientDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () => context.pop(),
        ),
        title: const Text('My documents'),
        actions: [
          HosIconButton(
            icon: HosIcons.add,
            tooltip: 'Upload',
            onPressed: () => context.go('/documents/upload'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(patientDocumentsProvider),
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
            onRetry: () => ref.invalidate(patientDocumentsProvider),
          ),
          data: (docs) {
            if (docs.isEmpty) {
              return HosEmptyState(
                icon: HosIcons.reports,
                title: 'No documents yet',
                message: 'Upload external reports, insurance cards, '
                    'or vaccine certificates to keep them in one place.',
                actionLabel: 'Upload a file',
                actionIcon: HosIcons.upload,
                onAction: () => context.go('/documents/upload'),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screenPadding,
              itemCount: docs.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _DocCard(doc: docs[i]),
            );
          },
        ),
      ),
    );
  }
}

class _DocCard extends ConsumerWidget {
  const _DocCard({required this.doc});
  final PatientDocument doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = switch (doc.kind) {
      'report' => theme.colorScheme.secondary,
      'insurance' => AppColors.info,
      'prescription' => AppColors.warning,
      'vaccine_cert' => AppColors.success,
      _ => AppColors.textSecondary,
    };
    return HosCard(
      onTap: () => _open(context, ref),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(_iconFor(doc.kind), color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.title, style: AppTypography.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${_label(doc.kind)} · ${doc.uploadedAt == null ? '' : DateFormat.yMMMd().format(doc.uploadedAt!)}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(HosIcons.more, size: HosIcons.sizeMd),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'open', child: Text('Open')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            onSelected: (v) {
              if (v == 'open') _open(context, ref);
              if (v == 'delete') _delete(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(patientDocumentRepoProvider);
    final url = doc.fileUrl ?? await repo.freshSignedUrl(doc.storagePath);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('${doc.title} will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(patientDocumentRepoProvider).delete(doc.id, doc.storagePath);
    ref.invalidate(patientDocumentsProvider);
  }

  String _label(String k) => switch (k) {
        'report' => 'Report',
        'insurance' => 'Insurance',
        'prescription' => 'Prescription',
        'vaccine_cert' => 'Vaccine cert',
        _ => 'Other',
      };

  IconData _iconFor(String k) => switch (k) {
        'report' => HosIcons.labReport,
        'insurance' => HosIcons.verified,
        'prescription' => HosIcons.prescription,
        'vaccine_cert' => HosIcons.injection,
        _ => HosIcons.reports,
      };
}

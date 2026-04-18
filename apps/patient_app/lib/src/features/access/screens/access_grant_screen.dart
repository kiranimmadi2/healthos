import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/access_provider.dart';

class AccessGrantScreen extends ConsumerWidget {
  const AccessGrantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grantsAsync = ref.watch(activeGrantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/access/grant'),
          ),
        ],
      ),
      body: grantsAsync.when(
        data: (grants) {
          if (grants.isEmpty) {
            return HosEmptyState(
              message: 'No doctors have access to your records',
              icon: Icons.share_outlined,
              actionLabel: 'Grant Access',
              onAction: () => context.push('/access/grant'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activeGrantsProvider);
            },
            child: ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: grants.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final grant = grants[index];
                return _GrantCard(grant: grant);
              },
            ),
          );
        },
        loading: () => const HosLoading(),
        error: (error, _) => HosError(
          message: error.toString(),
          onRetry: () => ref.invalidate(activeGrantsProvider),
        ),
      ),
    );
  }
}

class _GrantCard extends ConsumerWidget {
  const _GrantCard({required this.grant});

  final AccessGrant grant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorByIdProvider(grant.doctorId));

    return HosCard(
      child: Row(
        children: [
          doctorAsync.when(
            data: (doctor) => HosAvatar(name: doctor?.fullName, radius: 20),
            loading: () => HosAvatar(name: 'Dr', radius: 20),
            error: (_, _) => HosAvatar(name: 'Dr', radius: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                doctorAsync.when(
                  data: (doctor) => Text(
                    'Dr. ${doctor?.fullName ?? 'Unknown'}',
                    style: AppTypography.label,
                  ),
                  loading: () => Text('Loading...', style: AppTypography.caption),
                  error: (_, _) => Text(
                    'Doctor ID: ${grant.doctorId.substring(0, 8)}...',
                    style: AppTypography.label,
                  ),
                ),
                doctorAsync.when(
                  data: (doctor) => Text(
                    '${doctor?.specialization ?? 'General'} | Since: ${grant.grantedAt != null ? AppDateUtils.formatDate(grant.grantedAt!) : 'N/A'}',
                    style: AppTypography.caption,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => Text(
                    'Access: ${grant.accessLevel}',
                    style: AppTypography.caption,
                  ),
                ),
              ],
            ),
          ),
          HosStatusChip(
            label: grant.accessLevel.toUpperCase(),
            color: AppColors.info,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error, size: 20),
            onPressed: () async {
              final repo = ref.read(accessGrantRepoProvider);
              await repo.revoke(grant.id);
              ref.invalidate(activeGrantsProvider);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';

final _accessGrantRepoProvider = Provider<AccessGrantRepository>(
  (ref) => AccessGrantRepository(),
);

final _activeGrantsProvider = FutureProvider<List<AccessGrant>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];

  final repo = ref.watch(_accessGrantRepoProvider);
  return repo.getActiveByPatientId(patient.id);
});

class AccessGrantScreen extends ConsumerWidget {
  const AccessGrantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grantsAsync = ref.watch(_activeGrantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to grant doctor screen
            },
          ),
        ],
      ),
      body: grantsAsync.when(
        data: (grants) {
          if (grants.isEmpty) {
            return const HosEmptyState(
              message: 'No doctors have access to your records',
              icon: Icons.share_outlined,
              actionLabel: 'Grant Access',
            );
          }
          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: grants.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final grant = grants[index];
              return HosCard(
                child: Row(
                  children: [
                    HosAvatar(name: 'Doctor', radius: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Doctor ID: ${grant.doctorId.substring(0, 8)}...',
                              style: AppTypography.label),
                          Text(
                            'Access: ${grant.accessLevel} | Since: ${grant.grantedAt != null ? AppDateUtils.formatDate(grant.grantedAt!) : 'N/A'}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.error),
                      onPressed: () async {
                        final repo = ref.read(_accessGrantRepoProvider);
                        await repo.revoke(grant.id);
                        ref.invalidate(_activeGrantsProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const HosLoading(),
        error: (error, _) => HosError(
          message: error.toString(),
          onRetry: () => ref.invalidate(_activeGrantsProvider),
        ),
      ),
    );
  }
}

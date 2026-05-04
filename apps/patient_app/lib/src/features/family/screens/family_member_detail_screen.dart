import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/family_provider.dart';

class FamilyMemberDetailScreen extends ConsumerWidget {
  const FamilyMemberDetailScreen({super.key, required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(familyMemberByIdProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: memberAsync.whenData((m) => m?.fullName ?? '').valueOrNull != null
            ? Text(memberAsync.value!.fullName)
            : const Text('Family Member'),
        actions: [
          if (memberAsync.value != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/profile/family/$memberId/edit'),
            ),
        ],
      ),
      body: memberAsync.when(
        loading: () => const HosLoading(),
        error: (e, _) => HosError(message: e.toString()),
        data: (member) {
          if (member == null) {
            return const HosError(message: 'Member not found');
          }
          return _MemberDetail(member: member);
        },
      ),
    );
  }
}

class _MemberDetail extends ConsumerWidget {
  const _MemberDetail({required this.member});
  final FamilyMember member;

  String get _relationshipLabel {
    return member.relationship[0].toUpperCase() + member.relationship.substring(1);
  }

  String? get _ageLabel {
    if (member.dateOfBirth == null) return null;
    final age = DateTime.now().difference(member.dateOfBirth!).inDays ~/ 365;
    return '$age years old';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: HosPageContainer(
        maxWidth: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header card
          HosCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                    style: AppTypography.h2.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.fullName, style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          _StatusChip(label: _relationshipLabel),
                          if (_ageLabel != null) _StatusChip(label: _ageLabel!),
                          if (member.gender != null)
                            _StatusChip(label: member.gender![0].toUpperCase() + member.gender!.substring(1)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _LinkBadge(member: member),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: HosButton(
                  label: 'Book Appointment',
                  icon: Icons.calendar_today,
                  onPressed: () {
                    ref.read(selectedBookingMemberProvider.notifier).state = member;
                    context.push('/appointments/book');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Permissions section
          Text('Permissions', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),
          _PermissionRow(
            icon: Icons.calendar_today,
            label: 'Appointment management',
            enabled: member.canManageAppointments,
          ),
          _PermissionRow(
            icon: Icons.folder_shared,
            label: 'Can view your records',
            enabled: member.canViewRecords,
          ),
          _PermissionRow(
            icon: Icons.child_care,
            label: 'Dependent',
            enabled: member.isDependent,
          ),
          ],
        ),
      ),
    );
  }
}

class _LinkBadge extends StatelessWidget {
  const _LinkBadge({required this.member});
  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    return switch (member.inviteStatus) {
      'linked'  => _badge('Linked to HealthOS', AppColors.secondary, Icons.check_circle),
      'invited' => _badge('Invite sent', AppColors.warning, Icons.mail_outline),
      _         => member.isDependent
                    ? _badge('Managed by you', AppColors.primary, Icons.shield)
                    : _badge('Not yet linked', AppColors.textTertiary, Icons.person_outline),
    };
  }

  Widget _badge(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption.copyWith(color: color)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.textTertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.icon, required this.label, required this.enabled});
  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: enabled ? AppColors.secondary : AppColors.textTertiary),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          Icon(
            enabled ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: enabled ? AppColors.secondary : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

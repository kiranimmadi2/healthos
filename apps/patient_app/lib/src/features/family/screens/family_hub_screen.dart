import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/family_provider.dart';

class FamilyHubScreen extends ConsumerWidget {
  const FamilyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyMembersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Family & Dependents')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/profile/family/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
      body: familyAsync.when(
        loading: () => const HosLoading(),
        error: (e, _) => HosError(message: e.toString(), onRetry: () => ref.invalidate(familyMembersProvider)),
        data: (members) => members.isEmpty
            ? _EmptyState(onAdd: () => context.push('/profile/family/add'))
            : ListView.separated(
                padding: AppSpacing.screenPadding,
                itemCount: members.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) => _FamilyMemberCard(
                  member: members[i],
                  onTap: () => context.push('/profile/family/${members[i].id}'),
                  onEdit: () => context.push('/profile/family/${members[i].id}/edit'),
                  onDelete: () => _confirmDelete(context, ref, members[i]),
                ),
              ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.fullName} from your family list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(familyMemberRepoProvider).delete(member.id);
      ref.invalidate(familyMembersProvider);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.family_restroom, size: 80, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.xl),
            Text('No Family Members Yet', style: AppTypography.h3, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Add your family members to manage their health appointments and records in one place.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            HosButton(label: 'Add Family Member', onPressed: onAdd, icon: Icons.person_add),
          ],
        ),
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  const _FamilyMemberCard({
    required this.member,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final FamilyMember member;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  IconData get _relationshipIcon {
    return switch (member.relationship) {
      'spouse'   => Icons.favorite,
      'child'    => Icons.child_care,
      'parent'   => Icons.person,
      'sibling'  => Icons.people,
      'guardian' => Icons.shield,
      _          => Icons.person_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final age = member.dateOfBirth != null
        ? '${DateTime.now().difference(member.dateOfBirth!).inDays ~/ 365} yrs'
        : null;

    return HosCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha:0.1),
            child: Icon(_relationshipIcon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _Chip(label: _capitalize(member.relationship)),
                    if (age != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _Chip(label: age),
                    ],
                    const SizedBox(width: AppSpacing.sm),
                    if (member.inviteStatus == 'linked')
                      _Chip(label: 'Linked', color: AppColors.secondary)
                    else if (member.inviteStatus == 'invited')
                      _Chip(label: 'Invited', color: AppColors.warning)
                    else if (member.isDependent)
                      _Chip(label: 'Managed', color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textTertiary).withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: color ?? AppColors.textSecondary),
      ),
    );
  }
}

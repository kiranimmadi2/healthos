import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/family_provider.dart';

class FamilyHealthCard extends ConsumerWidget {
  const FamilyHealthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyMembersProvider);

    return familyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (members) {
        if (members.isEmpty) return const SizedBox.shrink();
        return HosCard(
          onTap: () => context.push('/profile/family'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.family_restroom, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Family Health', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${members.length} member${members.length == 1 ? '' : 's'}',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: members.take(4).map((m) => _MemberChip(member: m)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.member});
  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            member.fullName.split(' ').first,
            style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

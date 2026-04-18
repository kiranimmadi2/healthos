import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/family_provider.dart';
import '../../../providers/patient_provider.dart';

class AddFamilyMemberScreen extends ConsumerStatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  ConsumerState<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends ConsumerState<AddFamilyMemberScreen> {
  int _step = 0;

  // Step 1
  String? _relationship;

  // Step 2
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;

  // Step 3
  bool _isDependent = false;
  bool _canViewRecords = false;
  bool _canManageAppointments = false;

  bool _isLoading = false;

  static const _relationships = [
    ('spouse',   Icons.favorite,      'Spouse'),
    ('parent',   Icons.person,        'Parent'),
    ('child',    Icons.child_care,    'Child'),
    ('sibling',  Icons.people,        'Sibling'),
    ('guardian', Icons.shield,        'Guardian'),
    ('other',    Icons.person_outline,'Other'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final patient = await ref.read(currentPatientProvider.future);
      if (patient == null) throw Exception('Not authenticated');

      await ref.read(familyMemberRepoProvider).create({
        'primary_patient_id': patient.id,
        'relationship': _relationship,
        'full_name': _nameController.text.trim(),
        'date_of_birth': _dateOfBirth?.toIso8601String().split('T').first,
        'gender': _gender,
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'is_dependent': _isDependent,
        'can_view_records': _canViewRecords,
        'can_manage_appointments': _canManageAppointments,
      });

      ref.invalidate(familyMembersProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(['Who are you adding?', 'Their Details', 'Permissions'][_step]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / 3),
        ),
      ),
      body: SafeArea(
        child: [_buildStep1, _buildStep2, _buildStep3][_step](),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              children: _relationships.map((r) {
                final (value, icon, label) = r;
                final selected = _relationship == value;
                return GestureDetector(
                  onTap: () {
                    setState(() => _relationship = value);
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (mounted) setState(() => _step = 1);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.textTertiary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 32, color: selected ? Colors.white : AppColors.primary),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          label,
                          style: AppTypography.bodyMedium.copyWith(
                            color: selected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          HosTextField(
            controller: _nameController,
            label: 'Full Name *',
            prefixIcon: Icons.person,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: HosTextField(
                label: 'Date of Birth',
                prefixIcon: Icons.calendar_today,
                hint: _dateOfBirth != null
                    ? AppDateUtils.formatDate(_dateOfBirth!)
                    : 'Select date of birth',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc)),
            initialValue: _gender,
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: AppSpacing.md),
          HosTextField(
            controller: _phoneController,
            label: 'Phone (optional — for invite)',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: HosButton(
                  label: 'Back',
                  onPressed: () => setState(() => _step = 0),
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: HosButton(
                  label: 'Next',
                  onPressed: _nameController.text.trim().isEmpty
                      ? null
                      : () => setState(() => _step = 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final hasPhone = _phoneController.text.trim().isNotEmpty;
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Set how you\'ll share health data', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          _PermissionTile(
            icon: Icons.calendar_today,
            title: 'Manage their appointments',
            subtitle: 'You can book and cancel appointments on their behalf',
            value: _canManageAppointments,
            onChanged: (v) => setState(() => _canManageAppointments = v),
          ),
          const SizedBox(height: AppSpacing.md),
          _PermissionTile(
            icon: Icons.folder_shared,
            title: 'They can view my records',
            subtitle: 'They\'ll see your lab reports and visit history',
            value: _canViewRecords,
            onChanged: hasPhone ? (v) => setState(() => _canViewRecords = v) : null,
            disabled: !hasPhone,
            disabledHint: 'Add a phone number to enable this',
          ),
          const SizedBox(height: AppSpacing.md),
          _PermissionTile(
            icon: Icons.child_care,
            title: 'This is a dependent',
            subtitle: 'You fully manage their health (e.g. a child)',
            value: _isDependent,
            onChanged: (v) => setState(() {
              _isDependent = v;
              if (v) _canManageAppointments = true;
            }),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: HosButton(
                  label: 'Back',
                  onPressed: () => setState(() => _step = 1),
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: HosButton(
                  label: 'Add Member',
                  onPressed: _save,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.disabled = false,
    this.disabledHint,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    return HosCard(
      child: Row(
        children: [
          Icon(icon, color: disabled ? AppColors.textTertiary : AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium.copyWith(
                  color: disabled ? AppColors.textTertiary : AppColors.textPrimary,
                )),
                Text(
                  disabled && disabledHint != null ? disabledHint! : subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: disabled ? null : onChanged,
          ),
        ],
      ),
    );
  }
}

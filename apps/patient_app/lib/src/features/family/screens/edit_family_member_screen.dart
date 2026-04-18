import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/family_provider.dart';

class EditFamilyMemberScreen extends ConsumerStatefulWidget {
  const EditFamilyMemberScreen({super.key, required this.memberId});
  final String memberId;

  @override
  ConsumerState<EditFamilyMemberScreen> createState() => _EditFamilyMemberScreenState();
}

class _EditFamilyMemberScreenState extends ConsumerState<EditFamilyMemberScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;
  String? _relationship;

  bool _isDependent = false;
  bool _canViewRecords = false;
  bool _canManageAppointments = false;
  bool _isLoading = false;
  bool _initialised = false;

  static const _relationships = [
    ('spouse',   'Spouse'),
    ('parent',   'Parent'),
    ('child',    'Child'),
    ('sibling',  'Sibling'),
    ('guardian', 'Guardian'),
    ('other',    'Other'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initFromMember(FamilyMember member) {
    if (_initialised) return;
    _initialised = true;
    _nameController.text = member.fullName;
    _phoneController.text = member.phone ?? '';
    _dateOfBirth = member.dateOfBirth;
    _gender = member.gender;
    _relationship = member.relationship;
    _isDependent = member.isDependent;
    _canViewRecords = member.canViewRecords;
    _canManageAppointments = member.canManageAppointments;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(familyMemberRepoProvider).update(widget.memberId, {
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
      ref.invalidate(familyMemberByIdProvider(widget.memberId));
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
    final memberAsync = ref.watch(familyMemberByIdProvider(widget.memberId));

    return memberAsync.when(
      loading: () => const Scaffold(body: HosLoading()),
      error: (e, _) => Scaffold(body: HosError(message: e.toString())),
      data: (member) {
        if (member == null) {
          return const Scaffold(body: HosError(message: 'Member not found'));
        }
        _initFromMember(member);
        return _buildForm();
      },
    );
  }

  Widget _buildForm() {
    final hasPhone = _phoneController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Family Member')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Relationship', prefixIcon: Icon(Icons.people)),
              initialValue: _relationship,
              items: _relationships.map((r) {
                final (value, label) = r;
                return DropdownMenuItem(value: value, child: Text(label));
              }).toList(),
              onChanged: (v) => setState(() => _relationship = v),
            ),
            const SizedBox(height: AppSpacing.md),
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
              label: 'Phone (optional)',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Permissions', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.md),
            _PermissionTile(
              icon: Icons.calendar_today,
              title: 'Manage their appointments',
              value: _canManageAppointments,
              onChanged: (v) => setState(() => _canManageAppointments = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PermissionTile(
              icon: Icons.folder_shared,
              title: 'They can view my records',
              value: _canViewRecords,
              onChanged: hasPhone ? (v) => setState(() => _canViewRecords = v) : null,
              disabled: !hasPhone,
              disabledHint: 'Add a phone number to enable this',
            ),
            const SizedBox(height: AppSpacing.sm),
            _PermissionTile(
              icon: Icons.child_care,
              title: 'This is a dependent',
              value: _isDependent,
              onChanged: (v) => setState(() {
                _isDependent = v;
                if (v) _canManageAppointments = true;
              }),
            ),
            const SizedBox(height: AppSpacing.xxl),
            HosButton(
              label: 'Save Changes',
              onPressed: _save,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.disabled = false,
    this.disabledHint,
  });

  final IconData icon;
  final String title;
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
            child: Text(
              disabled && disabledHint != null ? disabledHint! : title,
              style: AppTypography.bodyMedium.copyWith(
                color: disabled ? AppColors.textTertiary : AppColors.textPrimary,
              ),
            ),
          ),
          Switch(value: value, onChanged: disabled ? null : onChanged),
        ],
      ),
    );
  }
}

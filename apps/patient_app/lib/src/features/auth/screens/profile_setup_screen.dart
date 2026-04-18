import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/patient_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    // Pre-fill name from Google OAuth metadata when available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authServiceProvider).currentUser;
      final googleName = user?.userMetadata?['full_name'] as String?
          ?? user?.userMetadata?['name'] as String?;
      if (googleName != null && _nameController.text.isEmpty) {
        _nameController.text = googleName;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('Not authenticated');

      final repo = ref.read(patientRepositoryProvider);
      final healthId = HealthIdGenerator.generate();

      final currentUser = ref.read(authServiceProvider).currentUser;
      await repo.create({
        'auth_id': userId,
        'health_id': healthId,
        'phone': currentUser?.phone,
        'full_name': _nameController.text.trim(),
        'gender': _selectedGender,
        'blood_group': _selectedBloodGroup,
        'date_of_birth': _dateOfBirth?.toIso8601String(),
      });

      if (mounted) {
        ref.invalidate(currentPatientProvider);
        context.go('/home');
      }
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
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Let\'s set up your health profile',
                  style: AppTypography.h3,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This information helps doctors provide better care.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                HosTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.validateName,
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
                          : 'Select your date of birth',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc),
                  ),
                  initialValue: _selectedGender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                  initialValue: _selectedBloodGroup,
                  items: _bloodGroups
                      .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedBloodGroup = value),
                ),
                const SizedBox(height: AppSpacing.xl),
                HosButton(
                  label: 'Create Health Profile',
                  onPressed: _createProfile,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

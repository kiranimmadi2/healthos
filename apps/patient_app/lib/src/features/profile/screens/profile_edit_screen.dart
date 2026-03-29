import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/patient_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodGroup;
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  void _loadPatientData() {
    final patient = ref.read(currentPatientProvider).valueOrNull;
    if (patient != null) {
      _nameController.text = patient.fullName ?? '';
      _selectedGender = patient.gender;
      _selectedBloodGroup = patient.bloodGroup;
      _dateOfBirth = patient.dateOfBirth;
      _allergiesController.text = patient.allergies.join(', ');
      _conditionsController.text = patient.chronicConditions.join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final patient = await ref.read(currentPatientProvider.future);
      if (patient == null) throw Exception('Profile not found');

      final repo = ref.read(patientRepositoryProvider);

      final allergies = _allergiesController.text.trim().isEmpty
          ? <String>[]
          : _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final conditions = _conditionsController.text.trim().isEmpty
          ? <String>[]
          : _conditionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      await repo.update(patient.id, {
        'full_name': _nameController.text.trim(),
        'gender': _selectedGender,
        'blood_group': _selectedBloodGroup,
        'date_of_birth': _dateOfBirth?.toIso8601String(),
        'allergies': allergies,
        'chronic_conditions': conditions,
      });

      if (mounted) {
        ref.invalidate(currentPatientProvider);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
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
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  value: _selectedGender,
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
                  value: _selectedBloodGroup,
                  items: _bloodGroups
                      .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBloodGroup = value),
                ),
                const SizedBox(height: AppSpacing.md),
                HosTextField(
                  controller: _allergiesController,
                  label: 'Allergies',
                  prefixIcon: Icons.warning_amber,
                  hint: 'Comma-separated (e.g., Penicillin, Peanuts)',
                ),
                const SizedBox(height: AppSpacing.md),
                HosTextField(
                  controller: _conditionsController,
                  label: 'Chronic Conditions',
                  prefixIcon: Icons.medical_information,
                  hint: 'Comma-separated (e.g., Diabetes, Hypertension)',
                ),
                const SizedBox(height: AppSpacing.xl),
                HosButton(
                  label: 'Save Changes',
                  onPressed: _saveProfile,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

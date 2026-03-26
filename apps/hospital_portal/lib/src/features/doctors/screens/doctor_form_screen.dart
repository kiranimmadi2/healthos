import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import 'doctors_list_screen.dart';

/// When editing, loads the existing doctor to pre-populate the form.
final doctorFormProvider =
    FutureProvider.family<Doctor?, String?>((ref, doctorId) async {
  if (doctorId == null) return null;
  final repo = DoctorRepository();
  return repo.getById(doctorId);
});

class DoctorFormScreen extends ConsumerStatefulWidget {
  const DoctorFormScreen({super.key, this.doctorId});

  /// Null means create mode; non-null means edit mode.
  final String? doctorId;

  @override
  ConsumerState<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends ConsumerState<DoctorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  bool _didPopulate = false;

  bool get _isEditMode => widget.doctorId != null;

  @override
  void dispose() {
    _fullNameController.dispose();
    _specializationController.dispose();
    _licenseNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateFields(Doctor doctor) {
    _fullNameController.text = doctor.fullName;
    _specializationController.text = doctor.specialization ?? '';
    _licenseNumberController.text = doctor.licenseNumber;
    _phoneController.text = doctor.phone ?? '';
    _emailController.text = doctor.email ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = DoctorRepository();
      final data = <String, dynamic>{
        'full_name': _fullNameController.text.trim(),
        'specialization': _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),
        'license_number': _licenseNumberController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      };

      if (_isEditMode) {
        await repo.update(widget.doctorId!, data);
      } else {
        await repo.create(data);
      }

      if (!mounted) return;

      ref.invalidate(allDoctorsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Doctor updated successfully.'
                : 'Doctor created successfully.',
          ),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Edit Doctor' : 'Add Doctor';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _isEditMode
          ? _buildEditBody()
          : _buildForm(),
    );
  }

  Widget _buildEditBody() {
    final doctorAsync = ref.watch(doctorFormProvider(widget.doctorId));

    return doctorAsync.when(
      loading: () => const Center(child: HosLoading()),
      error: (e, _) => HosError(
        message: e.toString(),
        onRetry: () => ref.invalidate(doctorFormProvider(widget.doctorId)),
      ),
      data: (doctor) {
        if (doctor == null) {
          return const HosEmptyState(
            message: 'Doctor not found.',
            icon: Icons.person_off_outlined,
          );
        }

        if (!_didPopulate) {
          _didPopulate = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _populateFields(doctor);
          });
        }

        return _buildForm();
      },
    );
  }

  Widget _buildForm() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                HosTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Enter doctor\'s full name',
                  prefixIcon: Icons.person_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                HosTextField(
                  controller: _specializationController,
                  label: 'Specialization',
                  hint: 'e.g. Cardiology, Dermatology',
                  prefixIcon: Icons.medical_services_outlined,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.md),
                HosTextField(
                  controller: _licenseNumberController,
                  label: 'License Number',
                  hint: 'Enter medical license number',
                  prefixIcon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'License number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                HosTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  hint: 'Enter phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                HosTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter email address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.xl),
                HosButton(
                  label: _isEditMode ? 'Update Doctor' : 'Create Doctor',
                  onPressed: _isSubmitting ? null : _submit,
                  isLoading: _isSubmitting,
                  icon: _isEditMode ? Icons.save_outlined : Icons.add,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

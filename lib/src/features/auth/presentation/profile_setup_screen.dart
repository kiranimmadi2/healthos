import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/theme.dart';
import '../../../shared/domain/app_failure.dart';
import 'package:intl/intl.dart';
import '../application/auth_providers.dart';
import '../application/user_providers.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  /// Brightness-aware semantic colours for this screen.
  HosColors get hos => context.hos;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  final _hospitalController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();

  String _selectedRole = 'patient';
  String? _selectedGender;
  String? _selectedSpecialization;
  DateTime? _selectedDob;
  bool _isLoading = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _specializations = [
    'General Practitioner',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Orthopedic',
    'Neurologist',
    'Gynecologist',
    'Psychiatrist',
    'ENT Specialist',
    'Ophthalmologist',
    'Dentist',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).value;
    if (user?.displayName != null) {
      _nameController.text = user!.displayName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _hospitalController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'patient') {
      if (_selectedDob == null) {
        _showError('Please select your date of birth');
        return;
      }
      if (_selectedGender == null) {
        _showError('Please select your gender');
        return;
      }
    } else {
      if (_selectedSpecialization == null) {
        _showError('Please select your specialization');
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final Map<String, dynamic> profileData = {
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'role': _selectedRole,
        'email': user.email,
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (_phoneController.text.trim().isNotEmpty) {
        profileData['phone'] = _phoneController.text.trim();
      }

      if (_selectedRole == 'patient') {
        profileData['dob'] = _selectedDob!.toIso8601String();
        profileData['gender'] = _selectedGender!;
        if (_heightController.text.isNotEmpty) {
          profileData['height'] = double.tryParse(_heightController.text);
        }
        if (_weightController.text.isNotEmpty) {
          profileData['weight'] = double.tryParse(_weightController.text);
        }
      } else {
        profileData['specialization'] = _selectedSpecialization!;
        profileData['hospital'] = _hospitalController.text.trim();
        profileData['licenseNumber'] = _licenseController.text.trim();
        if (_experienceController.text.isNotEmpty) {
          profileData['yearsOfExperience'] = int.tryParse(
            _experienceController.text,
          );
        }
      }

      try {
        await user.updateDisplayName(_nameController.text.trim());
      } catch (_) {}

      await ref
          .read(userRepositoryProvider)
          .createUserData(user.uid, profileData);
      ref.invalidate(userProfileProvider);
    } catch (e) {
      if (mounted) _showError(describeFailure(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Complete Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Almost there!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell us a bit more about yourself to personalize your experience.',
                  ),
                  const SizedBox(height: 40),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'I am joining as a:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildRoleSelector(),
                  const SizedBox(height: 32),

                  if (_selectedRole == 'patient')
                    _buildPatientFields()
                  else
                    _buildDoctorFields(),

                  const SizedBox(height: 56),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Finish Setup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildRoleCard('patient', 'Patient', Icons.person_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRoleCard(
            'doctor',
            'Doctor',
            Icons.medical_services_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF2563EB),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context),
          child: _buildDecoratedInput(
            label: 'Date of Birth',
            icon: Icons.calendar_today_rounded,
            content: _selectedDob == null
                ? 'Select Date'
                : DateFormat('MMM dd, yyyy').format(_selectedDob!),
          ),
        ),
        const SizedBox(height: 20),
        _buildDropdown(
          value: _selectedGender,
          label: 'Gender',
          icon: Icons.wc_rounded,
          items: _genders,
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _heightController,
                label: 'Height (cm)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoctorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Professional Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          value: _selectedSpecialization,
          label: 'Specialization',
          icon: Icons.local_hospital_rounded,
          items: _specializations,
          onChanged: (v) => setState(() => _selectedSpecialization = v),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _hospitalController,
          label: 'Hospital / Clinic',
          icon: Icons.business_rounded,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _licenseController,
          label: 'License Number',
          icon: Icons.badge_rounded,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _experienceController,
          label: 'Years of Experience',
          icon: Icons.work_history_rounded,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB)),
        ),
      ),
    );
  }

  Widget _buildDecoratedInput({
    required String label,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
              ),
              Text(content, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB)),
        ),
      ),
    );
  }
}

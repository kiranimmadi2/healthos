import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/theme.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../features/auth/application/auth_providers.dart';
import '../../../features/auth/application/user_providers.dart';

/// Function to trigger opening the User Profile & Settings Modal Sheet
Future<void> showUserProfileModal(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const UserProfileModalSheet(),
  );
}

class UserProfileModalSheet extends ConsumerStatefulWidget {
  const UserProfileModalSheet({super.key});

  @override
  ConsumerState<UserProfileModalSheet> createState() =>
      _UserProfileModalSheetState();
}

class _UserProfileModalSheetState extends ConsumerState<UserProfileModalSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _conditionsController;
  late TextEditingController _allergiesController;
  late TextEditingController _medicationsController;
  late TextEditingController _hospitalController;
  late TextEditingController _licenseController;
  late TextEditingController _experienceController;
  late TextEditingController _bioController;

  String? _selectedGender;
  String? _selectedBloodGroup;
  String? _selectedSpecialization;
  DateTime? _selectedDob;
  bool _isSaving = false;
  bool _initialized = false;

  // Settings Toggles
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _soundEffects = true;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
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
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _conditionsController = TextEditingController();
    _allergiesController = TextEditingController();
    _medicationsController = TextEditingController();
    _hospitalController = TextEditingController();
    _licenseController = TextEditingController();
    _experienceController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadCurrentUserData();
      _initialized = true;
    }
  }

  void _loadCurrentUserData() {
    final authUser = ref.read(authStateProvider).value;
    final profile = ref.read(userProfileProvider).value;

    _nameController.text =
        profile?['name'] as String? ?? authUser?.displayName ?? '';
    _emailController.text =
        profile?['email'] as String? ?? authUser?.email ?? '';
    _phoneController.text =
        profile?['phone'] as String? ?? authUser?.phoneNumber ?? '';

    _selectedGender = profile?['gender'] as String?;
    _selectedBloodGroup = profile?['bloodGroup'] as String? ?? profile?['blood_group'] as String?;
    _selectedSpecialization = profile?['specialization'] as String?;

    if (profile?['dob'] != null) {
      try {
        _selectedDob = DateTime.parse(profile!['dob'].toString());
      } catch (_) {}
    }

    if (profile?['height'] != null) {
      _heightController.text = profile!['height'].toString();
    }
    if (profile?['weight'] != null) {
      _weightController.text = profile!['weight'].toString();
    }

    final conditions = profile?['medicalHistory'] ?? profile?['conditions'] ?? profile?['chronicConditions'];
    if (conditions != null) {
      _conditionsController.text = conditions is List ? conditions.join(', ') : conditions.toString();
    }

    final allergies = profile?['allergies'];
    if (allergies != null) {
      _allergiesController.text = allergies is List ? allergies.join(', ') : allergies.toString();
    }

    final medications = profile?['medications'] ?? profile?['currentMedications'];
    if (medications != null) {
      _medicationsController.text = medications is List ? medications.join(', ') : medications.toString();
    }

    if (profile?['hospital'] != null) {
      _hospitalController.text = profile!['hospital'].toString();
    }
    if (profile?['licenseNumber'] != null) {
      _licenseController.text = profile!['licenseNumber'].toString();
    }
    if (profile?['yearsOfExperience'] != null) {
      _experienceController.text = profile!['yearsOfExperience'].toString();
    }
    if (profile?['bio'] != null) {
      _bioController.text = profile!['bio'].toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _hospitalController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final existingProfile = ref.read(userProfileProvider).value ?? {};
      final role = existingProfile['role'] as String? ?? 'patient';

      final Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (role == 'patient' || role == 'PATIENT') {
        if (_selectedGender != null) updatedData['gender'] = _selectedGender;
        if (_selectedBloodGroup != null) {
          updatedData['bloodGroup'] = _selectedBloodGroup;
          updatedData['blood_group'] = _selectedBloodGroup;
        }
        if (_selectedDob != null) {
          updatedData['dob'] = _selectedDob!.toIso8601String();
        }
        if (_heightController.text.isNotEmpty) {
          updatedData['height'] = double.tryParse(_heightController.text);
        }
        if (_weightController.text.isNotEmpty) {
          updatedData['weight'] = double.tryParse(_weightController.text);
        }
        if (_conditionsController.text.isNotEmpty) {
          final list = _conditionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          updatedData['medicalHistory'] = list;
          updatedData['conditions'] = list;
          updatedData['chronicConditions'] = list;
        }
        if (_allergiesController.text.isNotEmpty) {
          final list = _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          updatedData['allergies'] = list;
        }
        if (_medicationsController.text.isNotEmpty) {
          final list = _medicationsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          updatedData['medications'] = list;
          updatedData['currentMedications'] = list;
        }
      } else {
        if (_selectedSpecialization != null) {
          updatedData['specialization'] = _selectedSpecialization;
        }
        if (_hospitalController.text.isNotEmpty) {
          updatedData['hospital'] = _hospitalController.text.trim();
        }
        if (_licenseController.text.isNotEmpty) {
          updatedData['licenseNumber'] = _licenseController.text.trim();
        }
        if (_experienceController.text.isNotEmpty) {
          updatedData['yearsOfExperience'] =
              int.tryParse(_experienceController.text);
        }
      }

      // Update Firebase auth user display name
      if (_nameController.text.trim().isNotEmpty) {
        try {
          await user.updateDisplayName(_nameController.text.trim());
        } catch (_) {}
      }

      // Save to UserRepository (Firestore + Local Cache)
      await ref
          .read(userRepositoryProvider)
          .createUserData(user.uid, updatedData);

      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(userProfileProvider).value;
    final authUser = ref.watch(authStateProvider).value;

    final displayName =
        profile?['name'] as String? ?? authUser?.displayName ?? 'User Profile';
    final email = profile?['email'] as String? ?? authUser?.email ?? '';
    final role =
        (profile?['role'] as String? ?? 'patient').toUpperCase();

    final initials = displayName.trim().isNotEmpty
        ? displayName
            .trim()
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'P';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                role,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Settings & Edit Profile Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // --- Theme Switcher Section ---
                    _buildSectionHeader(
                      context,
                      title: 'Appearance & Theme',
                      icon: Icons.palette_outlined,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildThemeOption(
                          context,
                          label: 'Light',
                          icon: Icons.light_mode_rounded,
                          mode: ThemeMode.light,
                          currentMode: themeMode,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          context,
                          label: 'Dark',
                          icon: Icons.dark_mode_rounded,
                          mode: ThemeMode.dark,
                          currentMode: themeMode,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          context,
                          label: 'System',
                          icon: Icons.brightness_auto_rounded,
                          mode: ThemeMode.system,
                          currentMode: themeMode,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- Personal Details Form ---
                    _buildSectionHeader(
                      context,
                      title: 'Personal & Account Details',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Email Address (Registered)',
                        prefixIcon: Icon(Icons.email_rounded),
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Patient specific fields
                    if (role == 'PATIENT') ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _genders.contains(_selectedGender)
                                  ? _selectedGender
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.wc_rounded),
                                border: OutlineInputBorder(),
                              ),
                              items: _genders
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedGender = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectDateOfBirth,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth',
                                  prefixIcon: Icon(Icons.cake_rounded),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _selectedDob != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(_selectedDob!)
                                      : 'Select Date',
                                  style: TextStyle(
                                    color: _selectedDob == null
                                        ? AppColors.textMuted
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                                prefixIcon: Icon(Icons.height_rounded),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                prefixIcon: Icon(Icons.monitor_weight_rounded),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _bloodGroups.contains(_selectedBloodGroup)
                                  ? _selectedBloodGroup
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Blood Group',
                                prefixIcon: Icon(Icons.bloodtype_rounded),
                                border: OutlineInputBorder(),
                              ),
                              items: _bloodGroups
                                  .map((b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(b),
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedBloodGroup = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _conditionsController,
                        decoration: const InputDecoration(
                          labelText: 'Pre-existing Conditions / Diseases (comma-separated)',
                          hintText: 'e.g. Diabetes, Hypertension, Asthma, Anemia',
                          prefixIcon: Icon(Icons.healing_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _allergiesController,
                              decoration: const InputDecoration(
                                labelText: 'Known Allergies',
                                hintText: 'e.g. Penicillin, Dust, Peanuts',
                                prefixIcon: Icon(Icons.warning_amber_rounded),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _medicationsController,
                              decoration: const InputDecoration(
                                labelText: 'Current Medications',
                                hintText: 'e.g. Metformin 500mg, Thyroid 50mcg',
                                prefixIcon: Icon(Icons.medication_rounded),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Doctor specific fields
                    if (role == 'DOCTOR') ...[
                      DropdownButtonFormField<String>(
                        value: _specializations.contains(_selectedSpecialization)
                            ? _selectedSpecialization
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Specialization',
                          prefixIcon: Icon(Icons.medical_services_rounded),
                          border: OutlineInputBorder(),
                        ),
                        items: _specializations
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedSpecialization = val),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _hospitalController,
                        decoration: const InputDecoration(
                          labelText: 'Hospital / Clinic Name',
                          prefixIcon: Icon(Icons.local_hospital_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _licenseController,
                              decoration: const InputDecoration(
                                labelText: 'License No.',
                                prefixIcon: Icon(Icons.verified_rounded),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _experienceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Experience (Years)',
                                prefixIcon: Icon(Icons.work_history_rounded),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextFormField(
                      controller: _bioController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Bio / Notes',
                        prefixIcon: Icon(Icons.notes_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Notifications & Preferences Section ---
                    _buildSectionHeader(
                      context,
                      title: 'Preferences & Notifications',
                      icon: Icons.notifications_none_rounded,
                    ),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Push Notifications'),
                      subtitle: const Text('Reminders, appointment updates & alerts'),
                      value: _pushNotifications,
                      onChanged: (val) => setState(() => _pushNotifications = val),
                      activeColor: AppColors.primary,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Email Alerts'),
                      subtitle: const Text('Receive health reports & lab results in inbox'),
                      value: _emailAlerts,
                      onChanged: (val) => setState(() => _emailAlerts = val),
                      activeColor: AppColors.primary,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('In-App Sound Effects'),
                      subtitle: const Text('Play subtle sounds on actions'),
                      value: _soundEffects,
                      onChanged: (val) => setState(() => _soundEffects = val),
                      activeColor: AppColors.primary,
                    ),

                    const SizedBox(height: 24),

                    // --- Save Changes Button ---
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _isSaving ? 'Saving Changes...' : 'Save Profile Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- Sign Out Button ---
                    OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref.read(authRepositoryProvider).signOut();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = currentMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

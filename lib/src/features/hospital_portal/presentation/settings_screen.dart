import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/shell/health_page.dart';
import '../../../shared/presentation/widgets/hos_widgets.dart';

class HospitalSettingsScreen extends ConsumerStatefulWidget {
  const HospitalSettingsScreen({super.key});

  @override
  ConsumerState<HospitalSettingsScreen> createState() =>
      _HospitalSettingsScreenState();
}

class _HospitalSettingsScreenState
    extends ConsumerState<HospitalSettingsScreen> {
  final _nameController =
      TextEditingController(text: 'Apollo City Specialty Hospital');
  final _regIdController = TextEditingController(text: 'HOSP-2026-8842');
  final _emailController = TextEditingController(text: 'admin@apollocity.org');
  final _phoneController = TextEditingController(text: '+1 (555) 019-2834');

  bool _emailAlerts = true;
  bool _smsReminders = true;
  bool _criticalVitalsEscalation = true;

  final List<String> _departments = [
    'Cardiology',
    'Pediatrics',
    'Neurology',
    'Emergency Medicine',
    'Orthopedics',
    'General Surgery',
  ];

  final _newDeptController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _regIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _newDeptController.dispose();
    super.dispose();
  }

  void _addDepartment() {
    final text = _newDeptController.text.trim();
    if (text.isNotEmpty && !_departments.contains(text)) {
      setState(() {
        _departments.add(text);
        _newDeptController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Department "$text" added')),
      );
    }
  }

  void _removeDepartment(String dept) {
    setState(() {
      _departments.remove(dept);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Department "$dept" removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HealthPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Settings & Administration',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Configure hospital profile, alert thresholds, and active departments.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Hospital Profile Information Form
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(HosIcons.hospital, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Hospital Profile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Name',
                    prefixIcon: Icon(HosIcons.hospital),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _regIdController,
                  decoration: const InputDecoration(
                    labelText: 'Registration / License ID',
                    prefixIcon: Icon(HosIcons.shield),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email',
                          prefixIcon: Icon(Icons.email_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone',
                          prefixIcon: Icon(Icons.phone_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hospital profile updated')),
                      );
                    },
                    icon: const Icon(HosIcons.check),
                    label: const Text('Save Profile'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Notification Preferences
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(HosIcons.settings, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Notification & Alert Controls',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  title: const Text('Email Operational Summaries'),
                  subtitle: const Text('Daily reports sent to administrative staff'),
                  value: _emailAlerts,
                  onChanged: (val) => setState(() => _emailAlerts = val),
                  activeColor: AppColors.primary,
                ),
                SwitchListTile(
                  title: const Text('SMS Patient Reminders'),
                  subtitle: const Text('Automated SMS for upcoming appointment check-ins'),
                  value: _smsReminders,
                  onChanged: (val) => setState(() => _smsReminders = val),
                  activeColor: AppColors.primary,
                ),
                SwitchListTile(
                  title: const Text('Critical Vitals Emergency Escalation'),
                  subtitle: const Text('Instant push alerts when patient vitals cross threshold'),
                  value: _criticalVitalsEscalation,
                  onChanged: (val) => setState(() => _criticalVitalsEscalation = val),
                  activeColor: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Department Management CRUD List
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(HosIcons.user, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      'Department Management',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newDeptController,
                        decoration: const InputDecoration(
                          hintText: 'Enter new department name',
                          prefixIcon: Icon(HosIcons.hospital),
                        ),
                        onSubmitted: (_) => _addDepartment(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _addDepartment,
                      icon: const Icon(HosIcons.userAdd),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _departments.map((dept) {
                    return Chip(
                      avatar: const Icon(HosIcons.hospital, size: 16),
                      label: Text(dept),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16),
                      onDeleted: () => _removeDepartment(dept),
                      backgroundColor: AppColors.primarySoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

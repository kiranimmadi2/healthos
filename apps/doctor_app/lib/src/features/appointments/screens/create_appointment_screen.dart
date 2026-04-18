import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/doctor_provider.dart';
import '../providers/appointment_provider.dart';

final _patientRepoProvider = Provider<PatientRepository>((ref) => PatientRepository());
final _patientSearchProvider = FutureProvider.family<List<Patient>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final repo = ref.watch(_patientRepoProvider);
  return repo.search(query.trim());
});

class CreateAppointmentScreen extends ConsumerStatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  ConsumerState<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends ConsumerState<CreateAppointmentScreen> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();
  String _searchQuery = '';
  Patient? _selectedPatient;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  static const _timeSlots = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 9, minute: 30),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 10, minute: 30),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 11, minute: 30),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 14, minute: 30),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 15, minute: 30),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 16, minute: 30),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_selectedPatient == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select patient, date, and time')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final doctorId = ref.read(currentDoctorIdProvider);
      if (doctorId == null) throw Exception('Not authenticated');

      final scheduledAt = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );

      final repo = ref.read(appointmentRepoProvider);
      await repo.create({
        'patient_id': _selectedPatient!.id,
        'doctor_id': doctorId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      });

      ref.invalidate(doctorAppointmentsProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment created')),
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
      appBar: AppBar(title: const Text('New Appointment')),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Patient', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  if (_selectedPatient != null) ...[
                    HosCard(
                      child: Row(
                        children: [
                          HosAvatar(name: _selectedPatient!.fullName, radius: 20),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selectedPatient!.fullName ?? 'Unknown', style: AppTypography.label),
                                HosHealthIdBadge(healthId: _selectedPatient!.healthId),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _selectedPatient = null),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    HosTextField(
                      controller: _searchController,
                      label: 'Search Patients',
                      prefixIcon: Icons.search,
                      hint: 'Search by name or health ID',
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                    if (_searchQuery.trim().length >= 2)
                      ref.watch(_patientSearchProvider(_searchQuery)).when(
                        data: (patients) {
                          if (patients.isEmpty) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(top: AppSpacing.xs),
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: patients.length,
                              itemBuilder: (context, index) {
                                final patient = patients[index];
                                return ListTile(
                                  leading: HosAvatar(name: patient.fullName, radius: 16),
                                  title: Text(patient.fullName ?? 'Unknown'),
                                  subtitle: Text(patient.healthId),
                                  onTap: () {
                                    setState(() {
                                      _selectedPatient = patient;
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          child: LinearProgressIndicator(),
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  Text('Select Date', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: AbsorbPointer(
                      child: HosTextField(
                        label: 'Date',
                        prefixIcon: Icons.calendar_today,
                        hint: _selectedDate != null
                            ? AppDateUtils.formatDate(_selectedDate!)
                            : 'Pick a date',
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Text('Select Time', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _timeSlots.map((slot) {
                      final isSelected = _selectedTime == slot;
                      return ChoiceChip(
                        label: Text(slot.format(context)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedTime = selected ? slot : null);
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Text('Notes (optional)', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.sm),
                  HosTextField(
                    controller: _notesController,
                    label: 'Notes',
                    hint: 'Any additional notes',
                    maxLines: 3,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  HosButton(
                    label: 'Create Appointment',
                    onPressed: _create,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

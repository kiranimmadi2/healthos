import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/family_provider.dart';
import '../../../providers/patient_provider.dart';
import '../../access/providers/access_provider.dart';
import '../providers/appointments_provider.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  final _searchController = TextEditingController();
  final _reasonController = TextEditingController();
  String _searchQuery = '';
  Doctor? _selectedDoctor;
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
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _bookAppointment() async {
    if (_selectedDoctor == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor, date, and time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final patient = await ref.read(currentPatientProvider.future);
      if (patient == null) throw Exception('Profile not found');

      final bookingMember = ref.read(selectedBookingMemberProvider);

      final scheduledAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final repo = ref.read(appointmentRepoProvider);
      await repo.create({
        'patient_id': bookingMember == null ? patient.id : patient.id,
        'doctor_id': _selectedDoctor!.id,
        'scheduled_at': scheduledAt.toIso8601String(),
        'reason': _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        if (bookingMember != null) 'booked_by_patient_id': patient.id,
        if (bookingMember != null) 'booked_for_member_id': bookingMember.id,
      });

      ref.invalidate(upcomingAppointmentsProvider);
      ref.invalidate(allAppointmentsProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully')),
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
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // For whom?
            _BookingForSelector(),

            const SizedBox(height: AppSpacing.lg),

            // Step 1: Select Doctor
            Text('Select Doctor', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            if (_selectedDoctor != null) ...[
              HosCard(
                child: Row(
                  children: [
                    HosAvatar(name: _selectedDoctor!.fullName, radius: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dr. ${_selectedDoctor!.fullName}',
                              style: AppTypography.label),
                          Text(_selectedDoctor!.specialization ?? 'General',
                              style: AppTypography.caption),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _selectedDoctor = null),
                    ),
                  ],
                ),
              ),
            ] else ...[
              HosTextField(
                controller: _searchController,
                label: 'Search Doctors',
                prefixIcon: Icons.search,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              if (_searchQuery.trim().length >= 2)
                ref.watch(doctorSearchResultsProvider(_searchQuery)).when(
                  data: (doctors) {
                    if (doctors.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(top: AppSpacing.xs),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = doctors[index];
                          return ListTile(
                            leading: HosAvatar(name: doctor.fullName, radius: 16),
                            title: Text('Dr. ${doctor.fullName}'),
                            subtitle: Text(doctor.specialization ?? ''),
                            onTap: () {
                              setState(() {
                                _selectedDoctor = doctor;
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

            // Step 2: Select Date
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

            // Step 3: Select Time
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

            // Step 4: Reason
            Text('Reason (optional)', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            HosTextField(
              controller: _reasonController,
              label: 'Reason for visit',
              hint: 'Brief description of your concern',
              maxLines: 3,
            ),

            const SizedBox(height: AppSpacing.xl),

            HosButton(
              label: 'Book Appointment',
              onPressed: _bookAppointment,
              isLoading: _isLoading,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingForSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyAsync = ref.watch(familyMembersProvider);
    final selected = ref.watch(selectedBookingMemberProvider);

    return familyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (members) {
        if (members.isEmpty) return const SizedBox.shrink();

        final options = <FamilyMember?>[null, ...members];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who is this for?', style: AppTypography.h4),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: options.map((member) {
                  final isSelected = member?.id == selected?.id;
                  final label = member == null ? 'Myself' : member.fullName.split(' ').first;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => ref.read(selectedBookingMemberProvider.notifier).state = member,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      avatar: member == null
                          ? const Icon(Icons.person, size: 16)
                          : CircleAvatar(
                              radius: 8,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                label[0].toUpperCase(),
                                style: const TextStyle(fontSize: 8),
                              ),
                            ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../providers/family_provider.dart';
import '../../../providers/patient_provider.dart';
import '../../access/providers/access_provider.dart';
import '../providers/appointments_provider.dart';

const _timeSlots = [
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

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends ConsumerState<BookAppointmentScreen> {
  final _searchController = TextEditingController();
  final _reasonController = TextEditingController();

  int _step = 0;
  String _searchQuery = '';
  Doctor? _doctor;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return true; // "For whom" always valid (Myself is default)
      case 1:
        return _doctor != null;
      case 2:
        return _date != null && _time != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _book() async {
    setState(() => _saving = true);
    try {
      final patient = await ref.read(currentPatientProvider.future);
      if (patient == null) throw Exception('Profile not found');
      final bookingMember = ref.read(selectedBookingMemberProvider);

      final scheduledAt = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time!.hour,
        _time!.minute,
      );

      final repo = ref.read(appointmentRepoProvider);
      await repo.create({
        'patient_id': patient.id,
        'doctor_id': _doctor!.id,
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
          const SnackBar(content: Text('Appointment booked')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: HosIconButton(
          icon: HosIcons.back,
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
        ),
        title: const Text('Book appointment'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: HosStepIndicator(
              steps: const ['For whom', 'Doctor', 'Date & time', 'Confirm'],
              currentStep: _step,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: HosPageContainer(
                maxWidth: 720,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildStep(_step),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: HosButton.secondary(
                        label: 'Back',
                        onPressed: () => setState(() => _step--),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    flex: _step == 0 ? 1 : 1,
                    child: _step == 3
                        ? HosButton.primary(
                            label: 'Confirm booking',
                            icon: HosIcons.success,
                            onPressed: _canAdvance ? _book : null,
                            isLoading: _saving,
                            expand: true,
                          )
                        : HosButton.primary(
                            label: 'Continue',
                            iconRight: HosIcons.forward,
                            onPressed: _canAdvance
                                ? () => setState(() => _step++)
                                : null,
                            expand: true,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int i) {
    return KeyedSubtree(
      key: ValueKey(i),
      child: switch (i) {
        0 => _ForWhomStep(),
        1 => _doctorStep(),
        2 => _dateTimeStep(),
        _ => _confirmStep(),
      },
    );
  }

  Widget _doctorStep() {
    if (_doctor != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected doctor', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.sm),
          HosCard(
            child: Row(
              children: [
                HosAvatar(name: _doctor!.fullName, radius: 24),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. ${_doctor!.fullName}',
                          style: AppTypography.label),
                      const SizedBox(height: 2),
                      Text(_doctor!.specialization ?? 'General practice',
                          style: AppTypography.caption),
                    ],
                  ),
                ),
                HosIconButton(
                  icon: HosIcons.close,
                  tooltip: 'Change',
                  onPressed: () => setState(() => _doctor = null),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Find a doctor', style: AppTypography.h4),
        const SizedBox(height: AppSpacing.sm),
        HosTextField(
          controller: _searchController,
          hint: 'Search by name or specialty',
          prefixIcon: HosIcons.search,
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_searchQuery.trim().length >= 2)
          ref.watch(doctorSearchResultsProvider(_searchQuery)).when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: HosSkeletonListTile(),
                ),
                error: (e, _) => HosError(message: e.toString()),
                data: (doctors) {
                  if (doctors.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: HosEmptyState(
                        icon: HosIcons.search,
                        title: 'No matching doctors',
                        message: 'Try a different search term.',
                      ),
                    );
                  }
                  return Column(
                    children: doctors.take(10).map((d) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: HosCard(
                          onTap: () {
                            setState(() {
                              _doctor = d;
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          child: Row(
                            children: [
                              HosAvatar(name: d.fullName, radius: 20),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dr. ${d.fullName}',
                                        style: AppTypography.label),
                                    Text(d.specialization ?? 'General practice',
                                        style: AppTypography.caption),
                                  ],
                                ),
                              ),
                              const Icon(HosIcons.forward,
                                  size: HosIcons.sizeSm,
                                  color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              )
        else
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Type at least 2 characters to search.',
              style: AppTypography.caption,
            ),
          ),
      ],
    );
  }

  Widget _dateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HosDateField(
          label: 'Preferred date',
          hint: 'Pick a date',
          value: _date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          onChanged: (d) => setState(() => _date = d),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Preferred time', style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _timeSlots.map((slot) {
            final isSelected = _time == slot;
            return ChoiceChip(
              label: Text(slot.format(context)),
              selected: isSelected,
              onSelected: (_) => setState(() => _time = slot),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        HosTextField(
          controller: _reasonController,
          label: 'Reason (optional)',
          hint: 'Brief description of your concern',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _confirmStep() {
    final bookingMember = ref.watch(selectedBookingMemberProvider);
    final whoLabel = bookingMember == null
        ? 'Yourself'
        : bookingMember.fullName;
    final at = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review booking', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        HosAppointmentCard(
          personName: 'Dr. ${_doctor!.fullName}',
          personRole: _doctor!.specialization ?? 'General practice',
          when: at,
          status: HosAppointmentStatus.pending,
          forWhom: whoLabel,
        ),
        if (_reasonController.text.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          HosCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason for visit', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                Text(_reasonController.text.trim(),
                    style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(
          'By confirming you\'ll be notified once the clinic approves this request.',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _ForWhomStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyMembersProvider);
    final selected = ref.watch(selectedBookingMemberProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Who is this appointment for?', style: AppTypography.h4),
        const SizedBox(height: AppSpacing.md),
        HosCard(
          onTap: () =>
              ref.read(selectedBookingMemberProvider.notifier).state = null,
          child: Row(
            children: [
              const HosAvatar(name: 'Me', radius: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Myself', style: AppTypography.label),
              ),
              if (selected == null)
                const Icon(HosIcons.success,
                    color: AppColors.success, size: HosIcons.sizeMd),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        family.when(
          loading: () => const HosSkeletonListTile(),
          error: (_, _) => const SizedBox.shrink(),
          data: (members) {
            if (members.isEmpty) return const SizedBox.shrink();
            return Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Family members',
                      style: AppTypography.caption),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...members.map((m) {
                  final isSelected = selected?.id == m.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: HosCard(
                      onTap: () => ref
                          .read(selectedBookingMemberProvider.notifier)
                          .state = m,
                      child: Row(
                        children: [
                          HosAvatar(name: m.fullName, radius: 20),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.fullName, style: AppTypography.label),
                                Text(
                                  '${_rel(m.relationship)}${m.dateOfBirth == null ? '' : ' · ${DateFormat.yMMMd().format(m.dateOfBirth!)}'}',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(HosIcons.success,
                                color: AppColors.success,
                                size: HosIcons.sizeMd),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  String _rel(String raw) {
    switch (raw) {
      case 'spouse':
        return 'Spouse';
      case 'child':
        return 'Child';
      case 'parent':
        return 'Parent';
      case 'sibling':
        return 'Sibling';
      case 'guardian':
        return 'Guardian';
      default:
        return 'Other';
    }
  }
}
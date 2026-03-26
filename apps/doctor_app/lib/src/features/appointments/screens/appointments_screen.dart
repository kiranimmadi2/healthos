import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/appointment_provider.dart';
import '../widgets/appointment_card.dart';

class DoctorAppointmentsScreen extends ConsumerStatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  ConsumerState<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends ConsumerState<DoctorAppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(doctorAppointmentsForDateProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/appointments/create'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Date selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
                ),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Text(
                    AppDateUtils.formatDate(_selectedDate),
                    style: AppTypography.h4,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Appointments list
          Expanded(
            child: appointmentsAsync.when(
              data: (appointments) {
                if (appointments.isEmpty) {
                  return const HosEmptyState(
                    message: 'No appointments for this day',
                    icon: Icons.calendar_today,
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.screenPadding,
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) => DoctorAppointmentCard(appointment: appointments[index]),
                );
              },
              loading: () => const HosLoading(),
              error: (error, _) => HosError(
                message: error.toString(),
                onRetry: () => ref.invalidate(doctorAppointmentsForDateProvider(_selectedDate)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

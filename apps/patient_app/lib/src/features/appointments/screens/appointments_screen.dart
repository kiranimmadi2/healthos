import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../providers/appointments_provider.dart';
import '../widgets/appointment_card.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'All'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/appointments/book'),
          child: const Icon(Icons.add),
        ),
        body: const TabBarView(
          children: [
            _UpcomingTab(),
            _AllTab(),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTab extends ConsumerWidget {
  const _UpcomingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(upcomingAppointmentsProvider);

    return appointmentsAsync.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return const HosEmptyState(
            message: 'No upcoming appointments',
            icon: Icons.calendar_today,
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(upcomingAppointmentsProvider);
          },
          child: ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: appointments.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => AppointmentCard(
              appointment: appointments[index],
            ),
          ),
        );
      },
      loading: () => const HosLoading(),
      error: (error, _) => HosError(
        message: error.toString(),
        onRetry: () => ref.invalidate(upcomingAppointmentsProvider),
      ),
    );
  }
}

class _AllTab extends ConsumerWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(allAppointmentsProvider);

    return appointmentsAsync.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return const HosEmptyState(
            message: 'No appointments yet',
            icon: Icons.calendar_today,
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allAppointmentsProvider);
          },
          child: ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: appointments.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => AppointmentCard(
              appointment: appointments[index],
            ),
          ),
        );
      },
      loading: () => const HosLoading(),
      error: (error, _) => HosError(
        message: error.toString(),
        onRetry: () => ref.invalidate(allAppointmentsProvider),
      ),
    );
  }
}

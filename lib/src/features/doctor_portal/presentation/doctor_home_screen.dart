import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/layout/responsive_layout.dart';
import '../../../shared/presentation/shell/health_destination.dart';
import '../../../shared/presentation/shell/health_shell.dart';
import '../../../shared/presentation/widgets/user_profile_dialog.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/application/user_providers.dart';
import '../../chat/application/chat_providers.dart';
import '../application/doctor_portal_providers.dart';
import 'widgets/doctor_workspace_widgets.dart';
import 'workspaces/doctor_dashboard.dart';
import 'workspaces/messages_workspace.dart';
import 'workspaces/patients_workspace.dart';
import 'workspaces/reports_workspace.dart';
import 'workspaces/schedule_workspace.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  int _currentIndex = 0;

  static const _destinations = [
    HealthDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    HealthDestination(
      label: 'Patients',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
    ),
    HealthDestination(
      label: 'Schedule',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
    HealthDestination(
      label: 'Messages',
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
    ),
    HealthDestination(
      label: 'Reports',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
    ),
  ];

  late final List<Widget> _screens = [
    DoctorDashboard(onOpenSection: _selectSection),
    const PatientsWorkspace(),
    const ScheduleWorkspace(),
    const MessagesWorkspace(),
    const ReportsWorkspace(),
  ];

  void _selectSection(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.tabletMax;
    final labels = _destinations
        .map((destination) => destination.label)
        .toList();

    final stats = ref.watch(doctorStatsProvider);
    final patientCount = ref.watch(allPatientsProvider).value?.length ?? 0;
    final profile = ref.watch(userProfileProvider).value;
    final doctorName = (profile?['name'] as String?)?.trim();
    final initials = _initialsFor(doctorName);
    final alertCount = stats.pendingAppointments + stats.reportsToReview;

    final subtitles = [
      stats.pendingAppointments > 0
          ? '${stats.pendingAppointments} request${stats.pendingAppointments == 1 ? '' : 's'} to review'
          : 'Live appointments and requests',
      '$patientCount active patient${patientCount == 1 ? '' : 's'}',
      stats.todayAppointments > 0
          ? '${stats.todayAppointments} appointment${stats.todayAppointments == 1 ? '' : 's'} today'
          : 'Manage confirmed consultations',
      'Live patient conversations',
      stats.reportsToReview > 0
          ? '${stats.reportsToReview} report${stats.reportsToReview == 1 ? '' : 's'} need review'
          : 'All reports reviewed',
    ];

    return HealthShell(
      title: labels[_currentIndex],
      subtitle: subtitles[_currentIndex],
      destinations: _destinations,
      selectedIndex: _currentIndex,
      onDestinationSelected: _selectSection,
      leading: IconButton(
        tooltip: 'Sign out',
        onPressed: () => ref.read(authRepositoryProvider).signOut(),
        icon: const Icon(Icons.logout_rounded),
      ),
      actions: [
        SizedBox(
          width: isDesktop ? 280 : 48,
          child: isDesktop
              ? TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search workspace',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                  onSubmitted: _applySearch,
                )
              : IconButton(
                  tooltip: 'Search workspace',
                  onPressed: () => _showSearch(context),
                  icon: const Icon(Icons.search_rounded),
                ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => _showNotifications(context, stats),
          icon: alertCount > 0
              ? Badge(
                  label: Text('$alertCount'),
                  child: const Icon(Icons.notifications_outlined),
                )
              : const Icon(Icons.notifications_outlined),
        ),
        InkWell(
          onTap: () => showUserProfileModal(context),
          borderRadius: BorderRadius.circular(20),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondarySoft,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      child: _screens[_currentIndex],
    );
  }

  /// Applies a header search: stores the query and reveals the patient list,
  /// which filters on it.
  void _applySearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    ref.read(workspaceSearchProvider.notifier).set(query);
    final patientsIndex = _destinations.indexWhere(
      (d) => d.label == 'Patients',
    );
    if (patientsIndex != -1 && patientsIndex != _currentIndex) {
      _selectSection(patientsIndex);
    }
  }

  Future<void> _showSearch(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search patients by name or condition',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _applySearch(value);
          },
        ),
      ),
    );
  }

  Future<void> _showNotifications(BuildContext context, DoctorStats stats) async {
    final conversationCount = ref.read(chatThreadsProvider).value?.length ?? 0;
    final items = <Widget>[
      if (stats.pendingAppointments > 0)
        NotificationTile(
          icon: Icons.event_available_outlined,
          color: AppColors.primary,
          title: 'Booking requests',
          detail:
              '${stats.pendingAppointments} appointment${stats.pendingAppointments == 1 ? '' : 's'} awaiting confirmation',
          time: 'Now',
        ),
      if (stats.reportsToReview > 0)
        NotificationTile(
          icon: Icons.science_outlined,
          color: AppColors.warning,
          title: stats.highPriorityReports > 0
              ? 'Reports need review'
              : 'Diagnostic reports',
          detail:
              '${stats.reportsToReview} report${stats.reportsToReview == 1 ? '' : 's'} to review'
              '${stats.highPriorityReports > 0 ? ' · ${stats.highPriorityReports} high priority' : ''}',
          time: 'Now',
        ),
      if (conversationCount > 0)
        NotificationTile(
          icon: Icons.chat_bubble_outline_rounded,
          color: AppColors.secondary,
          title: 'Patient conversations',
          detail:
              '$conversationCount active conversation${conversationCount == 1 ? '' : 's'}',
          time: 'Now',
        ),
    ];

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      "You're all caught up — no new notifications.",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ...items,
            ],
          ),
        ),
      ),
    );
  }

  /// Builds up-to-two-letter initials from a doctor's display name, stripping a
  /// leading "Dr." title. Falls back to "DR" when no name is available.
  static String _initialsFor(String? name) {
    if (name == null || name.trim().isEmpty) return 'DR';
    final cleaned = name
        .replaceAll(RegExp(r'^\s*dr\.?\s+', caseSensitive: false), '')
        .trim();
    final parts = cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'DR';
    if (parts.length == 1) {
      final word = parts.first;
      return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

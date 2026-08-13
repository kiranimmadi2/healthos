import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/presentation/layout/responsive_layout.dart';
import '../../../../shared/presentation/shell/health_page.dart';
import '../../../../shared/domain/app_failure.dart';
import '../../../../shared/presentation/widgets/glass_container.dart';
import '../../../../shared/presentation/widgets/hos_states.dart';
import '../../../../shared/presentation/widgets/status_pill.dart';
import '../../../appointments/appointments.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/application/user_providers.dart';
import '../../../chat/chat.dart';
import '../../../doctors/doctors.dart';

part 'appointment_card.dart';
part 'care_updates.dart';
part 'dashboard_widgets.dart';
part 'health_summary_card.dart';
part 'quick_actions.dart';

class DashboardContent extends ConsumerWidget {
  const DashboardContent({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    final rawName =
        (profile?['name'] as String?)?.split(' ').first ??
        user?.displayName?.split(' ').first ??
        'there';
    final userName = rawName.isNotEmpty
        ? '${rawName[0].toUpperCase()}${rawName.substring(1).toLowerCase()}'
        : 'there';

    return HealthPage(
      maxWidth: 1400,
      bottomPadding: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeHeader(name: userName),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1050;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Content (Left Column)
                    Expanded(
                      flex: 65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AppointmentCard(onNavigate: onNavigate),
                          const SizedBox(height: 24),
                          _CategoryPillRow(onNavigate: onNavigate),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(child: _HealthTipsCard()),
                              const SizedBox(width: 20),
                              const Expanded(child: _ResultAndHistoryCard()),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const _SectionHeader(
                            title: 'Quick Actions',
                            subtitle: 'Instant access to care services',
                          ),
                          const SizedBox(height: 16),
                          _QuickActions(onNavigate: onNavigate),
                          const SizedBox(height: 28),
                          const _SectionHeader(
                            title: 'Care Updates',
                            subtitle: 'Recent activity across your medical records',
                          ),
                          const SizedBox(height: 16),
                          const _CareUpdates(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Doctor Search & Queue Panel
                    Expanded(
                      flex: 35,
                      child: Column(
                        children: [
                          _FindDoctorPanel(onNavigate: onNavigate),
                          const SizedBox(height: 24),
                          const _AppointmentQueueCard(),
                          const SizedBox(height: 24),
                          const _HealthSummaryCard(),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AppointmentCard(onNavigate: onNavigate),
                  const SizedBox(height: 20),
                  _CategoryPillRow(onNavigate: onNavigate),
                  const SizedBox(height: 24),
                  _FindDoctorPanel(onNavigate: onNavigate),
                  const SizedBox(height: 24),
                  const _AppointmentQueueCard(),
                  const SizedBox(height: 24),
                  const _HealthSummaryCard(),
                  const SizedBox(height: 24),
                  const _HealthTipsCard(),
                  const SizedBox(height: 24),
                  const _ResultAndHistoryCard(),
                  const SizedBox(height: 28),
                  const _SectionHeader(
                    title: 'Quick Actions',
                    subtitle: 'Instant access to care services',
                  ),
                  const SizedBox(height: 16),
                  _QuickActions(onNavigate: onNavigate),
                  const SizedBox(height: 28),
                  const _SectionHeader(
                    title: 'Care Updates',
                    subtitle: 'Recent activity across your medical records',
                  ),
                  const SizedBox(height: 16),
                  const _CareUpdates(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $name',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 34,
                letterSpacing: -0.8,
              ),
        ),
      ],
    );
  }
}

/// Category Pill Navigation Row identical to the reference design
class _CategoryPillRow extends ConsumerWidget {
  const _CategoryPillRow({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorTab = kIsWeb ? 1 : 2;
    final recordsTab = kIsWeb ? 2 : 3;
    final triageTab = kIsWeb ? 3 : 4;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GlassPillButton(
              icon: Icons.health_and_safety_rounded,
              label: 'Doctors',
              onTap: () {
                ref.read(selectedDoctorCategoryProvider.notifier).setCategory('All');
                ref.read(selectedDoctorQueryProvider.notifier).setQuery('');
                onNavigate(doctorTab);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GlassPillButton(
              icon: Icons.calendar_month_rounded,
              label: 'Book Consultation',
              onTap: () {
                ref.read(selectedDoctorCategoryProvider.notifier).setCategory('All');
                ref.read(selectedDoctorQueryProvider.notifier).setQuery('');
                onNavigate(doctorTab);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GlassPillButton(
              icon: Icons.folder_shared_rounded,
              label: 'Records & Meds',
              onTap: () => onNavigate(recordsTab),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GlassPillButton(
              icon: Icons.health_and_safety_rounded,
              label: 'Care Assistant',
              onTap: () => onNavigate(triageTab),
            ),
          ),
          if (!kIsWeb)
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: GlassPillButton(
                icon: Icons.restaurant_rounded,
                label: 'Meal Analyzer',
                onTap: () => onNavigate(1),
              ),
            ),
        ],
      ),
    );
  }
}

/// Find a Doctor & Specialty Grid Glass Panel
class _FindDoctorPanel extends ConsumerStatefulWidget {
  const _FindDoctorPanel({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<_FindDoctorPanel> createState() => _FindDoctorPanelState();
}

class _FindDoctorPanelState extends ConsumerState<_FindDoctorPanel> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final text = _searchController.text.trim();
    ref.read(selectedDoctorQueryProvider.notifier).setQuery(text);
    widget.onNavigate(kIsWeb ? 1 : 2);
  }

  @override
  Widget build(BuildContext context) {
    final doctorTab = kIsWeb ? 1 : 2;
    final specialties = [
      (Icons.medical_services_rounded, 'General'),
      (Icons.child_care_rounded, 'Pediatrics'),
      (Icons.favorite_outline_rounded, 'Obstetrics'),
      (Icons.monitor_heart_outlined, 'Internal Med'),
      (Icons.face_rounded, 'Dermatology'),
      (Icons.psychology_outlined, 'Mental Health'),
      (Icons.favorite_rounded, 'Cardiology'),
      (Icons.accessibility_new_rounded, 'Orthopedics'),
      (Icons.shield_outlined, 'Infectious'),
    ];

    return GlassContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find a doctor',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
          ),
          const SizedBox(height: 16),
          // Search Field
          TextField(
            controller: _searchController,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search doctors, specialties...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                onPressed: _search,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (constraints.maxWidth < 280) {
                crossAxisCount = 2;
              } else if (constraints.maxWidth >= 600) {
                crossAxisCount = 4;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: specialties.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 80,
                ),
                itemBuilder: (context, index) {
                  final item = specialties[index];
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final labelColor = isDark ? Colors.white : AppColors.textPrimary;

                  return InkWell(
                    onTap: () {
                      ref.read(selectedDoctorCategoryProvider.notifier).setCategory(item.$2);
                      ref.read(selectedDoctorQueryProvider.notifier).setQuery('');
                      widget.onNavigate(doctorTab);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: GlassContainer(
                      borderRadius: 16,
                      opacity: 0.75,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.$1,
                              size: 20,
                              color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.$2,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Health Tips glass card matching Hourglass design
class _HealthTipsCard extends StatelessWidget {
  const _HealthTipsCard();

  @override
  Widget build(BuildContext context) {
    final tips = [
      ('Stay Hydrated', 'Drink enough water to support energy and focus.', Icons.water_drop_rounded, AppColors.primary),
      ('Move Every Hour', 'Stand up and stretch briefly to keep active.', Icons.directions_walk_rounded, AppColors.secondary),
      ('Eat More Greens', 'Add vegetables to every meal for better nutrition.', Icons.eco_rounded, AppColors.success),
    ];

    return GlassContainer(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Tips',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 16),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tip.$4.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(tip.$3, color: tip.$4, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          tip.$2,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Result & History glass card matching reference image
class _ResultAndHistoryCard extends StatelessWidget {
  const _ResultAndHistoryCard();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Result & History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              const Icon(Icons.swap_horiz_rounded, size: 20, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 16),
          _historyItem(context, 'Diagnosis Terakhir', 'Flu Ringan', '12 Okt 2025', AppColors.primary),
          _historyItem(context, 'Obat', 'Paracetamol 500mg (5 hari)', '', AppColors.secondary),
          _historyItem(context, 'Hasil Lab', 'CBC — Normal', '06 Sep 2025', AppColors.success),
          _historyItem(context, 'Kunjungan Terakhir', 'Poli Umum', '02 Agu 2025', AppColors.warning),
        ],
      ),
    );
  }

  Widget _historyItem(BuildContext context, String category, String title, String date, Color dotColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? const Color(0xFF94A3B8) : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(fontSize: 11, color: mutedColor),
              ),
              const Spacer(),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: mutedColor),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Appointment Queue Card connected to real backend appointment stream
class _AppointmentQueueCard extends ConsumerWidget {
  const _AppointmentQueueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextAppointmentAsync = ref.watch(nextAppointmentProvider);

    return GlassContainer(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment queue',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 16),
          nextAppointmentAsync.when(
            data: (appointment) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final boxBg = isDark
                  ? const Color(0xFF1E293B).withOpacity(0.85)
                  : Colors.white.withOpacity(0.85);
              final textMainColor = isDark ? Colors.white : AppColors.textMain;

              if (appointment == null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: boxBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.event_available_rounded, size: 36, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        'No active appointment queue',
                        style: TextStyle(fontWeight: FontWeight.bold, color: textMainColor, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Book a consultation with our verified doctors anytime.',
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final timeFormatted = DateFormat('hh:mm a').format(appointment.dateTime);
              final dateFormatted = DateFormat('MMM dd, yyyy').format(appointment.dateTime);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: boxBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.specialization.isEmpty
                                    ? 'Specialist'
                                    : appointment.specialization,
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                appointment.doctorName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appointment.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 18,
                          opacity: 0.70,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              const Text('Status', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                appointment.status == AppointmentStatus.confirmed
                                    ? 'Confirmed'
                                    : 'Pending',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 18,
                          opacity: 0.70,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              const Text('Date', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                dateFormatted,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlassContainer(
                          borderRadius: 18,
                          opacity: 0.70,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              const Text('Time', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                timeFormatted,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const HosSkeletonList(count: 2, padding: EdgeInsets.zero),
            error: (error, _) => HosErrorState(
              error: error,
              compact: true,
              title: 'Could not load doctors',
            ),
          ),
        ],
      ),
    );
  }
}



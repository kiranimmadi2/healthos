import 'package:flutter/material.dart';

import '../../ui_kit.dart';

/// Dev-only gallery rendering every DS widget + tokens. Mount this behind a
/// `kDebugMode` guard on a `/design` route in each app. Single source of
/// truth for how each component should look.
class DesignGallery extends StatefulWidget {
  const DesignGallery({super.key});

  @override
  State<DesignGallery> createState() => _DesignGalleryState();
}

class _DesignGalleryState extends State<DesignGallery> {
  int _tab = 0;
  Set<String> _allergies = {'Peanuts'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System'),
        actions: [
          HosIconButton(
            icon: HosIcons.notifications,
            onPressed: () {},
            tooltip: 'Sample',
            badgeCount: 3,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _Section(title: 'Typography', child: _typography()),
          _Section(title: 'Color Tokens', child: _colors()),
          _Section(title: 'Icons (HosIcons)', child: _icons()),
          _Section(title: 'Buttons', child: _buttons()),
          _Section(title: 'Text Input & Form Fields', child: _form()),
          _Section(title: 'Chips & Status', child: _chips()),
          _Section(title: 'Cards', child: _cards()),
          _Section(title: 'Tab Bar', child: _tabBar()),
          _Section(title: 'Step Indicator', child: _stepIndicator()),
          _Section(title: 'Skeletons', child: _skeletons()),
          _Section(title: 'Empty / Error', child: _empty()),
          _Section(title: 'Timeline', child: _timeline()),
          _Section(title: 'Vitals / Prescription / Lab Report', child: _medical()),
          _Section(title: 'Appointment / Stat', child: _appointmentAndStat()),
          _Section(title: 'Avatar & Badges', child: _avatars()),
          _Section(
            title: 'Bottom Sheet (tap to open)',
            child: HosButton.secondary(
              label: 'Open bottom sheet',
              icon: HosIcons.chat,
              onPressed: () {
                showHosBottomSheet(
                  context: context,
                  title: 'Sample bottom sheet',
                  child: Column(
                    children: const [
                      Text(
                        'This is a standard HealthOS bottom sheet. Use it for '
                        'quick note entry, confirmations, or compact forms.',
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
      floatingActionButton: HosSpeedDial(
        tooltip: 'Quick actions',
        actions: [
          HosSpeedDialAction(
            label: 'Add visit',
            icon: HosIcons.edit,
            onPressed: () {},
          ),
          HosSpeedDialAction(
            label: 'Add note',
            icon: HosIcons.note,
            onPressed: () {},
          ),
          HosSpeedDialAction(
            label: 'Prescribe',
            icon: HosIcons.prescription,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _typography() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('H1 Heading', style: AppTypography.h1),
          const SizedBox(height: 4),
          Text('H2 Heading', style: AppTypography.h2),
          Text('H3 Heading', style: AppTypography.h3),
          Text('H4 Heading', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.sm),
          Text('Body large — Inter 16px', style: AppTypography.bodyLarge),
          Text('Body medium — Inter 14px', style: AppTypography.bodyMedium),
          Text('Body small — 12px', style: AppTypography.bodySmall),
          Text('LABEL', style: AppTypography.label),
          Text('caption', style: AppTypography.caption),
        ],
      );

  Widget _colors() {
    final swatches = <(String, Color)>[
      ('Primary', AppColors.primary),
      ('Secondary', AppColors.secondary),
      ('Success', AppColors.success),
      ('Warning', AppColors.warning),
      ('Error', AppColors.error),
      ('Info', AppColors.info),
      ('Triage Home', AppColors.triageHomeCare),
      ('Triage See Dr', AppColors.triageSeeDoctor),
      ('Triage ER', AppColors.triageEmergency),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final s in swatches)
          Container(
            width: 100,
            height: 64,
            decoration: BoxDecoration(
              color: s.$2,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(6),
            child: Text(
              s.$1,
              style: AppTypography.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _icons() {
    final icons = <(String, IconData)>[
      ('home', HosIcons.home),
      ('reports', HosIcons.reports),
      ('symptoms', HosIcons.symptoms),
      ('profile', HosIcons.profile),
      ('family', HosIcons.family),
      ('notifications', HosIcons.notifications),
      ('settings', HosIcons.settings),
      ('dashboard', HosIcons.dashboard),
      ('appointment', HosIcons.appointment),
      ('vitals', HosIcons.vitals),
      ('heartRate', HosIcons.heartRate),
      ('temperature', HosIcons.temperature),
      ('prescription', HosIcons.prescription),
      ('injection', HosIcons.injection),
      ('labReport', HosIcons.labReport),
      ('biomarker', HosIcons.biomarker),
      ('diagnosis', HosIcons.diagnosis),
      ('allergy', HosIcons.allergy),
      ('note', HosIcons.note),
      ('add', HosIcons.add),
      ('edit', HosIcons.edit),
      ('delete', HosIcons.delete),
      ('search', HosIcons.search),
      ('filter', HosIcons.filter),
      ('share', HosIcons.share),
      ('copy', HosIcons.copy),
      ('qr', HosIcons.qr),
      ('verified', HosIcons.verified),
      ('pending', HosIcons.pending),
      ('ai', HosIcons.ai),
    ];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final i in icons)
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Icon(i.$2,
                    size: HosIcons.sizeLg,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 4),
                Text(i.$1,
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buttons() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              HosButton.primary(
                label: 'Primary',
                icon: HosIcons.add,
                onPressed: () {},
              ),
              HosButton.secondary(
                label: 'Secondary',
                icon: HosIcons.share,
                onPressed: () {},
              ),
              HosButton.tertiary(
                label: 'Tertiary',
                onPressed: () {},
              ),
              HosButton.destructive(
                label: 'Delete',
                icon: HosIcons.delete,
                onPressed: () {},
              ),
              HosButton.primary(
                label: 'Loading',
                onPressed: () {},
                isLoading: true,
              ),
              HosButton.primary(
                label: 'Continue',
                iconRight: HosIcons.forward,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              HosIconButton(
                icon: HosIcons.search,
                onPressed: () {},
                tooltip: 'Search',
              ),
              const SizedBox(width: AppSpacing.sm),
              HosIconButton(
                icon: HosIcons.notifications,
                onPressed: () {},
                badgeCount: 12,
              ),
              const SizedBox(width: AppSpacing.sm),
              HosIconButton(
                icon: HosIcons.more,
                onPressed: () {},
              ),
            ],
          ),
        ],
      );

  Widget _form() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HosTextField(
            label: 'Full name',
            hint: 'Jane Doe',
          ),
          const SizedBox(height: AppSpacing.md),
          HosDateField(
            label: 'Date of birth',
            value: DateTime(1998, 6, 12),
            onChanged: (_) {},
          ),
          const SizedBox(height: AppSpacing.md),
          HosDropdownField<String>(
            label: 'Blood type',
            value: 'O+',
            items: const [
              HosDropdownItem(label: 'A+', value: 'A+'),
              HosDropdownItem(label: 'A-', value: 'A-'),
              HosDropdownItem(label: 'B+', value: 'B+'),
              HosDropdownItem(label: 'O+', value: 'O+'),
              HosDropdownItem(label: 'O-', value: 'O-'),
              HosDropdownItem(label: 'AB+', value: 'AB+'),
            ],
            prefixIcon: HosIcons.bloodDrop,
            onChanged: (_) {},
          ),
          const SizedBox(height: AppSpacing.md),
          HosMultiSelectChips(
            label: 'Allergies',
            options: const [
              'Peanuts',
              'Dust',
              'Penicillin',
              'Lactose',
              'Pollen',
              'Shellfish'
            ],
            selected: _allergies,
            onChanged: (s) => setState(() => _allergies = s),
            helperText: 'Select any that apply',
          ),
        ],
      );

  Widget _chips() => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          HosStatusChip(
            label: 'Normal',
            color: AppColors.biomarkerNormal,
            icon: HosIcons.success,
          ),
          HosStatusChip(
            label: 'Low',
            color: AppColors.biomarkerLow,
            icon: HosIcons.warning,
          ),
          HosStatusChip(
            label: 'High',
            color: AppColors.biomarkerHigh,
            icon: HosIcons.warning,
          ),
          HosStatusChip(
            label: 'Home care',
            color: AppColors.triageHomeCare,
            icon: HosIcons.home,
          ),
          HosStatusChip(
            label: 'See doctor',
            color: AppColors.triageSeeDoctor,
            icon: HosIcons.symptoms,
          ),
          HosStatusChip(
            label: 'Emergency',
            color: AppColors.triageEmergency,
            icon: HosIcons.warning,
          ),
        ],
      );

  Widget _cards() => Column(
        children: [
          HosCard(
            onTap: () {},
            child: const Text('A simple tappable card'),
          ),
          const SizedBox(height: AppSpacing.sm),
          HosCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.borderRadiusSm),
                  ),
                  child: const Icon(HosIcons.heartRate,
                      color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resting heart rate', style: AppTypography.h4),
                      Text('72 bpm · average for your age',
                          style: AppTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _tabBar() => HosTabBar(
        tabs: const ['Overview', 'Visits', 'Labs', 'Notes'],
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      );

  Widget _stepIndicator() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: HosStepIndicator(
          steps: ['For whom', 'Doctor', 'Date & time', 'Confirm'],
          currentStep: 1,
        ),
      );

  Widget _skeletons() => Column(
        children: const [
          HosSkeletonListTile(),
          SizedBox(height: AppSpacing.sm),
          HosSkeletonCard(lines: 3),
        ],
      );

  Widget _empty() => HosCard(
        child: SizedBox(
          height: 220,
          child: HosEmptyState(
            icon: HosIcons.reports,
            title: 'No reports yet',
            message: 'When your lab uploads results, you\'ll see them here.',
            actionLabel: 'Request a test',
            actionIcon: HosIcons.add,
            onAction: () {},
          ),
        ),
      );

  Widget _timeline() => HosTimeline(
        entries: [
          HosTimelineEntry(
            title: 'Visit — Dr. Rao',
            subtitle: 'Apr 10, 2026',
            dotColor: AppColors.primary,
            body: Text(
              'Hypertension follow-up. BP 128/82, HR 74.',
              style: AppTypography.bodyMedium,
            ),
          ),
          HosTimelineEntry(
            title: 'Lab — CBC',
            subtitle: 'Apr 7, 2026',
            dotColor: AppColors.secondary,
            body: Text(
              '2 abnormal biomarkers flagged.',
              style: AppTypography.bodyMedium,
            ),
          ),
          HosTimelineEntry(
            title: 'Prescription — Metformin',
            subtitle: 'Mar 28, 2026',
            dotColor: AppColors.warning,
          ),
        ],
      );

  Widget _medical() => Column(
        children: [
          HosVitalsCard(
            title: 'Latest vitals',
            vitals: const [
              HosVital(
                label: 'Blood pressure',
                value: '128/82',
                unit: 'mmHg',
                icon: HosIcons.heartRate,
                status: HosVitalStatus.normal,
              ),
              HosVital(
                label: 'Heart rate',
                value: '74',
                unit: 'bpm',
                icon: HosIcons.heartRate,
                status: HosVitalStatus.normal,
              ),
              HosVital(
                label: 'Temperature',
                value: '99.4',
                unit: '°F',
                icon: HosIcons.temperature,
                status: HosVitalStatus.high,
              ),
              HosVital(
                label: 'SpO₂',
                value: '97',
                unit: '%',
                icon: HosIcons.vitals,
                status: HosVitalStatus.normal,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          HosPrescriptionCard(
            drugName: 'Metformin',
            dosage: '500 mg',
            frequency: '2× daily',
            duration: '30 days',
            instructions: 'Take after meals.',
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          HosLabReportCard(
            title: 'Complete Blood Count',
            date: DateTime.now().subtract(const Duration(days: 3)),
            lab: 'MediLab',
            status: HosLabReportStatus.reviewed,
            abnormalCount: 2,
            onTap: () {},
          ),
        ],
      );

  Widget _appointmentAndStat() => Column(
        children: [
          HosAppointmentCard(
            personName: 'Dr. Priya Rao',
            personRole: 'Cardiologist',
            when: DateTime.now().add(const Duration(days: 2, hours: 3)),
            location: 'Prasanthi Hospital',
            forWhom: 'Self',
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.3,
            children: [
              HosStatCard(
                label: 'Total patients',
                value: '1,284',
                icon: HosIcons.patients,
                trend: '+12%',
                trendPositive: true,
              ),
              HosStatCard(
                label: 'Active doctors',
                value: '48',
                icon: HosIcons.doctors,
                accent: AppColors.secondary,
                trend: '+2',
                trendPositive: true,
              ),
              HosStatCard(
                label: 'Today',
                value: '36',
                icon: HosIcons.appointment,
                accent: AppColors.warning,
              ),
              HosStatCard(
                label: 'Pending verifications',
                value: '7',
                icon: HosIcons.pending,
                accent: AppColors.error,
                trend: '-3',
                trendPositive: true,
              ),
            ],
          ),
        ],
      );

  Widget _avatars() => Row(
        children: [
          const HosAvatar(name: 'Jane Doe', radius: 24),
          const SizedBox(width: AppSpacing.md),
          const HosAvatar(name: 'P R', radius: 32),
          const SizedBox(width: AppSpacing.md),
          HosHealthIdBadge(healthId: 'HO-A7KQ2F'),
        ],
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

part of 'dashboard_content.dart';

class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorTab = kIsWeb ? 1 : 2;
    final recordsTab = kIsWeb ? 2 : 3;
    final triageTab = kIsWeb ? 3 : 4;

    final actions = [
      _ActionData(
        'Book appointment',
        'Schedule consultation',
        Icons.calendar_month_rounded,
        AppColors.primaryGradient,
        () {
          ref.read(selectedDoctorCategoryProvider.notifier).setCategory('All');
          ref.read(selectedDoctorQueryProvider.notifier).setQuery('');
          onNavigate(doctorTab);
        },
      ),
      _ActionData(
        'Find a doctor',
        'Browse specialists',
        Icons.medical_services_rounded,
        AppColors.purpleGradient,
        () {
          ref.read(selectedDoctorCategoryProvider.notifier).setCategory('All');
          ref.read(selectedDoctorQueryProvider.notifier).setQuery('');
          onNavigate(doctorTab);
        },
      ),
      _ActionData(
        'View records',
        'Access reports & lab tests',
        Icons.folder_shared_rounded,
        AppColors.secondaryGradient,
        () => onNavigate(recordsTab),
      ),
      _ActionData(
        'Check symptoms',
        'AI Health Assistant',
        Icons.health_and_safety_rounded,
        AppColors.emeraldGradient,
        () => onNavigate(triageTab),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppBreakpoints.tabletMax
            ? 4
            : constraints.maxWidth >= AppBreakpoints.mobileMax
            ? 2
            : 2;
        final spacing = constraints.maxWidth < 400 ? 10.0 : 16.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final action in actions)
              SizedBox(
                width: itemWidth,
                child: _QuickActionCard(
                  data: action,
                  onTap: action.onTap,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({required this.data, required this.onTap});

  final _ActionData data;
  final VoidCallback onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.data.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          child: GlassContainer(
            borderRadius: 24,
            opacity: _hovered ? 0.85 : 0.65,
            borderColor: _hovered ? widget.data.gradient.colors.first.withOpacity(0.5) : Colors.white.withOpacity(0.75),
            onTap: widget.onTap,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: widget.data.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.gradient.colors.first.withOpacity(
                          0.30,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  widget.data.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.data.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


part of 'dashboard_content.dart';

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('Book appointment', Icons.calendar_month_outlined, 1),
      _ActionData('Find a doctor', Icons.person_search_outlined, 1),
      _ActionData('View records', Icons.folder_open_outlined, 2),
      _ActionData('Check symptoms', Icons.chat_bubble_outline_rounded, 3),
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
                  onTap: () => onNavigate(action.destination),
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
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: _hovered ? AppColors.primary : AppColors.border,
            ),
            boxShadow: _hovered
                ? const [
                    BoxShadow(
                      color: Color(0x142563EB),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Icon(widget.data.icon, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    widget.data.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  const Text('Open'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

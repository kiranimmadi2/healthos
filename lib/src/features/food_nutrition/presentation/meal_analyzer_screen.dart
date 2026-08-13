import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/presentation/shell/health_page.dart';
import '../application/food_nutrition_providers.dart';
import '../domain/meal_analysis.dart';

class MealAnalyzerScreen extends ConsumerStatefulWidget {
  const MealAnalyzerScreen({super.key});

  @override
  ConsumerState<MealAnalyzerScreen> createState() => _MealAnalyzerScreenState();
}

class _MealAnalyzerScreenState extends ConsumerState<MealAnalyzerScreen> {
  final _inputController = TextEditingController();
  String _selectedMealType = 'Lunch ☀️';

  static const _mealTypes = ['Breakfast 🌅', 'Lunch ☀️', 'Dinner 🌙', 'Snack 🍎'];

  static const _presetMeals = [
    {'name': 'Oatmeal with blueberries & chia seeds', 'type': 'Breakfast 🌅'},
    {'name': 'Grilled chicken breast with quinoa & broccoli', 'type': 'Lunch ☀️'},
    {'name': '2 Pepperoni pizza slices & iced tea', 'type': 'Lunch ☀️'},
    {'name': 'Steamed salmon with asparagus & rice', 'type': 'Dinner 🌙'},
    {'name': 'Chocolate donut & caramel latte', 'type': 'Snack 🍎'},
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _onAnalyzePressed() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    ref.read(mealAnalysisProvider.notifier).analyzeMeal(
          foodDescription: text,
          mealType: _selectedMealType,
        );
  }

  void _selectPreset(String foodName, String mealType) {
    setState(() {
      _inputController.text = foodName;
      _selectedMealType = mealType;
    });
    _onAnalyzePressed();
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(mealAnalysisProvider);

    return HealthPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOnDeviceHeader(context),
          const SizedBox(height: AppSpacing.lg),
          _buildInputCard(context, analysisState.isLoading),
          const SizedBox(height: AppSpacing.xl),
          if (analysisState.isLoading)
            _buildLoadingIndicator()
          else if (analysisState.currentResult != null)
            _buildAnalysisResults(context, analysisState.currentResult!)
          else
            _buildPresetsAndIntro(context),
          if (analysisState.history.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            _buildHistorySection(context, analysisState.history),
          ],
        ],
      ),
    );
  }

  Widget _buildOnDeviceHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'On-Device Gemma 2B',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withOpacity(0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, color: AppColors.success, size: 12),
                          SizedBox(width: 4),
                          Text(
                            '100% Offline & Private',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Runs locally on device memory to evaluate food safety against your medical history.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, bool isLoading) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.75)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0x08000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What food or meal are you planning to eat?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Describe the dish, portion size, or ingredients for Instant Gemma AI safety triage.',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Meal category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _mealTypes.map((type) {
                final isSelected = _selectedMealType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: isDark ? const Color(0xFF1E3A8A) : AppColors.primarySoft,
                    backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.surfaceMuted,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
                          : (isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? (isDark ? const Color(0xFF60A5FA) : AppColors.primary)
                          : (isDark ? const Color(0xFF334155) : AppColors.border),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedMealType = type);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Text Field Input
          TextField(
            controller: _inputController,
            enabled: !isLoading,
            maxLines: 2,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. 2 slices whole wheat toast with mashed avocado & 2 poached eggs',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                fontSize: 14,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A).withOpacity(0.6) : AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Analyze Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _onAnalyzePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.psychology_rounded, size: 20),
              label: const Text(
                'Analyze Meal with On-Device Gemma',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'On-Device Gemma 2B Processing...',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Evaluating calories, glycemic load & personal health risks on local GPU/NPU',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsAndIntro(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Text(
              'Or try a quick preset meal:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetMeals.map((preset) {
            return ActionChip(
              avatar: const Icon(Icons.restaurant_menu_rounded, size: 16, color: AppColors.primary),
              label: Text(preset['name']!),
              backgroundColor: isDark ? const Color(0xFF1E293B).withOpacity(0.7) : AppColors.surface,
              side: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border),
              labelStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.textPrimary),
              onPressed: () => _selectPreset(preset['name']!, preset['type']!),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAnalysisResults(BuildContext context, MealAnalysisResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    switch (result.suitability) {
      case HealthSuitability.safe:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        statusTitle = 'SAFE & WELL-BALANCED MEAL';
        break;
      case HealthSuitability.moderateCaution:
        statusColor = AppColors.warning;
        statusIcon = Icons.warning_amber_rounded;
        statusTitle = 'MODERATE CAUTION RECOMMENDED';
        break;
      case HealthSuitability.highRisk:
        statusColor = AppColors.error;
        statusIcon = Icons.error_rounded;
        statusTitle = 'HIGH HEALTH RISK FOR YOUR PROFILE';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Suitability Banner Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(isDark ? 0.18 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: statusColor.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      statusTitle,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: ${result.suitabilityScore}/100',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                result.gemmaSummary,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Nutritional Macros Grid
        Text(
          'Estimated Macro Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _buildMacroTile(
                  context: context,
                  label: 'Calories',
                  value: '${result.macros.calories} kcal',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.deepOrange,
                ),
                _buildMacroTile(
                  context: context,
                  label: 'Carbohydrates',
                  value: '${result.macros.carbsGrams}g',
                  icon: Icons.grain_rounded,
                  color: Colors.amber,
                ),
                _buildMacroTile(
                  context: context,
                  label: 'Protein',
                  value: '${result.macros.proteinGrams}g',
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.primary,
                ),
                _buildMacroTile(
                  context: context,
                  label: 'Healthy Fats',
                  value: '${result.macros.fatGrams}g',
                  icon: Icons.opacity_rounded,
                  color: Colors.purple,
                ),
                _buildMacroTile(
                  context: context,
                  label: 'Dietary Fiber',
                  value: '${result.macros.fiberGrams}g',
                  icon: Icons.grass_rounded,
                  color: AppColors.success,
                ),
                _buildMacroTile(
                  context: context,
                  label: 'Sugars',
                  value: '${result.macros.sugarGrams}g',
                  icon: Icons.cookie_rounded,
                  color: Colors.pink,
                ),
                _buildMacroTile(
                  context: context,
                  label: 'Sodium',
                  value: '${result.macros.sodiumMg.toInt()}mg',
                  icon: Icons.water_drop_rounded,
                  color: Colors.teal,
                ),
                _buildMacroTile(
                  context: context,
                  label: 'Glycemic Index',
                  value: '${result.macros.glycemicIndex}',
                  icon: Icons.show_chart_rounded,
                  color: Colors.indigo,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // Patient Specific Warnings & Recommendations
        if (result.healthWarnings.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF450A0A) : AppColors.errorSoft,
              borderRadius: BorderRadius.circular(AppRadius.small),
              border: Border.all(color: AppColors.error.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.health_and_safety_rounded, color: AppColors.error, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Personal Medical Alerts',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...result.healthWarnings.map(
                  (warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $warning',
                      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Portion Advice Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B).withOpacity(0.75) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A8A) : AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.tips_and_updates_rounded, color: isDark ? const Color(0xFF60A5FA) : AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gemma Portion Recommendation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.portionAdvice,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroTile({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.75) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, List<MealAnalysisResult> history) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Processed Meals',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length.clamp(0, 5),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = history[index];
            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withOpacity(0.75) : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fastfood_rounded,
                    color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.foodName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${item.mealType} • ${item.macros.calories} kcal • Glycemic Index ${item.macros.glycemicIndex}',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    dateFormat.format(item.timestamp),
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

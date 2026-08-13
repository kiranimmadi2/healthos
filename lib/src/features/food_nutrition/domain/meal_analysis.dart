enum GemmaModelStatus {
  initializing,
  readyOnDevice,
  runningInference,
  fallbackCloud,
  error,
}

enum HealthSuitability {
  safe,
  moderateCaution,
  highRisk,
}

class NutritionalMacros {
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;
  final double sugarGrams;
  final double sodiumMg;
  final int glycemicIndex;

  const NutritionalMacros({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.sugarGrams,
    required this.sodiumMg,
    required this.glycemicIndex,
  });

  factory NutritionalMacros.fromJson(Map<String, dynamic> json) {
    return NutritionalMacros(
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0.0,
      fiberGrams: (json['fiberGrams'] as num?)?.toDouble() ?? 0.0,
      sugarGrams: (json['sugarGrams'] as num?)?.toDouble() ?? 0.0,
      sodiumMg: (json['sodiumMg'] as num?)?.toDouble() ?? 0.0,
      glycemicIndex: (json['glycemicIndex'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'fiberGrams': fiberGrams,
        'sugarGrams': sugarGrams,
        'sodiumMg': sodiumMg,
        'glycemicIndex': glycemicIndex,
      };
}

class MealAnalysisResult {
  final String foodName;
  final String mealType;
  final DateTime timestamp;
  final NutritionalMacros macros;
  final HealthSuitability suitability;
  final int suitabilityScore; // 0 to 100
  final List<String> healthWarnings;
  final List<String> benefits;
  final String portionAdvice;
  final String gemmaSummary;
  final bool isOnDeviceInference;

  const MealAnalysisResult({
    required this.foodName,
    required this.mealType,
    required this.timestamp,
    required this.macros,
    required this.suitability,
    required this.suitabilityScore,
    required this.healthWarnings,
    required this.benefits,
    required this.portionAdvice,
    required this.gemmaSummary,
    required this.isOnDeviceInference,
  });

  factory MealAnalysisResult.fromJson(Map<String, dynamic> json) {
    HealthSuitability suitability;
    final levelStr = (json['suitability'] as String?)?.toLowerCase() ?? 'safe';
    if (levelStr.contains('high') || levelStr.contains('risk') || levelStr.contains('avoid')) {
      suitability = HealthSuitability.highRisk;
    } else if (levelStr.contains('moderate') || levelStr.contains('caution') || levelStr.contains('warning')) {
      suitability = HealthSuitability.moderateCaution;
    } else {
      suitability = HealthSuitability.safe;
    }

    return MealAnalysisResult(
      foodName: json['foodName'] as String? ?? 'Custom Meal',
      mealType: json['mealType'] as String? ?? 'General Meal',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      macros: NutritionalMacros.fromJson(json['macros'] as Map<String, dynamic>? ?? {}),
      suitability: suitability,
      suitabilityScore: (json['suitabilityScore'] as num?)?.toInt() ?? 85,
      healthWarnings: (json['healthWarnings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      portionAdvice: json['portionAdvice'] as String? ?? 'Standard portion suitable.',
      gemmaSummary: json['gemmaSummary'] as String? ?? 'Meal processed by Gemma Model.',
      isOnDeviceInference: json['isOnDeviceInference'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'foodName': foodName,
        'mealType': mealType,
        'timestamp': timestamp.toIso8601String(),
        'macros': macros.toJson(),
        'suitability': suitability.name,
        'suitabilityScore': suitabilityScore,
        'healthWarnings': healthWarnings,
        'benefits': benefits,
        'portionAdvice': portionAdvice,
        'gemmaSummary': gemmaSummary,
        'isOnDeviceInference': isOnDeviceInference,
      };
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/application/user_providers.dart';
import '../data/nutrition_ai_service.dart';
import '../domain/meal_analysis.dart';

final nutritionAiServiceProvider = Provider<NutritionAiService>((ref) {
  return NutritionAiService();
});

/// Past analyses for the signed-in patient.
///
/// Previously history lived only in memory and was lost on every restart.
final mealHistoryProvider =
    StreamProvider<List<MealAnalysisResult>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('meal_analyses')
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => MealAnalysisResult.fromJson(doc.data()))
            .toList(),
      );
});

class MealAnalysisState {
  const MealAnalysisState({
    this.status = NutritionAiStatus.idle,
    this.currentResult,
    this.error,
  });

  final NutritionAiStatus status;
  final MealAnalysisResult? currentResult;

  /// The raw failure, rendered through `describeFailure` at the call site.
  final Object? error;

  bool get isLoading => status == NutritionAiStatus.analyzing;

  MealAnalysisState copyWith({
    NutritionAiStatus? status,
    MealAnalysisResult? currentResult,
    Object? error,
    bool clearResult = false,
    bool clearError = true,
  }) {
    return MealAnalysisState(
      status: status ?? this.status,
      currentResult: clearResult ? null : (currentResult ?? this.currentResult),
      error: clearError ? error : (error ?? this.error),
    );
  }
}

class MealAnalysisNotifier extends Notifier<MealAnalysisState> {
  @override
  MealAnalysisState build() => const MealAnalysisState();

  Future<void> analyzeMeal({
    required String foodDescription,
    required String mealType,
  }) async {
    state = state.copyWith(status: NutritionAiStatus.analyzing, error: null);

    try {
      final profile = ref.read(currentUserProfileProvider).value;
      final result = await ref
          .read(nutritionAiServiceProvider)
          .analyzeMeal(
            foodDescription: foodDescription,
            mealType: mealType,
            patientProfile: profile,
          );

      state = state.copyWith(
        status: NutritionAiStatus.idle,
        currentResult: result,
      );
      await _persist(result);
    } catch (error) {
      // Surface the failure. Never substitute an estimate.
      state = state.copyWith(status: NutritionAiStatus.error, error: error);
    }
  }

  Future<void> _persist(MealAnalysisResult result) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('meal_analyses')
          .add(result.toJson());
    } catch (error) {
      // History is a convenience; a write failure must not lose the result
      // already on screen.
      debugPrint('Could not save meal analysis: $error');
    }
  }

  void clearCurrentResult() {
    state = state.copyWith(clearResult: true, error: null);
  }
}

final mealAnalysisProvider =
    NotifierProvider<MealAnalysisNotifier, MealAnalysisState>(
  MealAnalysisNotifier.new,
);

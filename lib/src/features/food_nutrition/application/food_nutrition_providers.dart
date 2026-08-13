import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/user_providers.dart';
import '../data/on_device_gemma_service.dart';
import '../domain/meal_analysis.dart';

final onDeviceGemmaServiceProvider = Provider<OnDeviceGemmaService>((ref) {
  return OnDeviceGemmaService();
});

final gemmaModelStatusProvider = Provider<GemmaModelStatus>((ref) {
  final service = ref.watch(onDeviceGemmaServiceProvider);
  return service.currentStatus;
});

class MealAnalysisState {
  final bool isLoading;
  final MealAnalysisResult? currentResult;
  final List<MealAnalysisResult> history;
  final String? errorMessage;

  const MealAnalysisState({
    this.isLoading = false,
    this.currentResult,
    this.history = const [],
    this.errorMessage,
  });

  MealAnalysisState copyWith({
    bool? isLoading,
    MealAnalysisResult? currentResult,
    List<MealAnalysisResult>? history,
    String? errorMessage,
  }) {
    return MealAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      currentResult: currentResult ?? this.currentResult,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }
}

class MealAnalysisNotifier extends Notifier<MealAnalysisState> {
  @override
  MealAnalysisState build() {
    return const MealAnalysisState();
  }

  Future<void> analyzeMeal({
    required String foodDescription,
    required String mealType,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final profile = await ref.read(userProfileProvider.future);
      final service = ref.read(onDeviceGemmaServiceProvider);

      final result = await service.processFoodItem(
        foodDescription: foodDescription,
        mealType: mealType,
        patientProfile: profile,
      );

      final updatedHistory = [result, ...state.history];
      state = state.copyWith(
        isLoading: false,
        currentResult: result,
        history: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to process meal with Gemma model: $e',
      );
    }
  }

  void clearCurrentResult() {
    state = state.copyWith(currentResult: null);
  }
}

final mealAnalysisProvider = NotifierProvider<MealAnalysisNotifier, MealAnalysisState>(() {
  return MealAnalysisNotifier();
});

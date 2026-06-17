import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai_service.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

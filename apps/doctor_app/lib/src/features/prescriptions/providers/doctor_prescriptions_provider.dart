import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/doctor_provider.dart';

final doctorPrescriptionsProvider = FutureProvider<List<Prescription>>((ref) async {
  final doctor = ref.watch(currentDoctorProvider);

  return doctor.when(
    data: (doc) {
      if (doc == null) return [];
      return ref.watch(
        prescriptionsRepositoryProvider
      ).getDoctorPrescriptions(doc.id);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

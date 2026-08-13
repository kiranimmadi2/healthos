import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';
import '../domain/medical_record.dart';

/// Tint for a [RecordCategory], shared by every surface that shows records.
///
/// The same category-to-colour mapping was written out in the patient records
/// list, the doctor's patient timeline and the diagnostic report tile. Only the
/// colour is shared: each surface keeps its own icon on purpose (a lab report
/// reads as a blood drop in the records list but as a document in a timeline),
/// so folding the icons together here would change the UI rather than tidy it.
Color recordCategoryColor(BuildContext context, String category) {
  final hos = context.hos;
  return switch (category) {
    RecordCategory.labReport => hos.categoryLab,
    RecordCategory.prescription => hos.categoryPrescription,
    RecordCategory.imaging => hos.categoryImaging,
    RecordCategory.immunization => hos.categoryImmunization,
    _ => hos.categoryOther,
  };
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthos/src/features/auth/application/user_providers.dart';
import 'package:healthos/src/features/auth/domain/user_profile.dart';
import 'package:healthos/src/features/doctor_portal/application/doctor_portal_providers.dart';
import 'package:healthos/src/features/doctor_portal/domain/doctor_workspace_models.dart';
import 'package:healthos/src/features/records/application/record_providers.dart';
import 'package:healthos/src/features/records/domain/medical_record.dart';

/// These tests are only possible because the provider no longer builds
/// IconData/Color values — it used to need a widget binding to run at all.
void main() {
  MedicalRecord record({
    String id = 'r1',
    String title = 'Full blood count',
    String category = RecordCategory.labReport,
    String notes = '',
    String patientId = 'p1',
  }) {
    return MedicalRecord(
      id: id,
      title: title,
      category: category,
      notes: notes,
      date: DateTime(2026, 5, 1),
      patientId: patientId,
    );
  }

  List<DiagnosticReport> reportsFrom(List<MedicalRecord> records) {
    final container = ProviderContainer(
      overrides: [
        allRecordsProvider.overrideWithValue(AsyncValue.data(records)),
        allPatientsProvider.overrideWithValue(
          AsyncValue.data([
            UserProfile.fromMap('p1', const {'name': 'Sarah Connor'}),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(allDiagnosticReportsProvider).value ?? const [];
  }

  group('report selection', () {
    test('includes only lab reports and imaging', () {
      final reports = reportsFrom([
        record(id: 'a', category: RecordCategory.labReport),
        record(id: 'b', category: RecordCategory.imaging),
        record(id: 'c', category: RecordCategory.prescription),
        record(id: 'd', category: RecordCategory.immunization),
        record(id: 'e', category: RecordCategory.other),
      ]);

      expect(reports.map((r) => r.id), ['a', 'b']);
    });

    test('resolves the patient name, falling back when unknown', () {
      final reports = reportsFrom([
        record(id: 'a', patientId: 'p1'),
        record(id: 'b', patientId: 'ghost'),
      ]);

      expect(reports.first.patient, 'Sarah Connor');
      expect(reports.last.patient, 'Unknown Patient');
    });

    test('substitutes a placeholder for empty notes', () {
      expect(reportsFrom([record(notes: '')]).single.summary, 'No notes provided');
      expect(reportsFrom([record(notes: 'Stable')]).single.summary, 'Stable');
    });

    test('carries the category through instead of an icon', () {
      expect(
        reportsFrom([record(category: RecordCategory.imaging)]).single.category,
        RecordCategory.imaging,
      );
    });

    test('every report starts as needing review', () {
      expect(reportsFrom([record()]).single.status, ReportStatus.needsReview);
    });
  });

  group('priority', () {
    ReportPriority priorityFor({String title = 'Panel', String notes = ''}) =>
        reportsFrom([record(title: title, notes: notes)]).single.priority;

    test('defaults to normal', () {
      expect(priorityFor(), ReportPriority.normal);
      expect(priorityFor().isHigh, isFalse);
    });

    test('matches critical and elevated in the title', () {
      expect(priorityFor(title: 'Critical panel'), ReportPriority.high);
      expect(priorityFor(title: 'Elevated markers'), ReportPriority.high);
    });

    test('matches critical, high and danger in the notes', () {
      expect(priorityFor(notes: 'critical value'), ReportPriority.high);
      expect(priorityFor(notes: 'high reading'), ReportPriority.high);
      expect(priorityFor(notes: 'danger zone'), ReportPriority.high);
    });

    test('is case insensitive', () {
      expect(priorityFor(title: 'CRITICAL'), ReportPriority.high);
      expect(priorityFor(notes: 'DANGER'), ReportPriority.high);
    });

    // The term lists are deliberately asymmetric, carried over unchanged from
    // the original implementation. Pinned so the quirk is visible rather than
    // accidentally "fixed" later without a decision.
    test('does not match note-only terms in the title', () {
      expect(priorityFor(title: 'High cholesterol panel'), ReportPriority.normal);
      expect(priorityFor(title: 'Danger'), ReportPriority.normal);
    });

    test('does not match title-only terms in the notes', () {
      expect(priorityFor(notes: 'elevated'), ReportPriority.normal);
    });
  });
}

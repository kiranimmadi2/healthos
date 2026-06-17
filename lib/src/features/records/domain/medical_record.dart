import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class RecordCategory {
  static const labReport = 'Lab report';
  static const prescription = 'Prescription';
  static const imaging = 'Imaging';
  static const immunization = 'Immunization';
  static const other = 'Other';

  static const all = [labReport, prescription, imaging, immunization, other];
}

class MedicalRecord {
  MedicalRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.notes,
    required this.date,
  });

  final String id;
  final String title;
  final String category;
  final String notes;
  final DateTime date;

  factory MedicalRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MedicalRecord(
      id: doc.id,
      title: data['title'] as String? ?? 'Record',
      category: data['category'] as String? ?? RecordCategory.other,
      notes: data['notes'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

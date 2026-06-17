import 'package:cloud_firestore/cloud_firestore.dart';

class ChatThread {
  ChatThread({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String lastMessage;
  final DateTime? lastMessageAt;

  static String threadId(String patientId, String doctorId) =>
      '${patientId}_$doctorId';

  factory ChatThread.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatThread(
      id: doc.id,
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? 'Patient',
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? 'Doctor',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }
}

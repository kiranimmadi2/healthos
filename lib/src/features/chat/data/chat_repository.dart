import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';

class ChatRepository {
  final FirebaseFirestore _db;
  ChatRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  Stream<List<ChatThread>> watchThreads(String uid) {
    return _chats
        .where('participants', arrayContains: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(ChatThread.fromDoc).toList()
            ..sort(
              (a, b) => (b.lastMessageAt ?? DateTime(2000)).compareTo(
                a.lastMessageAt ?? DateTime(2000),
              ),
            ),
        );
  }

  Stream<List<ChatMessage>> watchMessages(String threadId) {
    return _chats
        .doc(threadId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ChatMessage.fromDoc).toList());
  }

  /// Creates the thread if it does not exist yet, then returns its id.
  Future<String> openThread({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
  }) async {
    final threadId = ChatThread.threadId(patientId, doctorId);
    await _chats.doc(threadId).set({
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'participants': [patientId, doctorId],
    }, SetOptions(merge: true));
    return threadId;
  }

  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String text,
  }) async {
    final thread = _chats.doc(threadId);
    final message = thread.collection('messages').doc();
    final batch = _db.batch();
    batch.set(message, {
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    });
    batch.set(thread, {
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }
}

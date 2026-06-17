import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(FirebaseFirestore.instance),
);

/// Chat threads the signed-in user participates in, latest activity first.
final chatThreadsProvider = StreamProvider<List<ChatThread>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(chatRepositoryProvider).watchThreads(user.uid);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  ref,
  threadId,
) {
  return ref.watch(chatRepositoryProvider).watchMessages(threadId);
});

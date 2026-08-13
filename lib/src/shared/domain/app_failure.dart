import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Turns an arbitrary thrown object into copy that is safe to show a patient.
///
/// Screens used to render `Text('Error: $e')`, which leaks stack-shaped
/// internals into a medical UI. Everything user-facing goes through here; the
/// raw error is still available under [debugDetail] for debug builds only.
String describeFailure(Object? error) {
  if (error == null) return 'Something went wrong.';

  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'network-request-failed' =>
        "You're offline. Check your connection and try again.",
      'too-many-requests' =>
        'Too many attempts. Please wait a moment before retrying.',
      'user-disabled' => 'This account has been disabled.',
      _ => error.message ?? 'We could not complete that sign-in step.',
    };
  }

  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' => "You don't have access to this.",
      'unavailable' || 'network-request-failed' =>
        "You're offline. We'll retry when you reconnect.",
      'deadline-exceeded' => 'That took too long. Please try again.',
      'not-found' => 'This item no longer exists.',
      'already-exists' => 'That already exists.',
      'resource-exhausted' => 'Service is busy right now. Try again shortly.',
      // Surfaces while a composite index is still building after a deploy.
      'failed-precondition' =>
        'This view needs a database index that has not finished building yet.',
      'unauthenticated' => 'Please sign in again.',
      _ => 'Something went wrong while talking to the server.',
    };
  }

  // Exceptions that already carry deliberately user-facing text.
  final text = error.toString();
  if (error is Exception && !text.startsWith('Exception:')) return text;

  return 'Something went wrong.';
}

/// Raw error text, for debug builds only. Returns null in release so internals
/// never reach a patient's screen.
String? debugDetail(Object? error) {
  if (!kDebugMode || error == null) return null;
  return error.toString();
}

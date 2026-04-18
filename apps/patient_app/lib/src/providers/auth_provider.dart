import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.onAuthStateChange.map((state) => state.session?.user);
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.id;
});


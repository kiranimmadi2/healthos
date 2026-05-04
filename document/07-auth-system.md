# 07 — Auth System

The single most important issue in the codebase. Read this if anything about login, profile loading, or RLS is misbehaving.

---

## What's wrong in one sentence

**Authentication runs through Firebase, but the database thinks it's still using Supabase Auth — so a logged-in user has no row in Supabase's `auth.users`, and every `auth.uid()`-based RLS policy and `patients.auth_id` lookup quietly returns nothing.**

---

## How it got this way

The last commit on this branch swapped [packages/supabase_client/lib/src/auth/auth_service.dart](../packages/supabase_client/lib/src/auth/auth_service.dart) wholesale from a Supabase Auth implementation to a Firebase Auth one. The likely motivation was needing `firebase_messaging` for FCM push, plus a more battle-tested mobile phone-OTP path.

What did **not** change in the same pass:
- The Supabase client is still initialised in every `main.dart`.
- Every repository still calls `Supabase.instance.client.from(...)`.
- `patients.auth_id` and `doctors.auth_id` are still `uuid` columns intended to match Supabase's `auth.users.id`.
- RLS policies and helper functions (`get_patient_id_for_user()`) compare against `auth.uid()` (Supabase's notion of the current user).

So the app is now in a split-brain state: the *frontend* knows who you are (Firebase UID), but the *backend* doesn't (Supabase sees you as anon).

---

## What still works

- The bare login UI (you can complete a phone OTP and end up with a Firebase user).
- Anything that does not require RLS authentication — i.e., almost nothing in production. Some screens may *appear* to work in development if RLS is open or service-role keys are involved.

## What is broken

- Profile fetch after login: `select * from patients where auth_id = ?` — there's no value to pass that maps to anything in the table.
- The router's "is profile missing?" gate: it hits the broken fetch and falls through to "missing" → loops back to setup forever.
- Profile setup itself: even when you create a `patients` row, the `auth_id` column will be blank or wrong, so the next session won't find it.
- All RLS-gated reads/writes (lab reports, visits, appointments, etc).
- Doctor "account not found" screen: depends on the same broken fetch.

---

## How to fix it

### Recommended path: revert AuthService to Supabase Auth

1. Rewrite `auth_service.dart`:
   ```dart
   class AuthService {
     final _client = Supabase.instance.client;

     User? get currentUser => _client.auth.currentUser;
     Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

     Future<AuthResponse> signInWithEmail({required String email, required String password}) =>
         _client.auth.signInWithPassword(email: email, password: password);

     Future<void> signInWithPhone(String phone) =>
         _client.auth.signInWithOtp(phone: phone);

     Future<AuthResponse> verifyPhoneOtp({required String phone, required String token}) =>
         _client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);

     Future<bool> signInWithGoogle() => _client.auth.signInWithOAuth(
           OAuthProvider.google,
           redirectTo: kIsWeb ? null : 'io.supabase.healthos://login-callback',
         );

     Future<void> signOut() => _client.auth.signOut();
   }
   ```
2. Update each app's `auth_provider.dart`:
   ```dart
   final authStateProvider = StreamProvider<AuthState>((ref) =>
       ref.watch(authServiceProvider).onAuthStateChange);

   final currentUserIdProvider = Provider<String?>((ref) =>
       ref.watch(authStateProvider).valueOrNull?.session?.user.id);
   ```
3. Update routers — change `next.valueOrNull?.uid` to `next.valueOrNull?.session?.user.id`.
4. Remove `firebase_auth` and `google_sign_in` from each app's `pubspec.yaml`. **Keep** `firebase_core` and `firebase_messaging` — those are needed for FCM push.
5. Confirm Android/iOS deep link configuration matches the Supabase callback scheme:
   - Android: `apps/<app>/android/app/src/main/AndroidManifest.xml` — intent filter for `io.supabase.healthos://login-callback`.
   - iOS: `apps/<app>/ios/Runner/Info.plist` — `CFBundleURLTypes` entry.
   - Web: Supabase project → Auth → URL Configuration → add the deployed web origin.
6. Provision real Google OAuth credentials and configure them in Supabase project → Auth → Providers → Google.
7. Smoke test the full flow per [04-implementation-plan.md Stage 1](04-implementation-plan.md).

### Alternative path: keep Firebase, bridge it

If there's a reason to stay on Firebase Auth (e.g., investment in Firebase phone OTP infrastructure):

1. Configure Supabase to accept Firebase ID tokens. This is a custom JWT setup — you swap `SUPABASE_JWT_SECRET` for Firebase's public keys / verifier.
2. After Firebase sign-in on the client, fetch the ID token and call `Supabase.instance.client.auth.setSession(...)` with it.
3. Migrate `patients.auth_id` from `uuid` to `text` and store the Firebase UID. Migrate existing rows.
4. Rewrite RLS helper functions to compare against the Firebase UID (read from the JWT claim).

This is significantly more work and changes the data model. Don't do it unless there's a hard requirement.

---

## How to verify the fix

After applying the recommended path, every one of these should work:

1. `flutter run` the patient app, sign in with phone OTP. End up at `/auth/setup` (no profile yet).
2. Fill out the profile form, submit. End up at `/home`. Open Supabase studio: `select auth_id from patients where id = ...` returns a UUID matching `select id from auth.users limit 1`.
3. Cold restart the app, sign in again. End up directly at `/home` (profile detected).
4. From the doctor app, log in as a pre-created doctor. End up at the dashboard.
5. From the doctor app, log in as a Firebase user with no `doctors` row. End up on the "Account not found" screen.
6. RLS smoke: as a patient, `select * from prescriptions` from the app returns only your rows. From a different user's session, returns rows for that user (or zero).

---

## Don't fix this in isolation

Bundle the auth fix with:
- [ISSUE-005](03-known-issues.md) — moving credentials into env. You'll be touching `main.dart` anyway.
- [ISSUE-007](03-known-issues.md) — deep link / OAuth credential config. Same surface area.

Doing them together is one focused PR; doing them separately means three rounds of "test the auth flow" overhead.

# 03 — Known Issues

Concrete bugs, schema/model mismatches, and architectural mistakes. Each entry has a **Fix plan** that should leave the codebase healthier.

When an issue is fixed, **delete it from this file** and add an entry to [CHANGELOG.md](CHANGELOG.md). Do not let resolved issues linger here.

---

## ISSUE-001 — Auth split-brain (Firebase vs Supabase) 🔴 CRITICAL

**Where:**
- [packages/supabase_client/lib/src/auth/auth_service.dart](../packages/supabase_client/lib/src/auth/auth_service.dart) — entirely Firebase.
- Each app's `main.dart` still initialises Supabase (with hardcoded URL/anon key).
- Each app's `auth_provider.dart` exposes a Firebase `User?` stream.
- DB schema: `patients.auth_id`, `doctors.auth_id` are typed `uuid` and intended to match `auth.users.id` from **Supabase Auth**.

**Symptom:** When a user signs in via Firebase, their Firebase UID has no corresponding row in Supabase's `auth.users`, so `patients.auth_id = current_supabase_user_id()` joins return nothing. Every RLS policy, every "load my profile" query, and every `get_patient_id_for_user()` function call breaks.

**Fix plan (pick ONE path):**

### Path A — Go all-in on Supabase Auth (recommended; matches spec)
1. Rip Firebase Auth out of `auth_service.dart`. Keep `firebase_messaging` for FCM push only — that does **not** require Firebase Auth.
2. Re-implement `signInWithPhone`, `signInWithEmailOtp`, `signInWithEmail`, `signInWithGoogle` against `Supabase.instance.client.auth`.
3. Restore the Supabase deep-link redirect (`io.supabase.healthos://login-callback`) for Google OAuth on mobile, and the matching web redirect URL.
4. Remove `firebase_auth` and `google_sign_in` from every app's `pubspec.yaml`.
5. In each `auth_provider.dart`, change `Stream<User?>` (Firebase) → `Stream<AuthState>` (Supabase) and update consumers (notably the routers).
6. Re-test the patient signup flow end-to-end.

### Path B — Stay on Firebase Auth, bridge to Supabase
1. Set up Supabase as a JWT-verifying backend that trusts Firebase ID tokens (`SUPABASE_JWT_SECRET` swap, custom auth hook).
2. Mint a Supabase session from the Firebase ID token on the client; pass it to the Supabase client via `setSession()`.
3. Change `patients.auth_id` to `text` and store the Firebase UID instead of a Supabase UUID. Migrate existing rows.
4. Rewrite RLS helper functions (`get_patient_id_for_user`) to compare against the Firebase UID claim.

**Recommendation:** Path A. The DB schema and RLS already assume Supabase Auth. Path B requires DB schema changes and reworking every policy. The reason Firebase was introduced (per the diff) appears to be to use `firebase_messaging` for push — that does not require swapping the auth backend.

---

## ISSUE-002 — `Visit` model out of sync with DB 🔴 BLOCKS VISIT FLOW

**Where:** [packages/core/lib/src/models/visit.dart](../packages/core/lib/src/models/visit.dart)

**Problem:** Migration [20260418000002_family_and_clinical.sql](../supabase/migrations/20260418000002_family_and_clinical.sql) added `follow_up_date`, `icd_code`, `visit_type`, `triage_level` to the `visits` table. The Dart model still has only `chief_complaint`, `diagnosis`, `notes`, `visited_at`. The `CreateVisitScreen` writes the new columns directly via the Supabase client; reads via the model silently drop them.

**Fix plan:**
1. Add the four fields to `Visit`:
   ```dart
   @JsonKey(name: 'follow_up_date') DateTime? followUpDate,
   @JsonKey(name: 'icd_code') String? icdCode,
   @JsonKey(name: 'visit_type') String? visitType,
   @JsonKey(name: 'triage_level') String? triageLevel,
   ```
2. Run `dart run build_runner build --delete-conflicting-outputs` in `packages/core` to regenerate `.freezed.dart` / `.g.dart`.
3. Verify `VisitRepository` reads include them (it should automatically once the model knows).
4. Surface `followUpDate`, `triageLevel`, `visitType` in any visit detail UI (and in the patient-side visits list once that exists — see [02-pending-features.md](02-pending-features.md)).

---

## ISSUE-003 — `Appointment` model out of sync with DB 🔴 BLOCKS FAMILY BOOKING

**Where:** [packages/core/lib/src/models/appointment.dart](../packages/core/lib/src/models/appointment.dart)

**Problem:** Migration `20260418000002` added `booked_by_patient_id` and `booked_for_member_id` to `appointments`. The `BookAppointmentScreen` already has a "For whom?" step. The model is missing the fields, so the family-member selection has nowhere to land.

**Fix plan:**
1. Add to `Appointment`:
   ```dart
   @JsonKey(name: 'booked_by_patient_id') String? bookedByPatientId,
   @JsonKey(name: 'booked_for_member_id') String? bookedForMemberId,
   ```
2. Regenerate Freezed/JSON.
3. Update the booking screen's submission to populate `bookedByPatientId` (= current patient) and `bookedForMemberId` (= selected family member or null).
4. In the doctor app appointments list, render "Booked for [member name]" when `bookedForMemberId` is set (will need a join via `family_members`).

---

## ISSUE-004 — `access_grants.status` enum mismatch 🟡

**Where:** [supabase/migrations/00005_create_access_grants.sql](../supabase/migrations/00005_create_access_grants.sql)

**Problem:** The migration's status enum is `active / revoked / expired`. The spec ([CLAUDE.md](../CLAUDE.md)) describes the values `pending / approved / rejected`. The "doctor requests access by Health ID; patient approves" flow needs `pending` to exist.

**Fix plan:**

Decide which is canonical. Two options:
1. **Keep `active/revoked/expired` and add `pending`.** This requires a migration:
   ```sql
   ALTER TYPE access_grant_status ADD VALUE 'pending';
   ```
   Update spec wording in CLAUDE.md to drop `approved`/`rejected` (use `active` for approved, `revoked` for rejected).
2. **Switch to `pending/approved/rejected`** as spec says. Migration that creates a new enum, migrates rows, drops the old. More disruptive.

**Recommendation:** Option 1. Less migration risk. Then update the patient approve/reject UI to flip `pending → active` (approve) or `pending → revoked` (reject).

---

## ISSUE-005 — Hardcoded Supabase credentials in every `main.dart` 🟡

**Where:** [apps/patient_app/lib/main.dart](../apps/patient_app/lib/main.dart) and the same in `doctor_app`, `hospital_portal`, `lab_portal`.

**Problem:** Production Supabase URL and anon key are pasted into source. The anon key is "low-risk" but it should still come from build configuration. RLS is the only thing protecting the DB; anyone who can read the binary can read those keys.

**Fix plan:**
1. Add `flutter_dotenv` or use `--dart-define` at build time.
2. Move credentials to `.env` (already gitignored — `.env.example` exists).
3. Bootstrap each `main.dart`:
   ```dart
   await dotenv.load(fileName: '.env');
   await Supabase.initialize(
     url: dotenv.env['SUPABASE_URL']!,
     anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
   );
   ```
4. Audit `.env.example` to confirm it documents every required variable (Google OAuth client IDs, FCM keys, etc).

---

## ISSUE-006 — FCM push delivery is a stub 🟡

**Where:** [supabase/functions/notifications/index.ts](../supabase/functions/notifications/index.ts) line 55 — `// TODO: Integrate with a real push notification service`.

**Problem:** Notifications inserted into the `notifications` table are not delivered as push notifications. FCM tokens are stored (since migration 20260418000001) but nothing reads them.

**Fix plan:**
1. In the edge function, on insert to `notifications`:
   - Look up the recipient's FCM tokens from `fcm_tokens`.
   - Use the **FCM HTTP v1 API** (not legacy) — requires a Google service account JSON in the function's secrets.
   - POST the message to `https://fcm.googleapis.com/v1/projects/{project_id}/messages:send` for each token.
   - On 404/`UNREGISTERED` response, delete the dead token from `fcm_tokens`.
2. Trigger the function from a `BEFORE INSERT` trigger or from the Supabase realtime → external function bridge.
3. In each app, on app start: register for FCM, write the token to `fcm_tokens` (upsert by `(user_id, token)`), and refresh on token rotation.
4. Wire foreground/background message handlers in each app to update local state and navigate to the relevant screen.

---

## ISSUE-007 — OAuth deep links wired to old Supabase scheme 🟡

**Where:** Android intent filters reference `io.supabase.healthos://login-callback`, but the current `signInWithGoogle` uses Firebase `google_sign_in` which doesn't use that scheme. iOS has no deep link configured.

**Fix plan:** Resolved as a side-effect of fixing **ISSUE-001 path A** (return to Supabase OAuth). If keeping Firebase, configure Firebase's own redirect URI scheme for iOS and remove the dead Supabase intent filter on Android.

---

## ISSUE-008 — Doctor app has a "create appointment" screen that contradicts the spec 🟡

**Where:** [apps/doctor_app/lib/src/features/appointments/screens/create_appointment_screen.dart](../apps/doctor_app/lib/src/features/appointments/screens/create_appointment_screen.dart)

**Problem:** Spec says: "Doctor cannot create appointments (patient books them)." A doctor-side create flow exists. Either the spec is out of date or this screen should be deleted.

**Fix plan:** Confirm with product. If the spec is canonical, delete the screen and its route. If doctors *should* be able to schedule on a patient's behalf, update the spec and add an `appointment.created_by` audit column.

---

## ISSUE-009 — Patient model field handling could NPE on home screen 🟢 LOW

**Where:** [apps/patient_app/lib/src/features/home/screens/home_screen.dart](../apps/patient_app/lib/src/features/home/screens/home_screen.dart) — early lines split `fullName` on space without null-coalescing.

**Fix plan:** Defensive null check / fallback to "there" or empty string. Trivial.

---

## ISSUE-010 — Generic `throw Exception(...)` everywhere 🟢 LOW

**Problem:** `throw Exception('Not authenticated')` and similar litter screen code. Hard to handle programmatically; loses type info.

**Fix plan:** Add a small set of typed exceptions in `packages/core/lib/src/exceptions/` (`AuthException`, `ProfileMissingException`, `RepositoryException`) and migrate. Don't do this in isolation — bundle with whatever feature work touches the same files.

---

## How to keep this list clean

1. When you fix something here, **delete the entry** (don't strike it through, don't add "FIXED").
2. Add a one-line note to [CHANGELOG.md](CHANGELOG.md) referencing the issue ID and the commit / PR.
3. When you discover a new bug worth tracking, add it here with a fresh `ISSUE-NNN` ID (continue numbering from the highest).
4. P0/P1 features that are missing → [02-pending-features.md](02-pending-features.md). P0/P1 things that **exist but are broken** → here.

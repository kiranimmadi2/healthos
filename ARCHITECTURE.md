# HealthOS — Master Architecture & Feature Specification

> **Living document.** Updated as features are planned and shipped.  
> Last updated: 2026-04-18

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Tech Stack & Monorepo Structure](#2-tech-stack--monorepo-structure)
3. [Authentication Architecture — Google Sign-In Fix](#3-authentication-architecture--google-sign-in-fix)
4. [Database Schema — Current + Changes](#4-database-schema--current--changes)
5. [Family Member Management — Patient App](#5-family-member-management--patient-app)
6. [Doctor Patient Management — End-to-End](#6-doctor-patient-management--end-to-end)
7. [API / Edge Function Layer](#7-api--edge-function-layer)
8. [State Management (Riverpod) Architecture](#8-state-management-riverpod-architecture)
9. [UI/UX Specification — Patient App](#9-uiux-specification--patient-app)
10. [UI/UX Specification — Doctor App](#10-uiux-specification--doctor-app)
11. [UI/UX Specification — Hospital Portal](#11-uiux-specification--hospital-portal)
12. [Design System Reference](#12-design-system-reference)
13. [Data Flow Diagrams](#13-data-flow-diagrams)
14. [Implementation Roadmap](#14-implementation-roadmap)

---

## 1. System Overview

HealthOS is an AI-powered unified health platform with four Flutter apps sharing a Supabase (PostgreSQL + Auth + Storage + Realtime) backend and Deno Edge Function microservices.

```
┌──────────────────────────────────────────────────────────────────┐
│                        CLIENT APPS                               │
│  patient_app    doctor_app    hospital_portal    lab_portal       │
│  (mobile/web)  (tablet/web)     (web)             (web)          │
└───────────────────────┬──────────────────────────────────────────┘
                        │ HTTPS / WebSocket
┌───────────────────────▼──────────────────────────────────────────┐
│                     SUPABASE PLATFORM                            │
│  ┌──────────┐  ┌────────────┐  ┌─────────┐  ┌───────────────┐  │
│  │ Auth     │  │ PostgreSQL │  │ Storage │  │  Realtime     │  │
│  │ (GoTrue) │  │ + RLS      │  │ Buckets │  │  (WebSocket)  │  │
│  └──────────┘  └────────────┘  └─────────┘  └───────────────┘  │
│                                                                  │
│  EDGE FUNCTIONS (Deno)                                           │
│  ai-service  |  appointment-service  |  clinical-service         │
│  notification-service  |  (future: family-service)              │
└──────────────────────────────────────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────────────┐
│  SHARED PACKAGES (Dart)                                          │
│  packages/core   |  packages/ui_kit                             │
│  packages/supabase_client  |  packages/ai_client                │
└──────────────────────────────────────────────────────────────────┘
```

### User Roles

| Role | App | Auth Method | Profile Source |
|------|-----|-------------|----------------|
| Patient | patient_app | Phone OTP / Email OTP / Google | `patients` table, self-created on first login |
| Doctor | doctor_app | Phone OTP / Google | `doctors` table, pre-seeded by admin |
| Hospital Admin | hospital_portal | Email+Password / Google | `hospitals` table via email match |
| Lab Technician | lab_portal | Email+Password / Google | `hospitals` table (staff) |

---

## 2. Tech Stack & Monorepo Structure

```
healthos/
├── apps/
│   ├── patient_app/          Flutter 3.8+ (iOS, Android, Web)
│   ├── doctor_app/           Flutter 3.8+ (Tablet-first, Web)
│   ├── hospital_portal/      Flutter Web
│   └── lab_portal/           Flutter Web
├── packages/
│   ├── core/                 Models (Freezed), Enums, Utilities
│   ├── ui_kit/               Design system, Widgets, Theme
│   ├── supabase_client/      Repositories, AuthService, ClientInitializer
│   └── ai_client/            HTTP client for Edge Functions
├── supabase/
│   ├── migrations/           SQL migration files (ordered)
│   ├── functions/            Deno TypeScript Edge Functions
│   │   ├── _shared/          Router, Middleware, Supabase client, Gemini client
│   │   ├── ai-service/
│   │   ├── appointment-service/
│   │   ├── clinical-service/
│   │   └── notification-service/
│   └── config.toml           Supabase local dev config
└── ARCHITECTURE.md           ← this file
```

**Core dependencies:**
- `flutter_riverpod ^2.5` — state management
- `go_router ^14` — navigation
- `supabase_flutter ^2.3` — auth + database client
- `freezed` / `json_serializable` — immutable models
- `google_sign_in ^6` — native Google OAuth on mobile *(to be added)*

---

## 3. Authentication Architecture — Google Sign-In Fix

### 3.1 What's Currently Broken

| Problem | Location | Impact |
|---------|----------|--------|
| `.env` has placeholder `GOOGLE_CLIENT_ID` | `.env` lines 6-7 | Google OAuth returns 401 |
| Mobile deep link not in Supabase redirect allow-list | `supabase/config.toml` line 156 | Redirect blocked after OAuth |
| Patient router sends Google-authed users to `/home` without checking if profile exists | `apps/patient_app/lib/src/routing/app_router.dart` line 46 | New Google users crash — no patient record |
| Doctor/Hospital/Lab router doesn't validate profile after Google auth | All other routers | Authenticated but missing profile = broken app state |
| Android has no intent filter for `io.supabase.healthos` deep link | AndroidManifest.xml | App doesn't open after Google OAuth on Android |

### 3.2 Google OAuth Data Flow (Fixed)

```
[Patient taps "Sign in with Google"]
        │
        ▼
signInWithOAuth(OAuthProvider.google,
  redirectTo: kIsWeb ? Uri.base.origin + '/auth/callback'
                     : 'io.supabase.healthos://login-callback')
        │
        ▼
[System browser opens]
  google.com/oauth2 consent screen
        │
        ▼
[User approves]
        │
        ▼
[Google → POST to Supabase GoTrue callback]
  Supabase creates/upserts auth.users row
  Sets user.email, user.app_metadata.provider = "google"
        │
        ▼
[Supabase redirects to app]
  Mobile: io.supabase.healthos://login-callback#access_token=...
  Web:    http://localhost:3000/auth/callback#access_token=...
        │
        ▼
[supabase_flutter handles deep link / web hash fragment]
  Updates session, persists to secure storage
        │
        ▼
[authStateProvider StreamProvider emits User]
        │
        ▼
[GoRouter redirect fires — reads authStateProvider + patientProfileStateProvider]
        │
        ├── No patient profile found? ──→ /auth/setup
        │
        └── Profile exists? ──────────→ /home
```

### 3.3 Required Changes

#### `supabase/config.toml`
```toml
[auth]
site_url = "http://127.0.0.1:3000"
additional_redirect_urls = [
  "https://127.0.0.1:3000",
  "io.supabase.healthos://login-callback",
  "com.healthos.doctorapp://login-callback",
  "http://localhost:3000/auth/callback"
]
```

#### `.env` (real values must be filled — never commit)
```
GOOGLE_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=<client-secret>
```

#### `apps/patient_app/android/app/src/main/AndroidManifest.xml`
Add inside `<application>`:
```xml
<activity android:name="com.linusu.flutter_web_auth_2.CallbackActivity"
          android:exported="true">
  <intent-filter android:label="flutter_web_auth_2">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.supabase.healthos" android:host="login-callback" />
  </intent-filter>
</activity>
```

#### `apps/patient_app/lib/src/routing/app_router.dart` — Router Fix

Add a new provider that combines auth + patient profile state:

```dart
/// Tri-state: loading | no-profile | has-profile
enum PatientProfileState { loading, missing, exists }

final patientProfileStateProvider = Provider<PatientProfileState>((ref) {
  final auth = ref.watch(authStateProvider);
  if (auth.isLoading) return PatientProfileState.loading;
  if (auth.valueOrNull == null) return PatientProfileState.missing;
  
  final patient = ref.watch(currentPatientProvider);
  if (patient.isLoading) return PatientProfileState.loading;
  if (patient.valueOrNull == null) return PatientProfileState.missing;
  return PatientProfileState.exists;
});
```

Update redirect logic:
```dart
redirect: (context, state) {
  final authState = ref.read(authStateProvider);
  final isAuthenticated = authState.valueOrNull != null;
  final isAuthRoute = state.matchedLocation.startsWith('/auth');

  if (!isAuthenticated && !isAuthRoute) return '/auth';

  if (isAuthenticated) {
    final profileState = ref.read(patientProfileStateProvider);
    if (profileState == PatientProfileState.loading) return null; // wait
    if (profileState == PatientProfileState.missing) return '/auth/setup';
    if (isAuthRoute) return '/home'; // profile exists, leave auth
  }
  return null;
},
```

Also add `patientProfileStateProvider` to `refreshListenable` so the router re-evaluates when the profile loads.

#### Doctor App Router Fix

After Google login, if `currentDoctorProvider` returns null, show a dedicated "Account Not Found" screen explaining that doctor accounts must be created by hospital admins, with a "Contact Support" button and sign-out option.

```dart
// doctor app router redirect
if (isAuthenticated && !isAuthRoute) {
  final doctor = ref.read(currentDoctorProvider);
  if (doctor.isLoading) return null;
  if (doctor.valueOrNull == null) return '/auth/not-found';
}
```

### 3.4 Profile Setup Screen — Google Auth Compatibility

`ProfileSetupScreen` already handles profile creation correctly. The only change needed is pre-filling `fullName` from `currentUser?.userMetadata?['full_name']` and `avatarUrl` from `currentUser?.userMetadata?['avatar_url']` when the user signed in via Google.

```dart
// In ProfileSetupScreen initState:
final user = SupabaseClientInitializer.client.auth.currentUser;
final googleName = user?.userMetadata?['full_name'] as String?;
final googleAvatar = user?.userMetadata?['avatar_url'] as String?;
if (googleName != null) _nameController.text = googleName;
// Store googleAvatar to use in profile creation call
```

---

## 4. Database Schema — Current + Changes

### 4.1 Current Tables (Summary)

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `patients` | Patient profiles | `auth_id`, `health_id`, `phone`, `allergies[]`, `chronic_conditions[]`, `fcm_token` |
| `doctors` | Doctor profiles | `auth_id`, `hospital_id`, `specialization`, `verified`, `fcm_token` |
| `hospitals` | Hospital organizations | `name`, `email`, `license` |
| `access_grants` | Doctor-patient access control | `patient_id`, `doctor_id`, `status`, `access_level` |
| `visits` | Clinical encounters | `patient_id`, `doctor_id`, `chief_complaint`, `diagnosis`, `notes` |
| `lab_reports` | Lab report metadata | `patient_id`, `report_type`, `status`, `file_url` |
| `biomarkers` | Individual test values | `patient_id`, `report_id`, `name`, `value`, `normal_min`, `normal_max` |
| `prescriptions` | Medications prescribed | `patient_id`, `doctor_id`, `medications` (JSONB array) |
| `appointments` | Scheduled visits | `patient_id`, `doctor_id`, `scheduled_at`, `status` |
| `symptom_sessions` | AI triage history | `patient_id`, `symptoms_input`, `ai_response`, `triage_level` |
| `notifications` | In-app + push | `patient_id`, `doctor_id`, `title`, `body`, `read_at` |
| `patient_embeddings` | RAG vector store | `patient_id`, `embedding` (vector 1536), `source_type` |

### 4.2 New Tables Required

#### `family_members` (new)
```sql
CREATE TABLE family_members (
  id                        UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  primary_patient_id        UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  member_patient_id         UUID REFERENCES patients(id) ON DELETE SET NULL,
  -- member_patient_id is NULL until/unless member joins HealthOS

  relationship              TEXT NOT NULL CHECK (relationship IN (
                              'spouse', 'child', 'parent', 'sibling', 'guardian', 'other'
                            )),
  full_name                 TEXT NOT NULL,
  date_of_birth             DATE,
  gender                    TEXT CHECK (gender IN ('male', 'female', 'other')),
  phone                     TEXT,

  -- Permissions granted by primary patient
  is_dependent              BOOLEAN DEFAULT false,
  can_view_records          BOOLEAN DEFAULT false,
  can_manage_appointments   BOOLEAN DEFAULT false,

  -- Linking status
  invite_status             TEXT DEFAULT 'not_invited' CHECK (invite_status IN (
                              'not_invited', 'invited', 'linked'
                            )),
  invited_at                TIMESTAMPTZ,
  linked_at                 TIMESTAMPTZ,

  created_at                TIMESTAMPTZ DEFAULT NOW(),
  updated_at                TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_family_members_primary  ON family_members (primary_patient_id);
CREATE INDEX idx_family_members_member   ON family_members (member_patient_id);
CREATE INDEX idx_family_members_phone    ON family_members (phone);
```

#### `visit_vitals` (new — separate from freeform notes)
```sql
CREATE TABLE visit_vitals (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  visit_id        UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
  patient_id      UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  bp_systolic     INT,
  bp_diastolic    INT,
  heart_rate      INT,
  temperature_c   NUMERIC(4,1),
  weight_kg       NUMERIC(5,1),
  height_cm       NUMERIC(5,1),
  spo2_percent    NUMERIC(4,1),
  recorded_at     TIMESTAMPTZ DEFAULT NOW(),
  recorded_by     UUID REFERENCES doctors(id)
);

CREATE INDEX idx_visit_vitals_visit    ON visit_vitals (visit_id);
CREATE INDEX idx_visit_vitals_patient  ON visit_vitals (patient_id);
```

#### `doctor_notes` (new — freeform notes outside visits)
```sql
CREATE TABLE doctor_notes (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id    UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id     UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
  content       TEXT NOT NULL,
  is_private    BOOLEAN DEFAULT true, -- doctor-only vs shared with patient
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_doctor_notes_patient  ON doctor_notes (patient_id);
CREATE INDEX idx_doctor_notes_doctor   ON doctor_notes (doctor_id);
```

### 4.3 Altered Tables

```sql
-- Appointments: track who booked (self vs family manager)
ALTER TABLE appointments
  ADD COLUMN booked_by_patient_id UUID REFERENCES patients(id),
  ADD COLUMN booked_for_member_id UUID REFERENCES family_members(id);

-- Visits: add follow-up date + ICD code
ALTER TABLE visits
  ADD COLUMN follow_up_date    DATE,
  ADD COLUMN icd_code          TEXT,
  ADD COLUMN visit_type        TEXT DEFAULT 'consultation'
    CHECK (visit_type IN ('consultation', 'follow_up', 'emergency', 'procedure'));
```

### 4.4 New RLS Policies

```sql
-- family_members: primary patient manages own family
CREATE POLICY "patient manages own family"
  ON family_members FOR ALL
  USING (primary_patient_id = get_patient_id_for_user(auth.uid()))
  WITH CHECK (primary_patient_id = get_patient_id_for_user(auth.uid()));

-- family_members: linked member can read their own entry
CREATE POLICY "member can read own entry"
  ON family_members FOR SELECT
  USING (member_patient_id = get_patient_id_for_user(auth.uid()));

-- visit_vitals: doctor write, patient read via access grant
CREATE POLICY "doctor writes vitals"
  ON visit_vitals FOR INSERT
  WITH CHECK (recorded_by = get_doctor_id_for_user(auth.uid()));

CREATE POLICY "patient reads own vitals"
  ON visit_vitals FOR SELECT
  USING (patient_id = get_patient_id_for_user(auth.uid()));

CREATE POLICY "doctor reads vitals with access"
  ON visit_vitals FOR SELECT
  USING (doctor_has_access_to_patient(get_doctor_id_for_user(auth.uid()), patient_id));

-- doctor_notes: doctor owns, patient sees non-private
CREATE POLICY "doctor manages own notes"
  ON doctor_notes FOR ALL
  USING (doctor_id = get_doctor_id_for_user(auth.uid()))
  WITH CHECK (doctor_id = get_doctor_id_for_user(auth.uid()));

CREATE POLICY "patient reads non-private notes"
  ON doctor_notes FOR SELECT
  USING (patient_id = get_patient_id_for_user(auth.uid()) AND is_private = false);
```

---

## 5. Family Member Management — Patient App

### 5.1 Feature Overview

A patient can:
- Add family members (spouse, parent, child, sibling, guardian, other)
- Manage dependents (children, elderly parents) on their behalf without an invite
- Invite connected adults (with phones) to link their HealthOS account
- Grant per-member permissions: view records, manage appointments
- Book appointments on behalf of family members
- View a merged family health overview

### 5.2 New Screens & Routes

```
/profile/family                    FamilyHubScreen
/profile/family/add                AddFamilyMemberScreen (multi-step)
/profile/family/:memberId          FamilyMemberDetailScreen
/profile/family/:memberId/edit     EditFamilyMemberScreen
/appointments/book                 BookAppointmentScreen (enhanced — "for whom?" step)
```

### 5.3 New Dart Models

#### `FamilyMember` (packages/core)
```dart
@freezed
class FamilyMember with _$FamilyMember {
  const factory FamilyMember({
    required String id,
    required String primaryPatientId,
    String? memberPatientId,
    required String relationship,
    required String fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? phone,
    @Default(false) bool isDependent,
    @Default(false) bool canViewRecords,
    @Default(false) bool canManageAppointments,
    @Default('not_invited') String inviteStatus,
    DateTime? invitedAt,
    DateTime? linkedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FamilyMember;

  factory FamilyMember.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberFromJson(json);
}
```

### 5.4 New Repository: `FamilyMemberRepository` (packages/supabase_client)
```dart
class FamilyMemberRepository {
  Future<List<FamilyMember>> getByPrimaryPatient(String patientId);
  Future<FamilyMember> create(Map<String, dynamic> data);
  Future<FamilyMember> update(String memberId, Map<String, dynamic> data);
  Future<void> delete(String memberId);
  Future<void> linkToPatient(String memberId, String linkedPatientId);
  Future<FamilyMember?> findByPhone(String primaryPatientId, String phone);
}
```

### 5.5 New Riverpod Providers (patient_app)
```dart
final familyMembersProvider = FutureProvider<List<FamilyMember>>((ref) async {
  final patient = await ref.watch(currentPatientProvider.future);
  if (patient == null) return [];
  return ref.read(familyMemberRepoProvider).getByPrimaryPatient(patient.id);
});

final selectedBookingMemberProvider = StateProvider<FamilyMember?>((ref) => null);
// null means "booking for self"
```

---

## 6. Doctor Patient Management — End-to-End

### 6.1 Complete Doctor Workflow (Enhanced)

```
[Doctor Login via Phone OTP or Google]
        │
        ▼
[Dashboard: Patient List]
  ← patients who granted access via access_grants
  ← search by name / health_id
  ← "No patients yet" empty state with QR scan hint
        │
        ▼
[PatientDetailScreen — ENHANCED]
        │
        ├── Header Card: demographics + quick edit (allergies, conditions)
        ├── Upcoming appointment badge
        ├── Speed Dial FAB:
        │     ├── 📋 New Visit
        │     ├── 💊 New Prescription
        │     ├── 🔬 Add Lab Result
        │     └── 📝 Quick Note
        ├── Timeline tabs: Visits | Labs | Prescriptions | Notes
        └── AI Summary button
```

### 6.2 Enhanced Visit Creation

**Screen: `CreateVisitScreen` (doctor_app)**

```
─────────────────────────────────────
  New Visit   [patient name]
─────────────────────────────────────

  Visit Type: [Consultation ▾]

  Chief Complaint *
  ┌──────────────────────────────┐
  │ Describe the main complaint  │
  └──────────────────────────────┘

  ▶ Vital Signs  (tap to expand)
  ┌──────────────────────────────┐
  │ BP:  [___] / [___]  mmHg    │
  │ HR:  [___]  bpm             │
  │ Temp:[___]  °C              │
  │ Wt:  [___]  kg              │
  │ Ht:  [___]  cm              │
  │ SpO2:[___]  %               │
  └──────────────────────────────┘

  Examination Findings
  ┌──────────────────────────────┐
  │ (multiline text)             │
  └──────────────────────────────┘

  Diagnosis / Assessment
  ┌──────────────────────────────┐
  │                              │
  └──────────────────────────────┘

  ICD-10 Code (optional)
  [_______________]

  Plan
  ┌──────────────────────────────┐
  │ (multiline text)             │
  └──────────────────────────────┘

  Follow-up Date   [Pick date ▾]

  Triage Level   [See Doctor ▾]

  ─────────────────────────────────
  [    Cancel    ]  [  Save Visit ]
```

**Data model stored:**
- `visits` row: `chief_complaint`, `diagnosis`, `notes` (examination+plan combined), `visit_type`, `follow_up_date`, `icd_code`
- `visit_vitals` row: all measured values if any were entered

### 6.3 Manual Lab Result Entry

**Screen: `AddLabResultScreen` (doctor_app)**

```
─────────────────────────────────────
  Add Test Results   [patient name]
─────────────────────────────────────

  Test Date   [Today ▾]
  Lab Name    [_____________]

  ── Test Results ───────────────────

  ┌──────────────────────────────────┐
  │  Test Name  [Hemoglobin      ▾]  │
  │  Value      [12.5]               │
  │  Unit       [g/dL            ▾]  │
  │  Ref Range  [12.0] – [16.0]      │
  └──────────────────────────────────┘

  [+ Add Another Test]

  Notes (optional)
  ┌──────────────────────────────────┐
  │                                  │
  └──────────────────────────────────┘

  ──────────────────────────────────
  [ Cancel ]          [ Save Results ]
```

**Data flow:**
1. Creates `lab_reports` row (type = entered test, status = 'ready', doctor_id = current doctor)
2. Creates `biomarkers` rows for each test value entered
3. Triggers notification to patient: "Dr. [name] added your test results"

### 6.4 Doctor Quick Notes

**Screen: `QuickNoteScreen` (doctor_app) — modal bottom sheet**

```
─────────────────────────────────────
  Clinical Note — [patient name]
─────────────────────────────────────

  ┌──────────────────────────────────┐
  │                                  │
  │  Type your note here...          │
  │                                  │
  │                                  │
  └──────────────────────────────────┘

  Visibility
  ◉ Private (only you can see this)
  ○ Shared with patient

  ──────────────────────────────────
  [ Cancel ]          [ Save Note ]
```

### 6.5 Patient Demographics Edit by Doctor

Doctor can edit `allergies` and `chronic_conditions` directly (clinical authority). They cannot edit personal demographics (name, DOB) — those belong to the patient.

**UI: `EditPatientMedicalHistorySheet` — bottom sheet modal**

```
─────────────────────────────────────
  Medical History — [patient name]
─────────────────────────────────────

  Allergies
  [penicillin ×] [pollen ×]  [+ Add]

  Chronic Conditions
  [diabetes ×] [hypertension ×]  [+ Add]

  Emergency Contact
  Name:         [_____________]
  Relationship: [_____________]
  Phone:        [_____________]

  ──────────────────────────────────
  [ Cancel ]           [ Save Changes ]
```

**RLS note:** Doctor can `UPDATE patients` on `allergies`, `chronic_conditions`, `emergency_contact` fields only if `doctor_has_access_to_patient` returns true. A targeted update policy or function-level check (in edge function) handles this.

---

## 7. API / Edge Function Layer

### 7.1 New Routes Required

#### `clinical-service` additions
```
POST /vitals              → create visit_vitals record
GET  /vitals/visit/:id   → vitals for a visit
GET  /vitals/patient/:id → vitals history for patient

POST /notes              → create doctor_note
GET  /notes/patient/:id → notes for patient (doctor sees all, patient sees non-private)
PUT  /notes/:id         → update note
DELETE /notes/:id       → delete note

PATCH /patients/:id/medical-history  → update allergies, conditions, emergency_contact only
                                       (requires active access_grant validation)
```

#### New `family-service` Edge Function
```
GET  /family/:primaryPatientId           → list family members
POST /family                             → create family member record
PUT  /family/:memberId                   → update member (name, permissions)
DELETE /family/:memberId                 → remove member
PUT  /family/:memberId/link              → link member to HealthOS patient ID
POST /family/:memberId/invite            → trigger SMS invite via notification-service
```

### 7.2 appointment-service additions
```
GET  /appointments/family/:memberId   → appointments for a family member
POST /appointments                    → already exists; add booked_for_member_id support
```

---

## 8. State Management (Riverpod) Architecture

### 8.1 Provider Dependency Graph

```
authStateProvider (StreamProvider<User?>)
        │
        ├──→ currentUserIdProvider (Provider<String?>)
        │           │
        │           ├──→ currentPatientProvider (FutureProvider<Patient?>)
        │           │           │
        │           │           ├──→ familyMembersProvider
        │           │           ├──→ upcomingAppointmentsProvider
        │           │           ├──→ patientReportsProvider
        │           │           └──→ patientNotificationsProvider
        │           │
        │           └──→ currentDoctorProvider (FutureProvider<Doctor?>)
        │                       │
        │                       ├──→ grantedPatientsProvider
        │                       ├──→ doctorAppointmentsProvider
        │                       └──→ doctorNotificationsProvider
        │
        └──→ patientProfileStateProvider (Provider<PatientProfileState>)
                    │ (drives router redirect)
```

### 8.2 Key Provider Patterns

**Invalidation on mutation:**
```dart
// After creating a family member:
ref.invalidate(familyMembersProvider);

// After booking appointment for family member:
ref.invalidate(upcomingAppointmentsProvider);
ref.invalidate(familyMembersProvider); // to refresh member appointment count

// After doctor saves visit:
ref.invalidate(patientVisitsProvider(patientId));
ref.invalidate(patientByIdProvider(patientId)); // refresh allergies if changed
```

**Parameterized providers:**
```dart
final patientByIdProvider = FutureProvider.family<Patient?, String>((ref, patientId) async {
  return ref.read(patientRepositoryProvider).getById(patientId);
});

final familyMemberByIdProvider = FutureProvider.family<FamilyMember?, String>((ref, memberId) async {
  return ref.read(familyMemberRepoProvider).getById(memberId);
});
```

---

## 9. UI/UX Specification — Patient App

### 9.1 Navigation Structure (Enhanced)

```
Bottom Nav Bar (4 tabs):
  🏠 Home    📋 Records    🤖 Symptoms    👤 Profile

Profile tab expands to:
  /profile          ProfileScreen
  /profile/edit     ProfileEditScreen
  /profile/family   FamilyHubScreen  ← NEW
  /profile/family/add           ← NEW
  /profile/family/:id           ← NEW
  /profile/family/:id/edit      ← NEW
```

### 9.2 Home Screen — Health Overview Card

Add a "Family Health" quick card below the Health ID card:
```
┌──────────────────────────────────────────┐
│ 👨‍👩‍👧  Family Health                         │
│ Priya (spouse) · Appointment tomorrow    │
│ Arjun (child) · Vaccination overdue ⚠️  │
│                          View All →      │
└──────────────────────────────────────────┘
```

### 9.3 Profile Screen — Family Section

Add after existing profile fields:
```
  ─────── Family & Dependents ────────
  ┌──────────────────────────────────────┐
  │ 👤  Priya                    Spouse  │
  │     Linked · HealthID: HP-XXX-XXX   │
  │                                  >  │
  ├──────────────────────────────────────┤
  │ 👶  Arjun                     Child  │
  │     Dependent · Age 7               │
  │                                  >  │
  └──────────────────────────────────────┘
  [+ Add Family Member]
```

### 9.4 Add Family Member — Multi-Step Flow

**Step 1: Who are you adding?**
```
  ┌──────────────────────────────────────┐
  │  Who are you adding?                 │
  │                                      │
  │  ┌──────────┐  ┌──────────┐          │
  │  │  👫      │  │  👨      │          │
  │  │ Spouse   │  │ Parent   │          │
  │  └──────────┘  └──────────┘          │
  │  ┌──────────┐  ┌──────────┐          │
  │  │  👶      │  │  👧      │          │
  │  │ Child    │  │ Sibling  │          │
  │  └──────────┘  └──────────┘          │
  │  ┌──────────┐  ┌──────────┐          │
  │  │  🛡      │  │  👤      │          │
  │  │ Guardian │  │ Other    │          │
  │  └──────────┘  └──────────┘          │
  └──────────────────────────────────────┘
  Progress: ●○○
```

**Step 2: Their Details**
```
  ┌──────────────────────────────────────┐
  │  Tell us about them                  │
  │                                      │
  │  Full Name *                         │
  │  [                               ]   │
  │                                      │
  │  Date of Birth                       │
  │  [  Select date  ▾]                  │
  │                                      │
  │  Gender                              │
  │  [ Male ] [ Female ] [ Other ]       │
  │                                      │
  │  Phone (optional, for invite)        │
  │  [                               ]   │
  └──────────────────────────────────────┘
  Progress: ●●○
```

**Step 3: Permissions**
```
  ┌──────────────────────────────────────┐
  │  Set Permissions                     │
  │                                      │
  │  ◉ I'll manage their health          │
  │    Book appointments & view records  │
  │                                      │
  │  ○ Can view my health records        │
  │    They'll see your reports &        │
  │    appointments                      │
  │                                      │
  │  ╔══════════════════════════════╗    │
  │  ║ 📱 Send invite to +91-XXXXX  ║    │
  │  ║    (if phone was provided)   ║    │
  │  ╚══════════════════════════════╝    │
  └──────────────────────────────────────┘
  Progress: ●●●

  [ Back ]              [ Add Member ✓ ]
```

### 9.5 Book Appointment — "For Whom?" Step

Inserted as the first step before doctor selection:
```
  ┌──────────────────────────────────────┐
  │  Who needs the appointment?          │
  │                                      │
  │  ┌──────────────────────────────┐    │
  │  │  ◉  For Me                   │    │
  │  │     Ravi Kumar · HP-001-ABC  │    │
  │  └──────────────────────────────┘    │
  │                                      │
  │  ┌──────────────────────────────┐    │
  │  │  ○  Priya (Spouse)           │    │
  │  │     HP-002-DEF               │    │
  │  └──────────────────────────────┘    │
  │                                      │
  │  ┌──────────────────────────────┐    │
  │  │  ○  Arjun (Child, 7 yrs)     │    │
  │  │     Managed by you           │    │
  │  └──────────────────────────────┘    │
  │                                      │
  │  ──────────────────────────────────  │
  │                         [ Next → ]  │
  └──────────────────────────────────────┘
```

### 9.6 Family Member Detail Screen

```
AppBar: "Arjun · Child"  [edit icon]

┌──────────────────────────────────────────┐
│  👶  Arjun Kumar                         │
│  Age: 7  ·  Gender: Male  ·  B+          │
│  Managed by: Ravi (you)                  │
└──────────────────────────────────────────┘

[ 📅 Book Appointment ]  [ 📋 View Records ]

── Upcoming ──────────────────────────────
  No upcoming appointments
  [ Book First Appointment ]

── Recent Activity ───────────────────────
  (shown if linked / has records)
```

---

## 10. UI/UX Specification — Doctor App

### 10.1 Enhanced PatientDetailScreen

```
AppBar: "Patient Detail"  [🤖 AI Summary]

┌──────────────────────────────────────────┐
│  [Avatar]  Ravi Kumar                    │
│  HP-001-ABC  ·  Male  ·  32 yrs  ·  B+  │
│                                          │
│  🚨 Allergies: penicillin, pollen  [✏️]  │
│  📋 Conditions: diabetes             [✏️] │
│  📞 Emergency: Priya · +91-9999999        │
└──────────────────────────────────────────┘

Next appt: Tomorrow 10:00 AM — Routine Check

──────────────────────────────────────────
[ Visits ] [ Labs ] [ Prescriptions ] [ Notes ]
──────────────────────────────────────────

(timeline content per tab)

                              [+] Speed Dial FAB
                                  📋 New Visit
                                  💊 New Prescription
                                  🔬 Add Lab Result
                                  📝 Quick Note
```

### 10.2 Visit Timeline Card (Enhanced)

```
┌──────────────────────────────────────────┐
│  📋  Consultation  ·  Jan 15 2026        │
│  Chief Complaint: Persistent cough       │
│                                          │
│  Vitals: 120/80 · 88 bpm · 37.2°C        │
│                                          │
│  Diagnosis: Acute bronchitis             │
│  ICD-10: J20.9                           │
│                                          │
│  Follow-up: Jan 22 2026                  │
└──────────────────────────────────────────┘
```

### 10.3 Patient List Screen — Access Request

Currently doctors see only patients who granted access. Add a secondary action:
```
  ─── Patients ──────────────────────────────

  (list of granted patients)

  ──────────────────────────────────────────

  To view a new patient's records:
  Ask them to share their HealthOS QR code,
  or request access via their Health ID.

  [📱 Scan QR Code]  [🔑 Enter Health ID]
```

When doctor enters a patient Health ID:
- System creates an "access request" notification to the patient
- Patient approves/declines from their app
- Once approved, patient appears in doctor's list

### 10.4 AI Summary Screen (Enhanced)

```
AppBar: "Health Summary — Ravi Kumar"  [🔄 Refresh]

Generated: 5 minutes ago · Data: 47 records

┌──────────────────────────────────────────┐
│  📊 Overview                             │
│  Patient has managed Type 2 diabetes     │
│  for 3 years with mostly stable HbA1c.  │
│  Recent visit showed elevated BP...     │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│  🔍 Key Findings                         │
│  • HbA1c 7.2% (Jan 2026) — borderline   │
│  • BP consistently >140/90              │
│  • Hemoglobin trending down (trend chart)│
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│  ⚠️ Risk Factors                         │
│  • Uncontrolled hypertension             │
│  • Family history: cardiac disease       │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│  ✅ Recommendations                      │
│  • Review antihypertensive dosage        │
│  • Order cardiac workup                  │
│  • Schedule 2-week follow-up            │
└──────────────────────────────────────────┘

⚠️ AI-generated. Verify with clinical records.
```

---

## 11. UI/UX Specification — Hospital Portal

### 11.1 Dashboard Enhancements

Add quick metrics:
- Pending access requests (patients waiting for doctor approval)
- Doctors without verified status
- Upcoming appointments today

### 11.2 Doctor Onboarding Flow

When a new doctor signs in via Google and no profile exists, hospital admin can:
1. See them in "Pending Doctors" list
2. Link their Google auth_id to a pre-created doctor record
3. Or create the doctor record with their Google account

---

## 12. Design System Reference

### Colors
```dart
AppColors.primary       = #0066FF  // Interactive, CTAs, links
AppColors.secondary     = #00C48C  // Success, "healthy", positive values
AppColors.warning       = #FFAA00  // Borderline values, caution
AppColors.error         = #FF3B30  // Abnormal values, emergency triage
AppColors.surface       = #FFFFFF  // Card backgrounds
AppColors.background    = #F9FAFB  // Screen background
AppColors.textPrimary   = #1A1D26  // Main text
AppColors.textSecondary = #6B7280  // Supporting text
AppColors.textTertiary  = #9CA3AF  // Hints, placeholders
```

### Triage Color Mapping
```
emergency   → AppColors.error (#FF3B30)   — "Go to ER immediately"
see_doctor  → AppColors.warning (#FFAA00) — "Book appointment"
home_care   → AppColors.secondary (#00C48C)— "Rest and monitor"
```

### Relationship Icon Mapping (Family)
```
spouse   → Icons.favorite
parent   → Icons.person
child    → Icons.child_care
sibling  → Icons.people
guardian → Icons.shield
other    → Icons.person_outline
```

### Typography Scale
```
H1: Inter 32/700  — screen titles
H2: Inter 24/700  — section headings
H3: Inter 20/600  — card headings
H4: Inter 18/600  — sub-headings
bodyLarge:  Inter 16/400
bodyMedium: Inter 14/400  — most body text
caption:    Inter 12/500  — labels, metadata
button:     Inter 16/600  — CTA text
```

### Standard Spacing
```
AppSpacing.xs = 4    AppSpacing.sm  = 8
AppSpacing.md = 12   AppSpacing.lg  = 16
AppSpacing.xl = 24   AppSpacing.xxl = 32
```

---

## 13. Data Flow Diagrams

### 13.1 Google Sign-In End-to-End
```
Patient App                 Supabase              Google OAuth
     │                          │                      │
     │──signInWithOAuth()───────▶│                      │
     │                          │──auth_url redirect───▶│
     │◀─────────────────────────│                      │
     │ opens browser            │                      │
     │                          │◀──user consent───────│
     │                          │──verify token──────▶ │
     │                          │◀──id_token────────── │
     │                          │  upsert auth.users   │
     │◀──deep link callback─────│                      │
     │  supabase_flutter         │                      │
     │  updates session          │                      │
     │                          │                      │
     │──getByAuthId()───────────▶│                      │
     │◀──Patient | null──────────│                      │
     │                          │                      │
  if null → /auth/setup         │                      │
  if exists → /home             │                      │
```

### 13.2 Family Appointment Booking
```
Patient App                   Edge Functions           DB
     │                               │                 │
     │  selects family member        │                 │
     │  selects doctor + slot        │                 │
     │──POST /appointments──────────▶│                 │
     │  { patient_id,                │                 │
     │    doctor_id,                 │                 │
     │    scheduled_at,              │                 │
     │    booked_by_patient_id,      │                 │
     │    booked_for_member_id }     │                 │
     │                               │──INSERT─────────▶│
     │                               │                 │
     │                               │──notify patient▶│
     │                               │──notify doctor─▶│
     │◀──201 appointment────────────│                 │
```

### 13.3 Doctor Adds Visit + Vitals
```
Doctor App                    clinical-service          DB
     │                               │                 │
     │──POST /visits────────────────▶│                 │
     │  { patient_id, doctor_id,     │                 │
     │    chief_complaint, diagnosis,│──INSERT visits──▶│
     │    notes, visit_type,         │◀──visit.id───── │
     │    follow_up_date, icd_code } │                 │
     │◀──201 { visit.id }───────────│                 │
     │                               │                 │
     │──POST /vitals────────────────▶│                 │
     │  { visit_id, patient_id,      │──INSERT vitals──▶│
     │    bp_systolic, bp_diastolic, │                 │
     │    heart_rate, ... }          │                 │
     │◀──201 vitals─────────────────│                 │
     │                               │                 │
     │  invalidate patientVisitsProvider              │
```

---

## 14. Implementation Roadmap

### Phase 1 — Authentication Fix (Week 1) 🔴 CRITICAL
- [ ] Fill real values in `.env` (GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET)
- [ ] Update `supabase/config.toml` — add mobile deep link to redirect allow-list
- [ ] Fix patient app router — add `patientProfileStateProvider`, update redirect
- [ ] Fix all app routers — handle missing profile after Google auth
- [ ] Add Android intent filter for deep link in all apps
- [ ] Pre-fill Google profile data (name, avatar) in ProfileSetupScreen
- [ ] Add doctor "Account Not Found" screen for unregistered Google auth
- [ ] Manual QA: Google sign-in on Android, iOS, and Web for each app

**Files changed:**
- `supabase/config.toml`
- `.env`
- `apps/patient_app/android/app/src/main/AndroidManifest.xml`
- `apps/doctor_app/android/app/src/main/AndroidManifest.xml`
- `apps/hospital_portal/android/app/src/main/AndroidManifest.xml`
- `apps/lab_portal/android/app/src/main/AndroidManifest.xml`
- `apps/patient_app/lib/src/routing/app_router.dart`
- `apps/patient_app/lib/src/features/auth/screens/profile_setup_screen.dart`
- `apps/doctor_app/lib/src/routing/app_router.dart`
- `apps/hospital_portal/lib/src/routing/app_router.dart`
- `apps/lab_portal/lib/src/routing/app_router.dart`

### Phase 2 — Database Migrations (Week 1) 🔴 CRITICAL
- [ ] Migration: `family_members` table + RLS
- [ ] Migration: `visit_vitals` table + RLS
- [ ] Migration: `doctor_notes` table + RLS
- [ ] Migration: alter `appointments` (booked_by/for columns)
- [ ] Migration: alter `visits` (follow_up_date, icd_code, visit_type)
- [ ] Run `supabase db push` or apply to hosted instance

### Phase 3 — Core Models + Repositories (Week 1-2)
- [ ] Add `FamilyMember` Freezed model to `packages/core`
- [ ] Add `VisitVitals` Freezed model to `packages/core`
- [ ] Add `DoctorNote` Freezed model to `packages/core`
- [ ] Run `build_runner` in `packages/core`
- [ ] Add `FamilyMemberRepository` to `packages/supabase_client`
- [ ] Add `VisitVitalsRepository` to `packages/supabase_client`
- [ ] Add `DoctorNoteRepository` to `packages/supabase_client`
- [ ] Extend `AppointmentRepository` — support `booked_for_member_id`
- [ ] Extend `VisitRepository` — new columns

### Phase 4 — Edge Functions (Week 2)
- [ ] Add `/vitals` routes to `clinical-service`
- [ ] Add `/notes` routes to `clinical-service`
- [ ] Add `PATCH /patients/:id/medical-history` to `clinical-service`
- [ ] Create `family-service` Edge Function with full CRUD + link/invite routes
- [ ] Update `appointment-service` to store `booked_by/for` fields
- [ ] Deploy updated functions

### Phase 5 — Patient App: Family Hub (Week 2-3)
- [ ] `FamilyHubScreen` — list + empty state
- [ ] `AddFamilyMemberScreen` — 3-step multi-page form
- [ ] `FamilyMemberDetailScreen`
- [ ] `EditFamilyMemberScreen`
- [ ] Add family section to `ProfileScreen`
- [ ] Add family providers to patient app
- [ ] Update `BookAppointmentScreen` — "For whom?" first step
- [ ] Update `HomeScreen` — family health quick card
- [ ] Update router with new family routes

### Phase 6 — Doctor App: Enhanced Patient Management (Week 3)
- [ ] Enhance `CreateVisitScreen` — vitals section + icd code + follow-up
- [ ] `AddLabResultScreen` — manual biomarker entry
- [ ] `QuickNoteScreen` — bottom sheet doctor notes
- [ ] `EditPatientMedicalHistorySheet` — allergies/conditions edit
- [ ] `VitalSignsCard` widget — display vitals on visit timeline
- [ ] Update `PatientDetailScreen` — speed dial FAB + vitals display + notes tab
- [ ] Add vitals/notes providers to doctor app

### Phase 7 — Polish & Testing (Week 4)
- [ ] Accessibility audit (semantic labels on all interactive elements)
- [ ] Dark mode support (AppColors already defined)
- [ ] Offline state handling (Supabase realtime reconnection)
- [ ] Performance: paginate long lists (visits, reports)
- [ ] E2E test: Google sign-in → profile setup → home
- [ ] E2E test: add family member → book appointment for them
- [ ] E2E test: doctor creates visit with vitals → patient sees update

---

## Appendix: Environment Variables Required

```bash
# Supabase
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>  # edge functions only

# Google OAuth
GOOGLE_CLIENT_ID=<web-client-id>.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=<oauth-client-secret>

# AI
GEMINI_API_KEY=<google-ai-studio-key>

# Firebase (push notifications)
FIREBASE_SERVICE_ACCOUNT_JSON=<stringified-json>

# Google Cloud Console setup required:
# 1. Create OAuth 2.0 Web Client
# 2. Add authorized redirect URIs:
#    https://<project>.supabase.co/auth/v1/callback
# 3. Create OAuth 2.0 Android Client
#    Package: com.healthos.patient_app
#    SHA-1:   <from keystore>
# 4. Create OAuth 2.0 iOS Client
#    Bundle ID: com.healthos.patientApp
```

---

*This document is the single source of truth for HealthOS architecture. All implementation decisions should reference this document and update it when diverging.*

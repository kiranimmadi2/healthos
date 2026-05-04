# 05 — Database Schema

The current state of the Supabase database — every migration, every table, and where the Dart models drift from the SQL.

---

## Migration order

Listed in execution order. Each is a standalone file in [../supabase/migrations/](../supabase/migrations/).

| File | Purpose |
|---|---|
| `00001_enable_extensions.sql` | `pgcrypto`, `uuid-ossp` |
| `00002_create_hospitals.sql` | `hospitals` |
| `00003_create_patients.sql` | `patients` (with `health_id`, `allergies[]`, `chronic_conditions[]`, emergency contact) |
| `00004_create_doctors.sql` | `doctors` (`specialization`, `verified`, `license_number`, `avatar_url`) |
| `00005_create_access_grants.sql` | `access_grants` (status enum: `active/revoked/expired` — *spec wants `pending/approved/rejected`* — see [03-known-issues.md ISSUE-004](03-known-issues.md)) |
| `00006_create_visits.sql` | `visits` (chief_complaint, diagnosis, notes, visited_at) |
| `00007_create_lab_reports.sql` | `lab_reports` (report_type, status, file_url, parsed_data, ai_summary) |
| `00008_create_biomarkers.sql` | `biomarkers` (test_name, value, unit, normal_min/max, `is_abnormal` computed column) |
| `00009_create_prescriptions.sql` | `prescriptions` (medications JSONB, issued_at, valid_until, notes) |
| `00010_create_symptom_sessions.sql` | `symptom_sessions` (AI symptom checker history) |
| `00011_create_patient_embeddings.sql` | `patient_embeddings` (vector embeddings for AI features) |
| `00012_create_rls_policies.sql` | RLS on all tables |
| `00013_create_functions.sql` | `get_patient_id_for_user()`, `get_doctor_id_for_user()`, `doctor_has_access_to_patient()`, `update_updated_at_column()` |
| `00014_create_triggers.sql` | `updated_at` triggers |
| `00015_fix_rls_policies.sql` | RLS policy corrections |
| `20260326000011_add_notifications_and_appointments.sql` | `notifications`, `appointments` |
| `20260326000012_add_updated_at_columns.sql` | `updated_at` columns added where missing |
| `20260329000001_storage_and_fixes.sql` | Storage buckets + assorted RLS fixes |
| `20260418000001_add_fcm_tokens.sql` | `fcm_tokens` |
| `20260418000002_family_and_clinical.sql` | **`family_members`, `visit_vitals`, `doctor_notes`** + `ALTER appointments` (booked_by/for) + `ALTER visits` (follow_up_date, icd_code, visit_type, triage_level) |
| `20260418000003_medications_documents_vaccinations.sql` | `medication_schedules`, `medication_logs`, `patient_documents`, `vaccinations` + `patient-documents` storage bucket |

**Migration `20260418000003` is not yet pushed to dev/prod** — see [pending.md](../pending.md). Run `supabase db push` before the medications/documents/vaccinations features will work against the deployed environment.

---

## Tables — spec coverage

All tables from [../CLAUDE.md](../CLAUDE.md) exist. The key recently-added ones:

### `visit_vitals` (NEW in 20260418000002)
```
id            uuid PK
visit_id      uuid → visits.id
patient_id    uuid → patients.id
bp_systolic   int
bp_diastolic  int
heart_rate    int
temperature_c numeric(4,1)
weight_kg     numeric(5,2)
height_cm     numeric(5,2)
spo2_percent  numeric(4,1)
recorded_at   timestamptz default now()
recorded_by   uuid (doctor or auth uid)
```
One-to-many from `visits`. Read by patient and doctor.

### `family_members` (NEW in 20260418000002)
```
id                       uuid PK
primary_patient_id       uuid → patients.id
member_patient_id        uuid → patients.id   (NULL until member joins HealthOS)
relationship             text  (spouse/child/parent/sibling/guardian/other)
full_name                text
date_of_birth            date
gender                   text
phone                    text
is_dependent             boolean
can_view_records         boolean
can_manage_appointments  boolean
invite_status            text  (not_invited/invited/linked)
created_at               timestamptz
```

### `doctor_notes` (NEW in 20260418000002)
```
id          uuid PK
patient_id  uuid → patients.id
doctor_id   uuid → doctors.id
content     text
is_private  boolean default true
created_at  timestamptz
updated_at  timestamptz
```
Patient sees rows where `is_private = false` only.

### Extensions to `appointments` (in 20260418000002)
```
+ booked_by_patient_id   uuid → patients.id
+ booked_for_member_id   uuid → family_members.id (nullable)
```

### Extensions to `visits` (in 20260418000002)
```
+ follow_up_date  date
+ icd_code        text
+ visit_type      text  (consultation/follow_up/emergency/procedure)
+ triage_level    text  (emergency/see_doctor/home_care)
```

---

## Dart model ↔ DB sync status

| Model | Status | Drift |
|---|---|---|
| `Patient` | ✅ in sync | — |
| `Doctor` | ✅ in sync | — |
| `Hospital` | ✅ in sync | — |
| `Visit` | 🔴 OUT OF SYNC | Missing: `follow_up_date`, `icd_code`, `visit_type`, `triage_level`. See [03-known-issues.md ISSUE-002](03-known-issues.md). |
| `VisitVitals` | ✅ in sync | — |
| `Prescription` | ✅ in sync | — |
| `LabReport` | ✅ in sync | — |
| `Biomarker` | ✅ in sync | — |
| `Appointment` | 🔴 OUT OF SYNC | Missing: `booked_by_patient_id`, `booked_for_member_id`. See [03-known-issues.md ISSUE-003](03-known-issues.md). |
| `FamilyMember` | ✅ in sync | — |
| `DoctorNote` | ✅ in sync | — |
| `Notification` | ✅ in sync | — |
| `MedicationSchedule`, `MedicationLog` | ✅ in sync | — |
| `PatientDocument` | ✅ in sync | — |
| `Vaccination` | ✅ in sync | — |

To verify drift after schema changes: run `dart run build_runner build --delete-conflicting-outputs` in `packages/core`, then check that no `_$ModelFromJson` reads complain about missing keys.

---

## RLS — what to know

- Helper functions live in `00013_create_functions.sql`:
  - `get_patient_id_for_user()` → resolves the calling auth user to a patient row.
  - `get_doctor_id_for_user()` → same for doctors.
  - `doctor_has_access_to_patient(p_id, d_id)` → checks `access_grants`.
- Policies were corrected in `00015_fix_rls_policies.sql` after circular-dependency issues during initial rollout.
- Migration `20260418000002` added policies for `family_members`, `visit_vitals`, `doctor_notes`. Validate these against the new auth path once [ISSUE-001](03-known-issues.md) is resolved — RLS that uses `auth.uid()` will silently filter to "no rows" if the auth chain is wrong, which masks bugs as "empty list" UI.

---

## Storage buckets

- `avatars` (created in 00003_create_patients.sql or storage_and_fixes; check)
- `lab-reports` (created in 20260329000001_storage_and_fixes.sql)
- `patient-documents` (created in 20260418000003_medications_documents_vaccinations.sql) — **not yet pushed to remote**

Each bucket has its own RLS policies — keep them in sync with the table-level policies.

---

## How to update this file

When you add or alter a migration:
1. Append it to the migration table at the top (in order).
2. If it adds/alters tables, update the relevant section with the new columns.
3. If it changes a model, update the **Dart model ↔ DB sync** table.
4. If it changes RLS, note it under **RLS — what to know**.
5. Add a one-line entry to [CHANGELOG.md](CHANGELOG.md).

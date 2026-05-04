# 01 — Current State

A feature-by-feature audit of what is actually shipped, mapped against the spec in [../CLAUDE.md](../CLAUDE.md).

**Legend:**
- ✅ **DONE** — implemented, wired up, expected to work end-to-end.
- 🟡 **PARTIAL** — UI/screens exist but a wiring gap, model gap, or missing dependency means it doesn't fully work.
- 🔴 **BROKEN** — code exists but has a known defect that prevents it functioning.
- ⬜ **TODO** — not started.

---

## 1. Database

| Table | Status | Migration | Notes |
|-------|--------|-----------|-------|
| `hospitals` | ✅ | [00002_create_hospitals.sql](../supabase/migrations/00002_create_hospitals.sql) | |
| `patients` | ✅ | [00003_create_patients.sql](../supabase/migrations/00003_create_patients.sql) | All spec columns present. |
| `doctors` | ✅ | [00004_create_doctors.sql](../supabase/migrations/00004_create_doctors.sql) | |
| `access_grants` | ✅ | [00005_create_access_grants.sql](../supabase/migrations/00005_create_access_grants.sql) | Status enum is `active/revoked/expired`, **not** `pending/approved/rejected` per spec. See [03-known-issues.md](03-known-issues.md). |
| `visits` | ✅ | [00006_create_visits.sql](../supabase/migrations/00006_create_visits.sql) + [20260418000002_family_and_clinical.sql](../supabase/migrations/20260418000002_family_and_clinical.sql) | Extended with `follow_up_date`, `icd_code`, `visit_type`, `triage_level`. |
| `visit_vitals` | ✅ | [20260418000002_family_and_clinical.sql](../supabase/migrations/20260418000002_family_and_clinical.sql) | |
| `prescriptions` | ✅ | [00009_create_prescriptions.sql](../supabase/migrations/00009_create_prescriptions.sql) | |
| `lab_reports` | ✅ | [00007_create_lab_reports.sql](../supabase/migrations/00007_create_lab_reports.sql) | |
| `biomarkers` | ✅ | [00008_create_biomarkers.sql](../supabase/migrations/00008_create_biomarkers.sql) | |
| `appointments` | ✅ | [20260326000011_add_notifications_and_appointments.sql](../supabase/migrations/20260326000011_add_notifications_and_appointments.sql) + extension migration | Now has `booked_by_patient_id`, `booked_for_member_id`. |
| `family_members` | ✅ | [20260418000002_family_and_clinical.sql](../supabase/migrations/20260418000002_family_and_clinical.sql) | |
| `doctor_notes` | ✅ | [20260418000002_family_and_clinical.sql](../supabase/migrations/20260418000002_family_and_clinical.sql) | |
| `notifications` | ✅ | [20260326000011_add_notifications_and_appointments.sql](../supabase/migrations/20260326000011_add_notifications_and_appointments.sql) | |
| `fcm_tokens` | ✅ | [20260418000001_add_fcm_tokens.sql](../supabase/migrations/20260418000001_add_fcm_tokens.sql) | |
| `medication_schedules`, `medication_logs`, `patient_documents`, `vaccinations` | ✅ | [20260418000003_medications_documents_vaccinations.sql](../supabase/migrations/20260418000003_medications_documents_vaccinations.sql) | Extra features beyond original spec. |
| `symptom_sessions`, `patient_embeddings` | ✅ | [00010](../supabase/migrations/00010_create_symptom_sessions.sql), [00011](../supabase/migrations/00011_create_patient_embeddings.sql) | For AI features. |

**RLS:** policies in [00012](../supabase/migrations/00012_create_rls_policies.sql) and [00015](../supabase/migrations/00015_fix_rls_policies.sql), extended in 20260418000002. **Not yet validated end-to-end** against the new Firebase auth path.

---

## 2. Patient App

### Auth & onboarding
| Feature | Status | Files |
|---|---|---|
| Phone OTP sign-in | 🔴 BROKEN | [phone_input_screen.dart](../apps/patient_app/lib/src/features/auth/screens/phone_input_screen.dart), [auth_service.dart](../packages/supabase_client/lib/src/auth/auth_service.dart) — uses Firebase, but profile lookup uses Supabase `auth_id` (mismatch). |
| Email OTP / magic link | 🟡 PARTIAL | Same code path; same mismatch. |
| Google Sign-In | 🔴 BROKEN | [auth_service.dart:106](../packages/supabase_client/lib/src/auth/auth_service.dart#L106) — uses Firebase + `google_sign_in`. Real Google client IDs not configured; deep link wiring uses old Supabase callback URL. |
| Profile setup screen | 🟡 PARTIAL | [profile_setup_screen.dart](../apps/patient_app/lib/src/features/auth/screens/profile_setup_screen.dart) — saves a `patients` row, but `auth_id` will not match because of the Firebase/Supabase split. |
| Health ID generation | ✅ | Done at insert time (DB default / trigger). |
| Router redirect on missing profile | 🟡 PARTIAL | [app_router.dart:50-76](../apps/patient_app/lib/src/routing/app_router.dart#L50-L76) — logic is correct, but depends on the broken auth chain. |

### Home & navigation
| Feature | Status | Files |
|---|---|---|
| Home screen w/ Health ID card, upcoming appt, today's doses, quick actions | ✅ | [home_screen.dart](../apps/patient_app/lib/src/features/home/screens/home_screen.dart) |
| App shell with bottom nav | ✅ | [app_shell.dart](../apps/patient_app/lib/src/routing/app_shell.dart) |
| QR display of Health ID | ✅ | [qr_display_screen.dart](../apps/patient_app/lib/src/features/qr/screens/qr_display_screen.dart) |

### Records
| Feature | Status | Files |
|---|---|---|
| Reports list w/ skeletons | ✅ | [reports_list_screen.dart](../apps/patient_app/lib/src/features/records/screens/reports_list_screen.dart) |
| Report detail w/ biomarker tabs + trend chart | ✅ | [report_detail_screen.dart](../apps/patient_app/lib/src/features/records/screens/report_detail_screen.dart) |
| Visits timeline | ⬜ TODO | No `visits_list_screen.dart` exists in patient_app. The home screen shows the next appointment but there is no patient-facing visit history. |
| Visit detail (incl. vitals) | ⬜ TODO | Same — no screen for viewing a past visit's vitals. |
| Prescriptions list (patient view) | ⬜ TODO | Patient app has no `prescriptions/` feature folder. |

### AI
| Feature | Status | Files |
|---|---|---|
| Symptom checker chat | ✅ | [symptom_checker_screen.dart](../apps/patient_app/lib/src/features/symptoms/screens/symptom_checker_screen.dart) |

### Access management
| Feature | Status | Files |
|---|---|---|
| View access grants | ✅ | [access_grant_screen.dart](../apps/patient_app/lib/src/features/access/screens/access_grant_screen.dart) |
| Grant doctor by Health ID | ✅ | [grant_doctor_screen.dart](../apps/patient_app/lib/src/features/access/screens/grant_doctor_screen.dart) |
| Approve pending request notification → in-app accept | 🟡 PARTIAL | Status enum mismatch (`pending` not in DB enum) means the "doctor requests, patient approves" flow won't compile against current schema. |

### Family
| Feature | Status | Files |
|---|---|---|
| Family hub list | ✅ | [family_hub_screen.dart](../apps/patient_app/lib/src/features/family/screens/family_hub_screen.dart) |
| Add family member (3-step) | 🟡 PARTIAL | [add_family_member_screen.dart](../apps/patient_app/lib/src/features/family/screens/add_family_member_screen.dart) — works as form; SMS invite is not wired (no SMS provider). |
| Family member detail | ✅ | [family_member_detail_screen.dart](../apps/patient_app/lib/src/features/family/screens/family_member_detail_screen.dart) — needs records tab per [pending.md](../pending.md). |
| Edit family member | ✅ | [edit_family_member_screen.dart](../apps/patient_app/lib/src/features/family/screens/edit_family_member_screen.dart) |

### Appointments
| Feature | Status | Files |
|---|---|---|
| Appointments list | ✅ | [appointments_screen.dart](../apps/patient_app/lib/src/features/appointments/screens/appointments_screen.dart) |
| Book appointment (4-step: For whom → Doctor → Date/Time → Confirm) | 🔴 BROKEN | [book_appointment_screen.dart](../apps/patient_app/lib/src/features/appointments/screens/book_appointment_screen.dart) — UI is built, but the `Appointment` model is missing `booked_by_patient_id` and `booked_for_member_id`, so the family-member booking field will not round-trip. See [03-known-issues.md](03-known-issues.md). |

### Profile
| Feature | Status | Files |
|---|---|---|
| Profile screen | ✅ | [profile_screen.dart](../apps/patient_app/lib/src/features/profile/screens/profile_screen.dart) |
| Profile edit | ✅ | [profile_edit_screen.dart](../apps/patient_app/lib/src/features/profile/screens/profile_edit_screen.dart) |

### Notifications
| Feature | Status | Files |
|---|---|---|
| Notifications list w/ swipe-to-dismiss | ✅ | [notifications_screen.dart](../apps/patient_app/lib/src/features/notifications/screens/notifications_screen.dart) |
| FCM push delivery | 🔴 BROKEN | Edge function is a stub (`supabase/functions/notifications/index.ts:55` has TODO). FCM tokens are stored but never used to dispatch. |

### Medications / Documents / Vaccinations (extra features)
| Feature | Status | Files |
|---|---|---|
| Medication schedule list + add | ✅ | [medications_list_screen.dart](../apps/patient_app/lib/src/features/medications/screens/medications_list_screen.dart) |
| Local push reminders | ⬜ TODO | Per [pending.md](../pending.md) — needs `flutter_local_notifications`. |
| Documents upload + list | ✅ | [documents_list_screen.dart](../apps/patient_app/lib/src/features/documents/screens/documents_list_screen.dart) |
| Vaccinations list + add | ✅ | [vaccinations_list_screen.dart](../apps/patient_app/lib/src/features/vaccinations/screens/vaccinations_list_screen.dart) |

---

## 3. Doctor App

| Feature | Status | Files |
|---|---|---|
| Login (phone / Google) | 🔴 BROKEN | Same Firebase/Supabase split-brain as patient app. |
| "Account not found" screen | 🟡 PARTIAL | [doctor_not_found_screen.dart](../apps/doctor_app/lib/src/features/auth/screens/doctor_not_found_screen.dart) exists but the router gate that decides when to show it depends on the broken auth chain. |
| Patient list (from access grants) | ✅ | [patient_list_screen.dart](../apps/doctor_app/lib/src/features/patients/screens/patient_list_screen.dart) |
| Patient detail | ✅ | [patient_detail_screen.dart](../apps/doctor_app/lib/src/features/patients/screens/patient_detail_screen.dart) |
| Edit medical history (allergies / conditions) | ✅ | [edit_medical_history_sheet.dart](../apps/doctor_app/lib/src/features/patients/screens/edit_medical_history_sheet.dart) |
| Create visit w/ vitals | 🟡 PARTIAL | [create_visit_screen.dart](../apps/doctor_app/lib/src/features/visits/screens/create_visit_screen.dart) — UI complete with vitals grid, but the `Visit` Dart model is missing `visit_type`, `follow_up_date`, `icd_code`, `triage_level`, so reads will drop those fields. See [03-known-issues.md](03-known-issues.md). |
| Create prescription | ✅ | [create_prescription_screen.dart](../apps/doctor_app/lib/src/features/prescriptions/screens/create_prescription_screen.dart) |
| Doctor prescriptions list | ✅ | [doctor_prescriptions_list_screen.dart](../apps/doctor_app/lib/src/features/prescriptions/screens/doctor_prescriptions_list_screen.dart) |
| Add lab result (manual entry) | ✅ | [add_lab_result_screen.dart](../apps/doctor_app/lib/src/features/patients/screens/add_lab_result_screen.dart) |
| Quick note (private/shared toggle) | ✅ | [quick_note_screen.dart](../apps/doctor_app/lib/src/features/patients/screens/quick_note_screen.dart) |
| Appointments | ✅ | [appointments_screen.dart](../apps/doctor_app/lib/src/features/appointments/screens/appointments_screen.dart) |
| Create appointment | ✅ | [create_appointment_screen.dart](../apps/doctor_app/lib/src/features/appointments/screens/create_appointment_screen.dart) (note: spec says doctors do NOT create appointments — patients do; review whether this should exist). |
| AI summary | ✅ | [ai_summary_screen.dart](../apps/doctor_app/lib/src/features/ai_summary/screens/ai_summary_screen.dart) |
| Doctor profile | ✅ | [doctor_profile_screen.dart](../apps/doctor_app/lib/src/features/profile/screens/doctor_profile_screen.dart) |
| View patient medications / documents (read-side of new patient features) | ⬜ TODO | Per [pending.md](../pending.md) — RLS allows it; UI not built. |
| DS consistency pass (Icons.* → HosIcons.*) | ⬜ TODO | Per [pending.md](../pending.md). |

---

## 4. Hospital Portal

| Feature | Status | Files |
|---|---|---|
| Admin login (email/password) | 🔴 BROKEN | Same auth issue as patient/doctor apps. |
| Dashboard | 🟡 PARTIAL | [dashboard_screen.dart](../apps/hospital_portal/lib/src/features/dashboard/screens/dashboard_screen.dart) — placeholder per [pending.md](../pending.md); needs StatCards, recent activity table. |
| Doctors list | ✅ | [doctors_list_screen.dart](../apps/hospital_portal/lib/src/features/doctors/screens/doctors_list_screen.dart) |
| Doctor detail | ✅ | [doctor_detail_screen.dart](../apps/hospital_portal/lib/src/features/doctors/screens/doctor_detail_screen.dart) |
| Create / edit doctor | ✅ | [doctor_form_screen.dart](../apps/hospital_portal/lib/src/features/doctors/screens/doctor_form_screen.dart) |
| Patients list | ✅ | [patients_list_screen.dart](../apps/hospital_portal/lib/src/features/patients/screens/patients_list_screen.dart) |
| Patient detail | ✅ | [patient_detail_screen.dart](../apps/hospital_portal/lib/src/features/patients/screens/patient_detail_screen.dart) |
| Settings (hospital info, departments) | 🟡 PARTIAL | [settings_screen.dart](../apps/hospital_portal/lib/src/features/settings/screens/settings_screen.dart) — placeholder per [pending.md](../pending.md). |
| Send invite email when doctor created | ⬜ TODO | No email sender wired. |

---

## 5. Lab Portal

| Feature | Status | Files |
|---|---|---|
| Lab tech login | 🔴 BROKEN | Same auth issue. |
| Patient search by Health ID | ✅ | [patient_search_screen.dart](../apps/lab_portal/lib/src/features/patients/screens/patient_search_screen.dart) |
| Upload lab report file | ✅ | [report_upload_screen.dart](../apps/lab_portal/lib/src/features/upload/screens/report_upload_screen.dart) |
| Reports list | ✅ | [reports_list_screen.dart](../apps/lab_portal/lib/src/features/reports/screens/reports_list_screen.dart) |
| Report review | 🟡 PARTIAL | [report_review_screen.dart](../apps/lab_portal/lib/src/features/reports/screens/report_review_screen.dart) — PDF viewer is a placeholder per [pending.md](../pending.md). |

---

## 6. Cross-cutting infrastructure

| Concern | Status | Notes |
|---|---|---|
| Shared `ui_kit` design system | ✅ | 15 widgets shipped this pass. `DesignGallery` at `/design` (debug only). |
| Shared `core` models | 🟡 PARTIAL | `Visit` and `Appointment` models out of sync with DB — see [03-known-issues.md](03-known-issues.md). |
| Shared `supabase_client` repositories | ✅ | All required repos exist. |
| `ai_client` (Gemini) | ✅ | Used by symptom checker and AI summary. |
| Push notifications (FCM) | 🔴 BROKEN | Tokens stored, edge function stubbed, no dispatcher. |
| OAuth deep links | 🔴 BROKEN | Android intent filters reference old `io.supabase.healthos://` scheme; iOS not configured. |
| `.env` loading | 🟡 PARTIAL | `.env.example` exists; production credentials are hardcoded in every `main.dart`. |
| Test suite | ⬜ TODO | No tests visible at workspace root. |
| CI | ✅ | Claude review workflows present (`.github/workflows/`). |

---

## 7. What still needs scoping

These are mentioned in the spec but I can't tell from the code whether anyone has decided how to build them:

- **Patient-doctor messaging** — listed as "Not Started" in the spec.
- **Appointment rescheduling** — no flow exists.
- **Video consultation** — no flow exists.
- **Offline mode** — no caching layer exists.

Treat these as future-phase work; not blockers.

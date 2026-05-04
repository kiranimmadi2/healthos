# Doctor App

Tablet-first + web app for doctors viewing patients (via access grants) and creating clinical records.

**Path:** [../../apps/doctor_app/](../../apps/doctor_app/)
**Routing:** [app_shell.dart](../../apps/doctor_app/lib/src/routing/app_shell.dart)

---

## Feature folders

```
lib/src/features/
├── ai_summary/      AI-generated patient health summary
├── appointments/    List + create
├── auth/            Doctor login, "account not found" screen
├── dashboard/       (Currently uses patient_list as the home)
├── notifications/   In-app notifications
├── patients/        Patient list, detail, edit medical history, add lab result, quick note
├── prescriptions/   Create prescription, doctor's prescriptions list
├── profile/         Doctor profile
└── visits/          Create visit (now with vitals grid)
```

---

## Screens

| Screen | File |
|---|---|
| Login | [doctor_login_screen.dart](../../apps/doctor_app/lib/src/features/auth/screens/doctor_login_screen.dart) |
| Account not found | [doctor_not_found_screen.dart](../../apps/doctor_app/lib/src/features/auth/screens/doctor_not_found_screen.dart) |
| Dashboard / patient list | [patient_list_screen.dart](../../apps/doctor_app/lib/src/features/patients/screens/patient_list_screen.dart) |
| Patient detail | [patient_detail_screen.dart](../../apps/doctor_app/lib/src/features/patients/screens/patient_detail_screen.dart) |
| Edit medical history (allergies/conditions) | [edit_medical_history_sheet.dart](../../apps/doctor_app/lib/src/features/patients/screens/edit_medical_history_sheet.dart) |
| Add lab result | [add_lab_result_screen.dart](../../apps/doctor_app/lib/src/features/patients/screens/add_lab_result_screen.dart) |
| Quick note (private/shared) | [quick_note_screen.dart](../../apps/doctor_app/lib/src/features/patients/screens/quick_note_screen.dart) |
| Create visit + vitals | [create_visit_screen.dart](../../apps/doctor_app/lib/src/features/visits/screens/create_visit_screen.dart) |
| Create prescription | [create_prescription_screen.dart](../../apps/doctor_app/lib/src/features/prescriptions/screens/create_prescription_screen.dart) |
| Prescriptions list | [doctor_prescriptions_list_screen.dart](../../apps/doctor_app/lib/src/features/prescriptions/screens/doctor_prescriptions_list_screen.dart) |
| Appointments | [appointments_screen.dart](../../apps/doctor_app/lib/src/features/appointments/screens/appointments_screen.dart) |
| Create appointment | [create_appointment_screen.dart](../../apps/doctor_app/lib/src/features/appointments/screens/create_appointment_screen.dart) — **conflicts with spec**, see [ISSUE-008](../03-known-issues.md). |
| AI summary | [ai_summary_screen.dart](../../apps/doctor_app/lib/src/features/ai_summary/screens/ai_summary_screen.dart) |
| Doctor profile | [doctor_profile_screen.dart](../../apps/doctor_app/lib/src/features/profile/screens/doctor_profile_screen.dart) |
| Notifications | [notifications_screen.dart](../../apps/doctor_app/lib/src/features/notifications/screens/notifications_screen.dart) |

---

## Providers

- `authStateProvider` / `currentUserIdProvider` — Firebase-based (broken; see [ISSUE-001](../03-known-issues.md)).
- `currentDoctorProvider`, `currentDoctorIdProvider` — loads `doctors` row by `auth_id`.
- `appointmentsProvider`
- `aiSummaryProvider` — calls AI service via `ai_client`.
- `doctorPrescriptionsProvider`

---

## Known issues for this app

- **🔴 [ISSUE-001](../03-known-issues.md)** — auth split-brain blocks login → patient list flow.
- **🔴 [ISSUE-002](../03-known-issues.md)** — `Visit` model missing `visit_type`, `follow_up_date`, `icd_code`, `triage_level`. The create form writes them; reads drop them.
- **🟡 [ISSUE-008](../03-known-issues.md)** — `create_appointment_screen.dart` exists but spec says doctors don't create appointments. Decide and either delete or amend spec.
- **🟡 [ISSUE-005](../03-known-issues.md)** — hardcoded Supabase URL/key in [main.dart](../../apps/doctor_app/lib/main.dart).

---

## Pending work for this app

From [02-pending-features.md](../02-pending-features.md) and [../../pending.md](../../pending.md):

- **P1:** Surface patient-owned data (`medication_schedules`, `patient_documents`, `vaccinations`) on patient detail. RLS already permits.
- **P1:** Speed Dial FAB consolidating New Visit / New Prescription / Add Lab Result / Quick Note.
- **P2:** DS consistency pass — replace `Icons.*` with `HosIcons.*`, `CircularProgressIndicator` → `HosLoading` / skeletons.
- **P2:** Use `HosTimeline` on patient detail timeline tab; `HosVitalsCard` in create-visit preview; `HosPrescriptionCard` in create-prescription review.
- **P2:** Dark mode pass.

---

## Notes on the doctor onboarding flow

The spec describes:
1. Hospital admin pre-creates doctor (`doctors` row with `verified=false`).
2. Doctor receives email/link, signs in.
3. App finds the `doctors` row → dashboard.
4. If no row → "Account not found" screen.

Step 2 needs an email mailer (not yet wired — see hospital portal pending). Step 3 depends on the auth fix.

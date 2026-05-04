# Hospital Portal

Web app for hospital administrators to manage doctors, view appointments, and configure hospital settings.

**Path:** [../../apps/hospital_portal/](../../apps/hospital_portal/)
**Routing:** [admin_shell.dart](../../apps/hospital_portal/lib/src/layout/admin_shell.dart)

---

## Feature folders

```
lib/src/features/
├── auth/        Admin login (email + password)
├── dashboard/   Top-level dashboard (placeholder)
├── doctors/     Doctors CRUD (list, detail, create/edit form)
├── patients/    Patient list and detail (read-only from hospital scope)
└── settings/    Hospital settings (placeholder)
```

---

## Screens

| Screen | File | Status |
|---|---|---|
| Admin login | [admin_login_screen.dart](../../apps/hospital_portal/lib/src/features/auth/screens/admin_login_screen.dart) | 🔴 Auth broken |
| Dashboard | [dashboard_screen.dart](../../apps/hospital_portal/lib/src/features/dashboard/screens/dashboard_screen.dart) | 🟡 Placeholder; needs StatCards + recent activity |
| Doctors list | [doctors_list_screen.dart](../../apps/hospital_portal/lib/src/features/doctors/screens/doctors_list_screen.dart) | ✅ |
| Doctor detail | [doctor_detail_screen.dart](../../apps/hospital_portal/lib/src/features/doctors/screens/doctor_detail_screen.dart) | ✅ |
| Doctor form (create/edit) | [doctor_form_screen.dart](../../apps/hospital_portal/lib/src/features/doctors/screens/doctor_form_screen.dart) | ✅ but no email invite is dispatched on create |
| Patients list | [patients_list_screen.dart](../../apps/hospital_portal/lib/src/features/patients/screens/patients_list_screen.dart) | ✅ |
| Patient detail | [patient_detail_screen.dart](../../apps/hospital_portal/lib/src/features/patients/screens/patient_detail_screen.dart) | ✅ |
| Settings | [settings_screen.dart](../../apps/hospital_portal/lib/src/features/settings/screens/settings_screen.dart) | 🟡 Placeholder |

---

## Providers

- `authStateProvider` — Firebase-based (broken).
- `currentHospitalProvider` — loads the hospital admin's hospital.

---

## Known issues for this app

- **🔴 [ISSUE-001](../03-known-issues.md)** — auth split-brain.
- **🟡 [ISSUE-005](../03-known-issues.md)** — hardcoded Supabase credentials.
- **No mailer** for doctor invite emails. Spec says doctors receive a link after admin creates them; today nothing is sent.

---

## Pending work

From [02-pending-features.md](../02-pending-features.md) and [../../pending.md](../../pending.md):

- **P1:** Dashboard — 4 `HosStatCard` (patients, doctors, appointments today, pending verifications) + recent activity table + side-by-side responsive layout >1200px.
- **P1:** Settings — hospital info form, notification preference toggles, departments CRUD.
- **P1:** Email invite when a doctor is created (Resend / SendGrid / Supabase Auth invite link).
- **P1:** Pending access requests view (doctor → patient).
- **P2:** Convert `doctors_list_screen.dart` and `patients_list_screen.dart` to shared `HosDataTable`.
- **P2:** Dark mode pass.

# Patient App

Flutter mobile + web app for patients managing their own and family members' health.

**Path:** [../../apps/patient_app/](../../apps/patient_app/)
**Routing entry:** [app_router.dart](../../apps/patient_app/lib/src/routing/app_router.dart)
**Bottom nav shell:** [app_shell.dart](../../apps/patient_app/lib/src/routing/app_shell.dart)

---

## Feature folders

```
lib/src/features/
├── access/         Grant/revoke doctor access
├── appointments/   List + book (4-step flow)
├── auth/           Phone input, OTP verify, profile setup
├── documents/      Upload + list patient documents
├── family/         Family hub, add/edit/detail
├── home/           Dashboard
├── medications/    Schedules + log doses
├── notifications/  In-app notifications list
├── profile/        View + edit profile
├── qr/             Health ID QR display
├── records/        Lab reports list + detail (with biomarker trends)
├── symptoms/       AI symptom checker
└── vaccinations/   List + add vaccination records
```

**Notable gaps:** no `visits/` and no `prescriptions/` feature folders. Spec says patients should see their visit history (with vitals) and prescriptions; today they cannot. Tracked in [02-pending-features.md](../02-pending-features.md).

---

## Routes

| Path | Screen | Notes |
|---|---|---|
| `/auth` | `PhoneInputScreen` | Sign-in entry. |
| `/auth/verify` | `OtpVerifyScreen` | Pass `phone` or `email` via `extra`. |
| `/auth/setup` | `ProfileSetupScreen` | Forced redirect when authenticated but no `patients` row. |
| `/home` | `HomeScreen` | Health ID card, upcoming appt, today's doses, quick actions. |
| `/reports` | `ReportsListScreen` | |
| `/reports/:id` | `ReportDetailScreen` | Multi-biomarker tabs + trend chart. |
| `/symptoms` | `SymptomCheckerScreen` | AI chat. |
| `/access` | `AccessGrantScreen` | List of doctor grants. |
| `/access/grant` | `GrantDoctorScreen` | Add by Health ID. |
| `/profile` | `ProfileScreen` | |
| `/profile/edit` | `ProfileEditScreen` | |
| `/profile/family` | `FamilyHubScreen` | |
| `/profile/family/add` | `AddFamilyMemberScreen` | 3-step. |
| `/profile/family/:id` | `FamilyMemberDetailScreen` | |
| `/profile/family/:id/edit` | `EditFamilyMemberScreen` | |
| `/qr` | `QrDisplayScreen` | |
| `/notifications` | `NotificationsScreen` | Swipe-to-dismiss. |
| `/appointments` | `AppointmentsScreen` | |
| `/appointments/book` | `BookAppointmentScreen` | 4-step: For whom → Doctor → Date/Time → Confirm. |
| `/medications` | `MedicationsListScreen` | |
| `/medications/add` | `AddMedicationScheduleScreen` | |
| `/documents` | `DocumentsListScreen` | |
| `/documents/upload` | `UploadDocumentScreen` | |
| `/vaccinations` | `VaccinationsListScreen` | |
| `/vaccinations/add` | `AddVaccinationScreen` | |
| `/design` | `DesignGallery` | **Debug only.** |

---

## Providers

| Provider | What it does |
|---|---|
| `authStateProvider` | Stream of Firebase `User?` (currently — should be Supabase `AuthState`). |
| `currentUserIdProvider` | `User?.uid`. |
| `currentPatientProvider` | Loads the patient row keyed by auth user. **Currently broken** because of the auth split-brain. |
| `patientProfileStateProvider` | Enum: `loading / missing / present`. Drives router redirect. |
| `appointmentsProvider`, `upcomingAppointmentsProvider` | |
| `medicationsProvider` | |
| `documentsProvider` | |
| `notificationsProvider`, `unreadNotificationCountProvider` | |
| `accessGrantsProvider` | |
| `familyMembersProvider` | |
| `recentActivityProvider` | |

---

## Known issues for this app

- **🔴 [ISSUE-001](../03-known-issues.md)** — auth split-brain blocks every authenticated screen.
- **🔴 [ISSUE-003](../03-known-issues.md)** — `Appointment` model missing `booked_by_patient_id` / `booked_for_member_id` → "For whom?" booking step has nowhere to write the family member id.
- **🔴 [ISSUE-005](../03-known-issues.md)** — hardcoded Supabase URL/key in [main.dart](../../apps/patient_app/lib/main.dart).
- **🟡 [ISSUE-004](../03-known-issues.md)** — `access_grants.status` enum mismatch breaks doctor-request approval flow.
- **🟢 [ISSUE-009](../03-known-issues.md)** — possible NPE on `home_screen.dart` when `fullName` is null.

---

## Pending UI work for this app

From [02-pending-features.md](../02-pending-features.md) and [../../pending.md](../../pending.md):

- **P1:** Build `features/visits/` (list + detail with vitals).
- **P1:** Build `features/prescriptions/` (read-only list).
- **P1:** Surface `doctor_notes` (where `is_private = false`) on the records timeline.
- **P2:** Rebuild `profile_setup_screen.dart` as 3-step `HosStepIndicator`.
- **P2:** Polish family screens (records tabs, permissions row).
- **P2:** Vaccination "next due" card on home if within 14 days.
- **P3:** Local push reminders for medications.

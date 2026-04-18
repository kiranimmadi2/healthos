# HealthOS — Pending Work

Tracks what is **not yet shipped** from the UI-polish + essential-features programme. Organised by the phases defined in
[`~/.claude/plans/patient-app-13-reflective-pike.md`](../.claude/plans/patient-app-13-reflective-pike.md).

**Current branch:** `feature/new-features`
**Last workspace `flutter analyze`:** clean (4 pre-existing info-level lints in `ai_client` / `core` / `supabase_client` library names — unrelated to this work).

---

## ✅ Shipped in this pass

- **DS foundation (Phase 0):** Lucide-based `HosIcons` facade, 15 new widgets (Skeleton, TabBar, StepIndicator, BottomSheet, DateField, DropdownField, MultiSelectChips, DataTable, Timeline, SpeedDial, VitalsCard, PrescriptionCard, LabReportCard, AppointmentCard, StatCard), extended `HosButton` with `.primary`/`.secondary`/`.tertiary`/`.destructive` factories + `HosIconButton`, upgraded `HosEmptyState`, `DesignGallery` at `/design` (debug-only).
- **Phase 1a Home:** `HosIconButton` AppBar, upcoming-appointment card, today's-doses card, refresh indicator, skeleton states, 7 quick actions.
- **Phase 1.5 (user-requested essentials):** migrations for `medication_schedules`, `medication_logs`, `patient_documents`, `vaccinations` + `patient-documents` storage bucket, full RLS; 4 Freezed models + 3 repositories; Medications (list + add + home today-doses card), Documents (list + upload via `file_picker`), Vaccinations (list with `HosTimeline` + upcoming-due + add), all wired into router and quick actions.
- **Phase 1b:** `ReportDetailScreen` rewritten with multi-biomarker tabs + `BiomarkerLineChart` trend + summary card; `ReportsListScreen` using `HosLabReportCard` + skeletons.
- **Phase 1c:** `SymptomCheckerScreen` — typing indicator, suggested prompts, rich triage result card, sectioned recommendations / what-to-do / what-to-avoid / when-to-seek-help, DS styling.
- **Phase 1d:** `BookAppointmentScreen` — 4-step flow via `HosStepIndicator` (For whom → Doctor → Date/Time → Confirm) with `HosAppointmentCard` preview.
- **Phase 1f:** `NotificationsScreen` — unread badge in title, swipe-to-dismiss, skeletons, empty state. `GrantDoctorScreen` — DS polish + `showHosBottomSheet` confirm sheet with info banner.
- **Minor doctor_app polish:** dashboard AppBar uses `HosIconButton` + `HosEmptyState` (unplanned but landed during consistency sweep).

---

## ⏳ Pending

### Phase 1e — Profile Setup & Family polish (small)

Current `profile_setup_screen.dart` works but can be rebuilt to match the DS step-pattern and pro feel now that we have the
widgets for it.

- [ ] `apps/patient_app/lib/src/features/auth/screens/profile_setup_screen.dart` → split into 3 steps via `HosStepIndicator`:
  Basics (name, DOB, gender) → Health (blood type, allergies via `HosMultiSelectChips`, conditions) → Emergency contact.
  Swap raw `Icons.*` for `HosIcons.*`.
- [ ] `family_member_detail_screen.dart` → add shared-records tabs via `HosTabBar` (Visits / Labs / Notes), permissions toggles row.
- [ ] `add_family_member_screen.dart` → wire `HosStepIndicator` for its 3-step form consistently.
- [ ] `profile_screen.dart` → quick consistency pass (icons + list tile accents).

### Phase 1.5 follow-up — Local push reminders for medications

Medication schedules are persisted; reminders are not yet delivered locally. This needs native platform setup and cannot
be completed purely in Dart.

- [ ] Add `flutter_local_notifications` + `timezone` to `apps/patient_app/pubspec.yaml`.
- [ ] iOS: add notification permissions to `ios/Runner/Info.plist` (`UIBackgroundModes`, alert/badge/sound request).
- [ ] Android: add `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, notification channel setup.
- [ ] Create `lib/src/features/medications/providers/reminders_service.dart` with:
  - `init()` — channel config + permission request.
  - `scheduleFor(MedicationSchedule s)` — for each `doseTimes[]` + `weekdays`, schedule a repeating zoned notification.
  - `cancelFor(String scheduleId)` — cancel pending for a schedule.
- [ ] Hook into `add_medication_schedule_screen.dart` (`_save`) and stop-schedule action.
- [ ] Tap handler → deep link to `/medications` with the dose pre-logged as "taken".

### Phase 2 — `doctor_app` consistency polish

All 15 screens exist and work. This is a pure DS consistency pass.

- [ ] Replace remaining `Icons.*` with `HosIcons.*` across `doctor_app/lib/src/features/*/screens/*`. Grep target: inside `apps/doctor_app/lib/src/features/`, `Icon\(Icons\.` should be zero.
- [ ] Replace `CircularProgressIndicator` in screens with `HosLoading` or `HosSkeleton*`.
- [ ] [create_visit_screen.dart](apps/doctor_app/lib/src/features/visits/screens/create_visit_screen.dart) — use `HosVitalsCard` for the preview panel.
- [ ] [create_prescription_screen.dart](apps/doctor_app/lib/src/features/prescriptions/screens/create_prescription_screen.dart) — use `HosPrescriptionCard` in review.
- [ ] [patient_detail_screen.dart](apps/doctor_app/lib/src/features/patients/screens/patient_detail_screen.dart) — swap the timeline tab for `HosTimeline`; swap FAB for `HosSpeedDial`.
- [ ] Dark-mode pass on every screen (currently untested).

### Phase 3 — `hospital_portal` dashboard + settings

- [ ] [dashboard_screen.dart](apps/hospital_portal/lib/src/features/dashboard/screens/dashboard_screen.dart) — flesh out with 4 `HosStatCard` (patients, doctors, appointments today, pending verifications) + recent activity using `HosDataTable` + side-by-side responsive layout >1200px.
- [ ] [settings_screen.dart](apps/hospital_portal/lib/src/features/settings/screens/settings_screen.dart) — hospital info form, notification preference toggles, department CRUD list.
- [ ] Convert [doctors_list_screen.dart](apps/hospital_portal/lib/src/features/doctors/screens/doctors_list_screen.dart) and [patients_list_screen.dart](apps/hospital_portal/lib/src/features/patients/screens/patients_list_screen.dart) to shared `HosDataTable`.

### Phase 4 — `lab_portal` polish

- [ ] Swap list screens ([reports_list_screen.dart](apps/lab_portal/lib/src/features/reports/screens/reports_list_screen.dart), `patient_search_screen.dart`) to `HosDataTable`.
- [ ] [report_review_screen.dart](apps/lab_portal/lib/src/features/reports/screens/report_review_screen.dart) — real PDF viewer (package candidate: `pdfx` — works on mobile + web). Currently a placeholder.
- [ ] Dark-mode pass.

### Phase 5 — Final QA

- [ ] Run `flutter analyze` at workspace root — target zero warnings, including the 4 pre-existing info-level lints (clean up the `library xxx;` declarations + HTML-in-doc in `patient_embedding.dart`).
- [ ] Visit `/design` route in each app, verify `DesignGallery` renders all widgets in light + dark.
- [ ] End-to-end flows per plan:
  1. Patient: sign up → profile setup → home → book appointment → view lab report → grant doctor access.
  2. Doctor: login → select patient → create visit w/ vitals → create prescription → add quick note → view AI summary.
  3. Hospital admin: login → see dashboard stats → onboard doctor → verify doctor.
  4. Lab tech: login → upload report → OCR → review biomarkers → approve.
- [ ] Take 66 screenshots (33 screens × 2 themes) for PR visual review.

### Cross-cutting items

- [ ] **Grep cleanup**: inside `apps/*/lib/src/features/`, `Icon\(Icons\.` should be zero and `EdgeInsets.all\(` / inline `Color\(` / inline `TextStyle\(` should approach zero (only allowed where DS tokens genuinely don't fit).
- [ ] **Supabase deploy**: run `supabase db push` against dev + prod to apply [20260418000003_medications_documents_vaccinations.sql](supabase/migrations/20260418000003_medications_documents_vaccinations.sql) and create the `patient-documents` bucket.
- [ ] **Doctor-side read of patient-owned data**: doctor_app does not yet surface `medication_schedules` or `patient_documents` on `patient_detail_screen.dart` — RLS allows them via access grants, just needs UI work.
- [ ] **Vaccinations on home feed**: the upcoming-due list currently lives only in `VaccinationsListScreen` — consider surfacing the next due shot on the Home dashboard if any is due within 14 days.

---

## Estimated remaining effort

| Item | Estimate |
|---|---|
| Phase 1e polish (Profile / family) | 0.5 day |
| Local push reminders (native) | 0.5 day |
| Phase 2 doctor_app polish | 1 day |
| Phase 3 hospital_portal | 1 day |
| Phase 4 lab_portal + PDF | 0.5 day |
| Phase 5 QA + screenshots | 0.5 day |
| **Total** | **~4 days** |

---

## File map — where the new code lives

- New widgets: [packages/ui_kit/lib/src/widgets/](packages/ui_kit/lib/src/widgets/) (15 new files).
- Icon facade: [packages/ui_kit/lib/src/icons/hos_icons.dart](packages/ui_kit/lib/src/icons/hos_icons.dart).
- DS gallery: [packages/ui_kit/lib/src/gallery/design_gallery.dart](packages/ui_kit/lib/src/gallery/design_gallery.dart) — mount at `/design` (debug only).
- Migrations: [supabase/migrations/20260418000003_medications_documents_vaccinations.sql](supabase/migrations/20260418000003_medications_documents_vaccinations.sql).
- New models: `medication_schedule.dart`, `medication_log.dart`, `patient_document.dart`, `vaccination.dart` in [packages/core/lib/src/models/](packages/core/lib/src/models/).
- New repos: `medication_repository.dart`, `patient_document_repository.dart`, `vaccination_repository.dart` in [packages/supabase_client/lib/src/repositories/](packages/supabase_client/lib/src/repositories/).
- New features: [apps/patient_app/lib/src/features/medications/](apps/patient_app/lib/src/features/medications/), [documents/](apps/patient_app/lib/src/features/documents/), [vaccinations/](apps/patient_app/lib/src/features/vaccinations/).

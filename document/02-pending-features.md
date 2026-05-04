# 02 — Pending Features

Work that is **not started** or **half done**, grouped by priority. Bugs that block already-shipped features live in [03-known-issues.md](03-known-issues.md); this file is about *new* surface area to add.

---

## P0 — Blockers (must ship before any UAT)

These are not "new" features per se, but without them no flow works end-to-end. Detailed plans in [04-implementation-plan.md](04-implementation-plan.md) and [03-known-issues.md](03-known-issues.md).

1. **Decide auth backend** (Firebase vs Supabase) and finish the migration. Currently both are wired, neither correctly. — [07-auth-system.md](07-auth-system.md)
2. **Sync `Visit` and `Appointment` Dart models with DB columns.** Forms write fields the model doesn't know about → reads silently drop them.
3. **Real Google OAuth credentials** in env + per-platform deep link config (Android intent filter for current scheme, iOS URL scheme, web redirect).
4. **Wire FCM dispatcher** — replace the stub edge function so the in-app `notifications` table writes actually push.

---

## P1 — Spec features that have no UI yet

### Patient app
- **Visits timeline / history view.** Spec says patient sees "visits with chief complaint, diagnosis, follow-up date" and a detail view including vitals. Today the patient app has no `visits/` feature folder.
  - Add `apps/patient_app/lib/src/features/visits/screens/visits_list_screen.dart` and `visit_detail_screen.dart`.
  - Add `VisitsRepository.listForPatient(patientId)` that joins `visit_vitals`.
  - Add a tile to home screen / records tab.
- **Prescriptions list (patient view).** Patients should see their own prescriptions; only the doctor app has a prescriptions screen today.
  - Add `apps/patient_app/lib/src/features/prescriptions/screens/prescriptions_list_screen.dart`.
- **Doctor-shared notes view.** `doctor_notes` table exists; patient should see rows where `is_private = false`.
  - Add to records timeline.

### Doctor app
- **View patient-owned data** — `medication_schedules`, `patient_documents`, `vaccinations`. RLS already permits doctors with access; UI is missing in `patient_detail_screen.dart`.
- **Speed Dial FAB on patient detail.** Spec calls for: New Visit, New Prescription, Add Lab Result, Quick Note. Buttons exist scattered; consolidate via `HosSpeedDial` (already in design kit).
- **Switch patient detail timeline tab to `HosTimeline`.** Per [pending.md](../pending.md).

### Hospital portal
- **Dashboard** — 4 `HosStatCard`s (patients, doctors, appointments today, pending verifications) + recent activity table.
- **Settings** — hospital info form, notification preferences, departments CRUD.
- **Doctor invite email** — when a doctor is pre-created, send a sign-in link to their email. No mailer is wired.
- **Pending access requests view** — listed in spec; no screen exists.

### Lab portal
- **Real PDF viewer** in `report_review_screen.dart` (candidate: `pdfx`). Currently a placeholder.
- **OCR or auto-extract biomarkers** from uploaded report — spec does not mandate, but the upload flow assumes someone enters values manually and that flow could be smoother.

---

## P2 — Polish / DS consistency

Tracked in detail in [../pending.md](../pending.md). Summary:

- Doctor app: replace `Icons.*` with `HosIcons.*` across all feature screens.
- Doctor app: replace `CircularProgressIndicator` with `HosLoading` / skeletons.
- Patient app Phase 1e: rebuild `profile_setup_screen.dart` as 3-step `HosStepIndicator` flow; consistency pass on family screens.
- Dark mode pass — every screen, every app.
- Lint: get `flutter analyze` to zero warnings (4 known info-level lints in `ai_client`/`core`/`supabase_client`).

---

## P3 — Cross-cutting capabilities

- **Local push for medication reminders** — `flutter_local_notifications` + `timezone`, native permissions, schedule wiring. Plan in [pending.md](../pending.md).
- **Vaccination upcoming-due card on home feed** — surface next due shot if within 14 days.
- **Test suite** — no tests exist. At minimum: widget tests for the broken auth/router redirect logic.
- **`.env` loading at runtime** — replace hardcoded credentials in all `main.dart`s with `flutter_dotenv` or build-time `--dart-define`.

---

## P4 — Future phases (not yet scoped)

Listed in spec as "Not Started":
- Patient-doctor messaging
- Appointment rescheduling
- Video consultation
- Offline mode
- Advanced search / filtering

Do not start these until the P0–P2 list is empty.

---

## How to update this file

When you finish a pending item, **delete it from this file** and add a one-line entry to [CHANGELOG.md](CHANGELOG.md). When you discover a new gap, add it here under the right priority. Don't let this list rot — it's the working backlog.

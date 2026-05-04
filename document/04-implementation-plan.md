# 04 — Implementation Plan

The prioritised plan to take HealthOS from its current state (~75% surface, ~60% functional) to spec-complete. Sequenced so that **fixing blockers unblocks everything downstream**.

Time estimates assume one engineer with full context. They are rough; treat as relative weights.

---

## Stage 0 — Decide & document (½ day)

Before any code: get a yes/no from the product owner on these forks. Without these decisions some fixes will need redoing.

| Decision | Options | Default |
|---|---|---|
| Auth backend | Firebase / Supabase | **Supabase** (matches DB schema and RLS) |
| `access_grants.status` enum | `pending/approved/rejected` (per spec) or `active/revoked/expired` (per current DB, plus `pending`) | **DB + add `pending`** |
| Doctor-created appointments | Allowed / forbidden | Confirm with product |

Update [../CLAUDE.md](../CLAUDE.md) once decided so the spec and code agree.

---

## Stage 1 — Fix the blockers (3–4 days)

After this stage, every existing screen should at least *load* against a logged-in user.

### 1.1 Unify auth backend (1.5 days) — fixes [ISSUE-001](03-known-issues.md)
Default path: revert to Supabase Auth. See the detailed fix plan in 03-known-issues.md.

Acceptance:
- Patient signs in with phone OTP → `patients` row is created with valid `auth_id`.
- `select * from patients where auth_id = auth.uid()` returns the right row.
- Same for doctor / hospital admin / lab tech.
- Google OAuth on web returns to the app and lands the user on `/home` (or `/auth/setup` for first-timers).

### 1.2 Re-sync `Visit` and `Appointment` models (½ day) — fixes [ISSUE-002, ISSUE-003](03-known-issues.md)
Add the missing fields, regenerate Freezed, verify the `CreateVisitScreen` round-trips and the family-member booking field is persisted.

Acceptance:
- Create a visit with `visit_type=consultation`, `follow_up_date=2026-06-01`, vitals. Re-fetch it. All fields are present.
- Book an appointment "for [family member]". Re-fetch in doctor app. Doctor sees the family member name.

### 1.3 Configure real OAuth credentials & deep links (½ day) — fixes [ISSUE-007](03-known-issues.md)
- Provision Google OAuth client IDs (web + iOS + Android) in Google Cloud.
- Update Supabase project's auth → Google provider with the web client secret.
- Add iOS `URL Types` entry; verify Android intent filter matches the Supabase callback scheme.
- Add a `.env` entry for the Google web client ID (used by web build).

### 1.4 Move credentials out of source (½ day) — fixes [ISSUE-005](03-known-issues.md)
`flutter_dotenv` or `--dart-define`. Same change applied to all four apps.

### 1.5 Reconcile `access_grants` enum (½ day) — fixes [ISSUE-004](03-known-issues.md)
Pick the option from Stage 0; add migration; update screens that compare on the status string.

---

## Stage 2 — Fill the spec-mandated UI gaps (4–5 days)

After this stage, every flow described in [../CLAUDE.md](../CLAUDE.md) has a screen.

### 2.1 Patient-side visits & prescriptions views (1 day)
- New `features/visits/` folder in `patient_app` with list + detail. Detail must render `visit_vitals` (existing repo).
- New `features/prescriptions/` folder with list (read-only).
- Doctor-shared notes (`is_private = false`) appear on the records timeline.

### 2.2 Doctor-side patient-owned data (1 day)
- In `patient_detail_screen.dart`, surface `medication_schedules`, `patient_documents`, `vaccinations` that the doctor has RLS access to.
- Speed Dial FAB consolidating New Visit / New Prescription / Add Lab Result / Quick Note.

### 2.3 Hospital portal dashboard + settings (1 day)
- 4 StatCards + recent activity table on the dashboard.
- Settings: hospital info form, notification toggles, departments CRUD.
- Email invite when a doctor is created (transactional email — Resend / SendGrid).

### 2.4 Lab portal PDF viewer + polish (½ day)
- Wire `pdfx` into `report_review_screen.dart`.
- Switch list screens to `HosDataTable`.

### 2.5 Push notifications (1 day) — fixes [ISSUE-006](03-known-issues.md)
- Implement the FCM dispatcher in the edge function.
- Wire FCM token registration on app start in each app.
- Foreground / background message handlers + tap → navigate.

---

## Stage 3 — DS consistency and quality pass (2 days)

Tracked in detail in [../pending.md](../pending.md). Highlights:

- Patient app Phase 1e: rebuild `profile_setup_screen.dart` as 3-step `HosStepIndicator`; family screen polish.
- Doctor app: replace remaining `Icons.*` with `HosIcons.*`; replace `CircularProgressIndicator` with `HosLoading`/skeletons; HosTimeline / HosSpeedDial on patient detail.
- Dark mode pass across every screen.
- `flutter analyze` to zero warnings (clean up the 4 pre-existing info-level lints).

---

## Stage 4 — Cross-cutting capabilities (1.5 days)

- Local push reminders for medications (`flutter_local_notifications` + `timezone`). Plan in [pending.md](../pending.md).
- Vaccination upcoming-due card on home feed.
- Typed exceptions in `packages/core` ([ISSUE-010](03-known-issues.md)) — bundled with whatever screens are being touched anyway.

---

## Stage 5 — QA & release prep (1 day)

- `flutter analyze` workspace-wide → zero warnings.
- Visit `/design` route in each app, verify gallery in light + dark.
- End-to-end smoke per spec:
  1. Patient: sign up → profile setup → home → book appointment → view lab report → grant doctor access.
  2. Doctor: login → select patient → create visit w/ vitals → create prescription → add quick note → view AI summary.
  3. Hospital admin: login → see dashboard stats → onboard doctor → verify doctor.
  4. Lab tech: login → upload report → review biomarkers → approve.
- 66 screenshots (33 screens × 2 themes) for PR review.

---

## Total estimate

| Stage | Days |
|---|---|
| 0 — Decisions | 0.5 |
| 1 — Blockers | 3.5 |
| 2 — Spec gaps | 4.5 |
| 3 — DS polish | 2 |
| 4 — Cross-cutting | 1.5 |
| 5 — QA | 1 |
| **Total** | **~13 days** |

Roughly 2.5 weeks for one engineer with no interruptions.

---

## What "done" looks like

- Every row in [01-current-state.md](01-current-state.md) is ✅.
- [03-known-issues.md](03-known-issues.md) has zero entries (the file still exists, but the "issue list" section is empty pending new findings).
- [02-pending-features.md](02-pending-features.md) has only P3/P4 items.
- The doc CHANGELOG shows a clean trail of fixes mapping to commits.

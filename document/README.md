# HealthOS — Project Documentation

**Last updated:** 2026-05-04
**Branch:** `feature/new-features`
**Maintainer protocol:** see [UPDATE-PROTOCOL.md](UPDATE-PROTOCOL.md). Every meaningful code change in `apps/`, `packages/`, or `supabase/migrations/` should be reflected here.

---

## What is this folder?

This is the **single source of truth** for the *current* state of the HealthOS codebase — what works, what is half-built, what is broken, and what comes next. The product spec lives in [../CLAUDE.md](../CLAUDE.md); this folder tells you how the implementation compares.

Read these in order:

| # | File | What it covers |
|---|------|----------------|
| 1 | [01-current-state.md](01-current-state.md) | Every feature the spec calls for, with a status (DONE / PARTIAL / BROKEN / TODO) and the file paths that prove it. |
| 2 | [02-pending-features.md](02-pending-features.md) | Work that is not yet started or is half-done, grouped by app and prioritised. |
| 3 | [03-known-issues.md](03-known-issues.md) | Concrete bugs, schema/model mismatches, and architectural mistakes that need to be fixed. Each issue has a fix plan. |
| 4 | [04-implementation-plan.md](04-implementation-plan.md) | The prioritised plan to get the project to "spec-complete". Sequenced so blockers come first. |
| 5 | [05-database-schema.md](05-database-schema.md) | Every migration, every table, and which Dart models are out of sync with the DB. |
| 6 | [06-architecture.md](06-architecture.md) | High-level architecture: monorepo layout, shared packages, auth chain, data flow. |
| 7 | [07-auth-system.md](07-auth-system.md) | Deep-dive into the current Firebase ↔ Supabase split-brain auth situation, why it's broken, and how to fix it. |

Per-app deep dives:

- [apps/patient-app.md](apps/patient-app.md)
- [apps/doctor-app.md](apps/doctor-app.md)
- [apps/hospital-portal.md](apps/hospital-portal.md)
- [apps/lab-portal.md](apps/lab-portal.md)

Process:

- [UPDATE-PROTOCOL.md](UPDATE-PROTOCOL.md) — how (and when) this folder must be updated.
- [CHANGELOG.md](CHANGELOG.md) — running log of doc updates and the code changes that prompted them.

---

## TL;DR — where the project is right now

- **Implementation:** ~75% of features have screens and providers. Maybe ~60% are end-to-end functional.
- **Database:** All required tables exist (including the recent `family_members`, `visit_vitals`, `doctor_notes`).
- **Auth:** **BROKEN.** AuthService was migrated from Supabase Auth to Firebase Auth, but the Supabase `patients.auth_id` column is still keyed against Supabase auth — so post-login profile lookups will fail. See [03-known-issues.md#auth-split-brain](03-known-issues.md) and [07-auth-system.md](07-auth-system.md).
- **Models out of sync with DB:** `Visit`, `Appointment` are missing fields that the DB columns and screens already use. See [05-database-schema.md](05-database-schema.md).
- **Push notifications:** edge function is a stub; FCM tokens are stored but nothing dispatches.
- **Hardcoded prod credentials** in every `main.dart`. See [03-known-issues.md](03-known-issues.md).

The four critical blockers are listed at the top of [04-implementation-plan.md](04-implementation-plan.md). Fix those first; everything else is polish.

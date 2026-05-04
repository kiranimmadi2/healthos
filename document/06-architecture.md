# 06 — Architecture

High-level shape of the codebase. Pair this with [07-auth-system.md](07-auth-system.md) for the auth deep-dive, and [05-database-schema.md](05-database-schema.md) for the data layer.

---

## Monorepo layout

Managed by **Melos** ([../melos.yaml](../melos.yaml)).

```
healthos/
├── apps/
│   ├── patient_app/       Flutter (mobile + web) — for patients
│   ├── doctor_app/        Flutter (tablet-first + web) — for doctors
│   ├── hospital_portal/   Flutter (web) — for hospital admins
│   └── lab_portal/        Flutter (web) — for lab technicians
├── packages/
│   ├── core/              Shared Freezed models, exceptions, utilities
│   ├── ui_kit/            Design system (15+ widgets, theme, icons facade)
│   ├── supabase_client/   Auth service + repositories around supabase_flutter
│   └── ai_client/         Gemini wrappers (symptom checker, AI summary)
├── supabase/
│   ├── migrations/        SQL migrations (see 05-database-schema.md)
│   └── functions/         Edge Functions (notifications, ai-service)
├── CLAUDE.md              Product spec
├── ARCHITECTURE.md        Detailed feature/UI specs (older, complementary)
├── pending.md             Working backlog (UI polish phases)
└── document/              ← THIS FOLDER (status & plan)
```

---

## App ↔ package dependency graph

All four apps depend on:

```
apps/*/pubspec.yaml
  ├── core              (models, exceptions)
  ├── ui_kit            (widgets, theme, HosIcons facade) — depends on core
  ├── supabase_client   (AuthService, repositories)       — depends on core
  └── ai_client         (Gemini calls)                    — depends on core (only patient_app + doctor_app use it)
```

Apps do not depend on each other. Each is a separate `flutter` project so they can ship independently.

---

## Runtime stack

| Layer | Tech |
|---|---|
| UI | Flutter 3.x, Material 3 |
| State | Riverpod 2 (`flutter_riverpod`) |
| Routing | `go_router` 14 with `ShellRoute` for the bottom-nav shell |
| Auth | **Currently:** Firebase Auth (`firebase_auth`, `google_sign_in`). **Should be:** Supabase Auth — see [07-auth-system.md](07-auth-system.md). |
| Data | Supabase Postgres + RLS + Storage + Realtime |
| AI | Gemini via the `ai_client` package |
| Push | Firebase Cloud Messaging (FCM) — tokens stored, dispatch is **stubbed** |
| Local notifications | Not yet wired (planned: `flutter_local_notifications`) |
| QR | `mobile_scanner` |
| Files | `file_picker` |

---

## Per-app shell pattern

Each app has the same skeleton:

```
lib/
├── main.dart                ← Firebase.init + Supabase.init + runApp(ProviderScope(MyApp))
└── src/
    ├── routing/
    │   ├── app_router.dart  ← GoRouter with auth-state redirect
    │   └── app_shell.dart   ← Scaffold with bottom nav / nav rail
    ├── providers/
    │   ├── auth_provider.dart       ← Stream<User?> from AuthService
    │   └── <domain>_provider.dart
    └── features/
        └── <feature>/
            ├── screens/
            └── providers/   (feature-local providers if needed)
```

**Routing redirect** — every app's router watches `authStateProvider` and the per-role profile provider, and redirects:
- Not authenticated → `/auth`
- Authenticated, profile missing → `/auth/setup` (patient) or `/account-not-found` (doctor)
- Authenticated, profile present → `/home` (or first nav destination)

This pattern is **logically correct** in [app_router.dart:50-76](../apps/patient_app/lib/src/routing/app_router.dart#L50-L76). It's the auth chain underneath that is broken — see [07-auth-system.md](07-auth-system.md).

---

## Data flow — read path

```
Screen
  └── ConsumerWidget reads someProvider
        └── Provider calls SomeRepository
              └── Repository wraps `Supabase.instance.client.from('table')...`
                    └── PostgREST (with RLS applied)
```

Every read goes through a repository in `packages/supabase_client/lib/src/repositories/`. Screens should not call Supabase directly; in practice a few do (e.g., `CreateVisitScreen` writes `visit_vitals` directly via the client). This is fine when the model layer doesn't need to round-trip the result, but bites us in [ISSUE-002](03-known-issues.md).

---

## Data flow — write path

Same shape. Writes typically use:
```dart
await client.from('table').insert(payload).select().single();
```
The returned row is parsed via `Model.fromJson(...)`. Any column the model doesn't know about is silently dropped — which is exactly how [ISSUE-002](03-known-issues.md) and [ISSUE-003](03-known-issues.md) hide.

---

## AI flow

```
Screen ── calls ── AiClient (in ai_client package)
                       └── HTTPS → Supabase Edge Function (functions/ai-service)
                                       └── Gemini API
```

The edge function is the only place the Gemini key lives.

---

## Notifications flow (intended)

```
DB event (insert into notifications)
  └── Edge Function (functions/notifications)
        ├── Look up FCM tokens from fcm_tokens
        ├── POST to FCM HTTP v1 API
        └── (foreground) clients update via Supabase Realtime subscription on notifications
```

Today only the in-app subscription side works; the FCM dispatch step is a stub. See [ISSUE-006](03-known-issues.md).

---

## Design system

`packages/ui_kit` exports:
- **Theme:** `AppTheme.light()`, `AppTheme.dark()`, plus `AppSpacing`, `AppTypography`, `AppBreakpoints`.
- **Icons facade:** `HosIcons.*` (Lucide-based) — replaces ad-hoc `Icons.*`.
- **Widgets (15+):** Skeleton, TabBar, StepIndicator, BottomSheet, DateField, DropdownField, MultiSelectChips, DataTable, Timeline, SpeedDial, VitalsCard, PrescriptionCard, LabReportCard, AppointmentCard, StatCard, plus extended `HosButton`, `HosIconButton`, `HosEmptyState`, `HosResponsiveGrid`, `HosNavShell`, `HosPageContainer`, `HosLoading`.
- **Design gallery:** `DesignGallery` mounted at `/design` in debug builds in each app.

Migration to the design system is **incomplete** — the doctor app still has many `Icons.*` and raw `CircularProgressIndicator` usages. Tracked in [pending.md](../pending.md).

---

## Build & tooling

- Workspace bootstrap: `melos bootstrap`
- Code generation: `dart run build_runner build --delete-conflicting-outputs` (per package that uses Freezed/JSON)
- Lint: `flutter analyze` from workspace root
- Migrations: `supabase db push` (for remote) / `supabase db reset` (for local dev)
- Edge functions: `supabase functions deploy <name>`

CI: `.github/workflows/` contains the Claude review workflows (made non-blocking in commit `2e13c66`).

---

## Conventions worth knowing

- All models are **immutable Freezed classes** with `@JsonKey(name: 'snake_case_db_column')` annotations.
- Repositories return models, never raw `Map<String, dynamic>`.
- Providers are typed (`AsyncValue<T>` or plain `T` where derivable).
- Screens are stateless `ConsumerWidget` where possible, `ConsumerStatefulWidget` only when local state is needed (e.g., form controllers).
- File reference convention in docs and code: `path/to/file.dart:lineNumber`.
- All migrations are **forward-only**; do not edit a previously-applied migration. Add a new one.

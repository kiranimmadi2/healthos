# Architecture

## Overview

HealthOS is a single Flutter application that selects a patient or doctor
portal after authentication. Code is organized by business feature, with
role-specific portals composing those features into complete user workspaces.

## Dependency Direction

```text
presentation -> application -> data
       |             |           |
       +----------> domain <------+

app -> feature public boundaries
feature presentation -> shared presentation
```

Rules:

- `domain/` contains models and domain constants.
- `data/` owns Firebase or external service calls.
- `application/` owns Riverpod providers and reactive composition.
- `presentation/` owns Flutter widgets, local UI state, and navigation.
- `app/` owns startup-wide routing and theme configuration.
- `shared/` must not import a business feature.

Feature barrel files such as `auth/auth.dart` and
`appointments/appointments.dart` define intentional public boundaries.
Internal feature files use direct imports so dependencies remain discoverable.

## Startup And Routing

```text
main()
  -> WidgetsFlutterBinding.ensureInitialized()
  -> Firebase.initializeApp()
  -> ProviderScope
  -> HealthOSApp
  -> routerProvider
```

`routerProvider` watches `authStateProvider`:

1. Signed-out users are redirected to `/login`.
2. Signed-in users are redirected away from `/login` to `/`.
3. `RootScreen` watches `userRoleProvider`.
4. A `patient` role opens `PatientHomeScreen`.
5. A `doctor` role opens `DoctorHomeScreen`.
6. A missing role opens `ProfileSetupScreen`.

The route paths and redirect behavior are defined in
`lib/src/app/routing/app_router.dart`.

## Request And Data Flow

Firestore-backed features follow the same request path:

```text
Widget
  -> reads/watches Riverpod provider
  -> provider resolves signed-in user and repository
  -> repository reads or writes Firestore
  -> repository maps snapshots to domain models
  -> provider emits AsyncValue/Stream state
  -> widget rebuilds
```

Current Firestore contracts:

```text
users/{uid}
users/{uid}/records/{recordId}
appointments/{appointmentId}
chats/{patientId_doctorId}
chats/{patientId_doctorId}/messages/{messageId}
```

Repositories preserve the existing collection names, field names, sorting,
and denormalized values.

## State Flow

### Global Reactive State

Riverpod providers own app-wide and server-backed state:

- `authStateProvider`: Firebase authentication stream.
- `userProfileProvider`: signed-in user's Firestore profile.
- `userRoleProvider`: role used by root routing.
- `patientAppointmentsProvider`: patient appointment stream.
- `doctorAppointmentsProvider`: doctor appointment stream.
- `nextAppointmentProvider`: derived upcoming appointment.
- `availableDoctorsProvider`: available doctor stream.
- `medicalRecordsProvider`: patient record stream.
- `chatThreadsProvider`: participating chat threads.
- `chatMessagesProvider`: messages for one chat thread.

### Local UI State

Widget state remains local when it is temporary and presentation-specific:

- selected portal destination
- search and filter values
- form controllers and validation
- dialog/sheet visibility
- temporary doctor demo workspace interactions

Local state does not write to Firestore unless it calls a feature repository
through its Riverpod provider.

## AI Triage Flow

```text
AITriageScreen
  -> reads userProfileProvider
  -> reads aiServiceProvider
  -> AIService builds patient context and prompt
  -> Gemini model returns plain-text guidance
  -> screen appends the response to local chat state
```

The AI feature is isolated under `features/ai_triage`. Its presentation does
not construct external clients directly.

## Component Hierarchy

```text
HealthOSApp
`-- GoRouter
    |-- LoginScreen
    `-- RootScreen
        |-- ProfileSetupScreen
        |-- PatientHomeScreen
        |   `-- HealthShell
        |       |-- DashboardContent
        |       |-- DoctorListScreen
        |       |-- RecordsScreen
        |       `-- AITriageScreen
        `-- DoctorHomeScreen
            `-- HealthShell
                |-- DoctorDashboard
                |-- PatientsWorkspace
                |-- ScheduleWorkspace
                |-- MessagesWorkspace
                `-- ReportsWorkspace
```

`HealthShell`, `HealthPage`, responsive layout helpers, branding, and status
widgets live in `shared/presentation`.

## Business Domains

- Authentication: sign-in, sign-up, Google authentication, sign-out.
- User profiles: onboarding data and role resolution.
- Appointments: booking, status updates, patient and doctor views.
- Doctors: available doctor discovery and profile display.
- Records: patient-owned medical record storage.
- Chat: deterministic patient-doctor threads and messages.
- AI triage: profile-aware health guidance.
- Patient portal: patient navigation and dashboard composition.
- Doctor portal: doctor navigation and workspace composition.

## Doctor Demo Workspace

The doctor portal currently uses local fixture models and data for workspace
screens. They are explicitly isolated in `doctor_portal/demo` so future agents
do not confuse them with Firestore domain models or production repositories.

## Known Manual Review

- `features/ai_triage/data/ai_service.dart` currently contains a client-side
  Gemini API key. It was not moved to a server or environment loader because
  that would change runtime behavior. Rotate the exposed key and introduce a
  secure gateway as a separate behavior-changing task.
- The existing 390 px doctor dashboard widget test reports a RenderFlex
  overflow in the hero appointment row. Its UI code was moved unchanged during
  this refactor; resolving it requires a responsive layout change.

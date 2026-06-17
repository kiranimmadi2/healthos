# HealthOS

HealthOS is a Flutter application with role-based patient and doctor
workspaces. It uses Firebase for authentication and data storage, Riverpod for
dependency injection and reactive state, GoRouter for navigation, and Gemini
for AI-assisted patient triage.

## Technology

- Flutter and Dart
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Riverpod
- GoRouter
- Google Generative AI

## Repository Map

```text
lib/
|-- main.dart                  # Firebase initialization and app bootstrap
|-- firebase_options.dart      # Generated Firebase platform configuration
`-- src/
    |-- app/                   # App widget, router, and theme
    |-- features/              # Business and role-based feature modules
    `-- shared/                # Feature-independent presentation primitives

test/                          # Widget and integration-facing tests
assets/                        # Bundled application assets
android/, ios/, web/, ...      # Flutter platform runners
tool/                          # Developer utilities
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for runtime flow and dependency rules,
and [FOLDER_STRUCTURE.md](FOLDER_STRUCTURE.md) for detailed folder ownership.

## Getting Started

### Prerequisites

- Flutter with Dart 3.10 or newer
- A configured Firebase project
- Platform-specific Flutter tooling for the target device

### Install

```powershell
flutter pub get
```

The generated `lib/firebase_options.dart` file is required at runtime. Follow
[FIREBASE_SETUP.md](FIREBASE_SETUP.md) when configuring a new environment.

### Run

```powershell
flutter run
```

For web development:

```powershell
flutter run -d chrome
```

## Verification

```powershell
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Development Rules

- Preserve Firestore collection names and document fields.
- Keep feature dependencies flowing through each feature's barrel file or a
  specific application/domain module.
- Keep Firebase access in `data/` repositories.
- Keep Riverpod composition in `application/`.
- Keep widgets and navigation concerns in `presentation/`.
- Do not add cross-feature imports to another feature's internal `data/`
  implementation.

See [CONTRIBUTING.md](CONTRIBUTING.md) before making structural changes.

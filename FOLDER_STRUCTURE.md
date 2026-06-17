# Folder Structure

## Top Level

```text
.
|-- lib/                 # Authored Dart application code
|-- test/                # Automated tests
|-- assets/              # Bundled images and other runtime assets
|-- tool/                # Developer scripts
|-- android/             # Android runner and native configuration
|-- ios/                 # iOS runner and native configuration
|-- linux/               # Linux runner
|-- macos/               # macOS runner
|-- web/                 # Web runner and manifest
`-- windows/             # Windows runner
```

Platform folders should contain only platform integration and generated plugin
registration. Business logic belongs under `lib/src`.

## Application Code

```text
lib/
|-- main.dart
|-- firebase_options.dart
`-- src/
    |-- app/
    |   |-- health_os_app.dart
    |   |-- routing/
    |   `-- theme/
    |-- features/
    |   |-- ai_triage/
    |   |-- appointments/
    |   |-- auth/
    |   |-- chat/
    |   |-- doctor_portal/
    |   |-- doctors/
    |   |-- patient_portal/
    |   `-- records/
    `-- shared/
        `-- presentation/
            |-- branding/
            |-- layout/
            |-- shell/
            `-- widgets/
```

## Folder Responsibilities

### `app/`

Application-wide composition only:

- root `MaterialApp`
- routing and role selection
- theme tokens and `ThemeData`

It may import feature public boundaries. Features must not import app routing.

### `features/<feature>/domain/`

Business data structures and constants for one feature. Domain files may use
SDK or serialization types required by the current contract, but must not
depend on Flutter widgets or another feature's presentation.

### `features/<feature>/data/`

External system implementations:

- Firestore repositories
- authentication adapters
- AI service clients

Collection paths, field names, and external request behavior belong here.

### `features/<feature>/application/`

Riverpod providers and derived state. This layer connects authenticated user
state, repositories, and domain models without rendering UI.

### `features/<feature>/presentation/`

Screens, widgets, forms, local interaction state, and feature navigation.
Presentation code obtains dependencies through providers rather than creating
Firebase clients.

### Feature Barrel Files

Files such as `features/chat/chat.dart` export the supported cross-feature
surface. Add an export only when another feature or `app/` legitimately needs
that symbol.

### `doctor_portal/demo/`

Local fixture data and view models used by the current doctor workspace. This
folder is not a database layer and must not be imported by other business
features.

### `patient_portal/` And `doctor_portal/`

Role-specific composition. Portals own destination selection and assemble
feature screens, but reusable business operations stay in their domain
features.

### `shared/presentation/`

Feature-independent UI primitives:

- branding assets
- responsive layout helpers
- application shell widgets
- small reusable visual components

Shared code must not import from `features/`.

## Naming Conventions

- Dart files and folders: `snake_case`
- Types and widgets: `UpperCamelCase`
- Variables, methods, and providers: `lowerCamelCase`
- Provider names: end in `Provider`
- Repositories: `<Domain>Repository`
- Screens: `<Purpose>Screen`
- Portal workspaces: `<Purpose>Workspace`
- Public feature boundary: `<feature>.dart`

Name files after their primary public type or responsibility. A file should
not mix repositories, providers, models, and widgets.

# Contributing

## Before Editing

1. Read `ARCHITECTURE.md` and `FOLDER_STRUCTURE.md`.
2. Check `git status` and preserve unrelated working-tree changes.
3. Identify the owning feature and layer before adding code.
4. Record existing behavior with tests when changing a risky path.

## Dependency Rules

- UI reads dependencies from Riverpod providers.
- Providers construct and compose repositories.
- Repositories own Firebase and external service calls.
- Domain models own serialization required by their feature.
- Shared presentation code never imports a feature.
- Cross-feature imports use a feature barrel or a specific domain/application
  file, never another feature's internal data implementation.
- Avoid barrel imports from inside the same feature to prevent import cycles.

## Behavior Preservation

Refactors must not change:

- route paths or redirect rules
- Firestore collection names, document paths, or fields
- authentication behavior
- provider names or lifecycle semantics
- model defaults or serialization
- visible copy, layout, styling, gestures, or navigation
- AI prompts, model names, or response handling

When moving code, move it first, update imports, format, and verify before
performing additional cleanup.

## Adding A Feature

Use only the folders the feature needs:

```text
features/example/
|-- example.dart
|-- application/
|-- data/
|-- domain/
`-- presentation/
```

Do not create empty architectural layers. Keep the barrel limited to symbols
that are intentionally consumed outside the feature.

## Testing

Run before submitting:

```powershell
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Add focused tests when changing:

- provider-derived state
- repository mapping or sorting
- model serialization
- route redirects
- forms, dialogs, and user-visible interactions
- responsive layouts

## Documentation

Update architecture documentation when:

- a feature or layer is introduced
- dependency direction changes
- a new external service or persistence path is added
- navigation or state ownership changes

Comments should explain non-obvious constraints or decisions. Do not narrate
straightforward code.

## AI Agent Checklist

Before completing a task:

1. Search for all references to moved or renamed symbols.
2. Confirm no stale imports or duplicate implementations remain.
3. Inspect changed Firestore strings and serialized maps.
4. Run formatting, analysis, and tests.
5. Summarize behavior impact explicitly.
6. Call out verification that could not be completed.

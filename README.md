# HealthOS

AI-powered unified health platform with patient, doctor, hospital, and lab portals.

## Tech Stack

- **Frontend:** Flutter (Dart) — Riverpod + GoRouter
- **Backend:** Supabase (PostgreSQL, Edge Functions, Auth, Storage, Realtime)
- **AI:** Claude API (Anthropic) via Edge Functions
- **Push Notifications:** Firebase Cloud Messaging
- **Monorepo:** Melos

## Project Structure

```
healthos/
├── apps/
│   ├── patient_app/       # Flutter mobile (iOS + Android + Web)
│   ├── doctor_app/        # Flutter tablet-first app
│   ├── hospital_portal/   # Flutter Web admin dashboard
│   └── lab_portal/        # Flutter Web report upload
├── packages/
│   ├── core/              # Shared models, constants, utilities
│   ├── ui_kit/            # Design system components
│   ├── supabase_client/   # Database query layer
│   └── ai_client/         # Edge Function HTTP client
├── supabase/
│   ├── migrations/        # SQL schema migrations
│   ├── functions/         # Deno Edge Functions
│   └── seed.sql           # Development test data
├── .github/workflows/     # CI/CD pipelines
```

## Getting Started

### Prerequisites

- Flutter SDK 3.24+
- Dart SDK 3.2+
- Melos (`dart pub global activate melos`)
- Supabase CLI

### Setup

```bash
# Clone the repository
git clone <repo-url> healthos
cd healthos

# Install dependencies
melos bootstrap

# Generate code (freezed models, json_serializable)
melos run build_runner

# Start local Supabase
supabase start

# Run the patient app
cd apps/patient_app
flutter run
```

### Environment Variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

## Development

```bash
# Run all tests
melos run test

# Run static analysis
melos run analyze

# Format code
melos run format

# Generate code after model changes
melos run build_runner
```

## Architecture

- **Feature-based structure:** Each feature has data/domain/presentation layers
- **Repository pattern:** All DB access through typed repositories
- **RLS everywhere:** Row-Level Security on every table
- **AI gateway:** Edge Functions proxy all AI calls (API key never on client)
- **Freezed models:** Immutable data classes with JSON serialization

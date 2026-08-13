# HealthOS: Firebase & Google Setup Guide

To bring the HealthOS architecture to life and run the app, you need to connect the codebase to a real Firebase project. Follow these steps when you are ready to configure the backend.

## Step 1: Create the Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name it "HealthOS".
3. **Important:** To use Gemini AI (Vertex AI), you must upgrade your project to the **Blaze (pay-as-you-go) plan**. Go to the bottom left of the Firebase console and click "Upgrade". *(Development usage is usually free under the generous free tier, but a billing account must be linked).*

## Step 2: Connect the Flutter App (`firebase_options.dart`)
We use the official Firebase CLI tool to securely link the app without manually managing `.json` files.
1. Open your local terminal in the project folder.
2. Run this command to log in to Firebase:
   ```bash
   firebase login
   ```
3. Run these commands to automatically configure your app:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   *Follow the prompts in the terminal: select your HealthOS project, and select the platforms you want to support (Android, iOS, Web).* This generates the `lib/firebase_options.dart` file.

## Step 3: Enable Authentication

1. In the Firebase Console, go to **Build > Authentication** -> **Get Started**.
2. Go to the **Sign-in method** tab.
3. Enable **Email/Password**.
4. Enable **Google** (it will ask for a support email).
5. Enable **Phone**.

### 3a. Register SHA fingerprints (required for Android)

Google Sign-In needs these. Phone auth needs them too — without them Play
Integrity cannot attest the request and sign-in fails with
`missing-client-identifier`.

```bash
cd android
./gradlew signingReport
```

Register **both** SHA-1 and SHA-256, for **both** the debug and release
variants, under **Project Settings > Your apps > Android > Add fingerprint**.

> Registering only the release fingerprint is the usual mistake.
> `android/app/build.gradle.kts` falls back to the **debug** signing config when
> `key.properties` is absent, so a local `flutter run --release` is signed with
> the debug key and will fail phone auth unless that fingerprint is registered
> too.

Re-download `google-services.json` afterwards and place it in `android/app/`.
It is gitignored, so every machine needs its own copy.

### 3b. Enable Play Integrity (Android)

In Google Cloud Console, enable the **Play Integrity API** for the project.
Without it Firebase falls back to a reCAPTCHA web-view interstitial mid-flow,
which works but looks broken.

### 3c. Authorised domains (web)

Phone auth on web uses an invisible reCAPTCHA that the SDK renders itself — no
code required. Add your hosting domain under **Authentication > Settings >
Authorized domains** (`localhost` is there by default).

### 3d. Test phone numbers (development)

**Authentication > Sign-in method > Phone > Phone numbers for testing.**

Add a number and a fixed code, e.g. `+1 650-555-3434` / `123456`. That number
then signs in without sending a real SMS.

This is the *only* supported way to skip SMS during development. It is enforced
by Firebase, scoped to numbers you list, and inert in production — unlike the
previous hardcoded `123456` bypass, which accepted that code for **any**
account in **release** builds. Do not reintroduce a client-side shortcut;
`test/phone_auth_test.dart` fails the build if one appears.

### 3e. Cost note

SMS is metered and per-project quotas apply. If you only need passwordless
sign-in for a demo, email/password plus Google is free and needs none of the
setup above.

### 3f. Migrating accounts from the retired email-code flow

Earlier builds had an "Email OTP" mode whose Firebase password was derived from
the email address, so those users have a password they have never seen. They
cannot sign in via the Password tab.

The sign-in screen detects this (the `emailLink` entry in `authProviders`) and
offers **"Set a password for this account"**, which sends a normal reset email.
Google sign-in also still works for them. No admin action is needed.

## Step 4: Enable Firestore Database
1. In the Firebase Console, go to **Build > Firestore Database**.
2. Click **Create database**.
3. Choose **Start in test mode** for now (we will add secure production rules later).

## Step 5: Enable Vertex AI (Gemini)
1. In the Firebase Console, go to **Build > Vertex AI**.
2. Click **Enable**.

---

**Next Steps Once Setup is Complete:**
After you finish these steps, let the AI know. The next coding tasks will be:
1. Uncommenting Firebase initialization in `lib/main.dart` to use the new `firebase_options.dart` file.
2. Building the Doctor Selection and Appointment Booking flows.

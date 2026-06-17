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

## Step 3: Enable Authentication & Add SHA-1 (For Google Sign-In)
1. In the Firebase Console, go to **Build > Authentication** -> **Get Started**.
2. Go to the **Sign-in method** tab.
3. Enable **Email/Password**.
4. Enable **Google** (It will ask for a support email).
5. **CRITICAL FOR ANDROID:** To make Google Sign-In work on Android, you must add your SHA-1 key to Firebase.
   - In your terminal, navigate to the android folder: `cd android`
   - Run the signing report: `./gradlew signingReport`
   - Copy the `SHA1` string listed under the `debug` variant.
   - In the Firebase Console, go to **Project Settings** (gear icon top left) -> Scroll down to your Android App -> Click **Add fingerprint** and paste the SHA-1.

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

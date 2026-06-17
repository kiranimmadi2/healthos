# HealthOS — Wearable & Smart Device Integration Plan

How to connect **every major smartwatch and health sensor** (Apple Watch, Wear OS / Pixel Watch, Samsung Galaxy Watch, Fitbit, Garmin, Xiaomi/Amazfit, BLE heart-rate straps, pulse oximeters, smart BP monitors) to HealthOS and read their health parameters.

> **Status:** Plan only — nothing is implemented yet. Follow the phases below when ready.

---

## 1. The Big Idea: connect 2 health stores, not 20 watch brands

You never talk to a watch directly. Every brand already syncs its data into a **platform health store** on the phone. HealthOS reads from that store with the user's permission:

```
┌─────────────┐   ┌──────────────┐   ┌────────────────┐   ┌──────────┐
│ Apple Watch │ → │ Apple Health │ → │                │   │          │
│ Galaxy Watch│ → │ Samsung Hlth │ → │  health (pub)  │ → │ HealthOS │
│ Pixel Watch │ → │ Health       │ → │  Flutter       │   │ Firestore│
│ Fitbit      │ → │ Connect      │ → │  plugin        │   │ Dashboard│
│ Garmin      │ → │ (Android)    │ → │                │   │ AI Triage│
└─────────────┘   └──────────────┘   └────────────────┘   └──────────┘
```

- **iOS** → **HealthKit** (the "Apple Health" app). Apple Watch writes to it automatically.
- **Android** → **Health Connect** (built into Android 14+, free Play Store app on Android 9–13). Every brand's companion app writes into it.
- **One Flutter package reads both:** [`health`](https://pub.dev/packages/health)

### Device connection matrix — what the user does, once

| Device | User setup (one time) | Then data flows to HealthOS via |
|---|---|---|
| **Apple Watch** | Nothing — pairs with iPhone, writes to Apple Health automatically | HealthKit |
| **Pixel Watch / any Wear OS** | Install Fitbit (or Google Fit) app → enable "Sync with Health Connect" | Health Connect |
| **Samsung Galaxy Watch** | Samsung Health app → Settings → Health Connect → turn on sharing | Health Connect |
| **Fitbit (Versa, Charge, Sense…)** | Fitbit app → Settings → Health Connect → enable | Health Connect |
| **Garmin (all watches)** | Garmin Connect app → Settings → Health Connect → enable | Health Connect |
| **Xiaomi / Amazfit / Mi Band** | Zepp or Mi Fitness app → Health Connect sharing on | Health Connect |
| **Huawei** | Huawei Health doesn't support Health Connect directly → user installs the "Health Sync" bridge app | Health Connect |
| **BLE chest strap (Polar H10, etc.), finger pulse oximeter, smart BP cuff** | No companion app needed — HealthOS connects directly over Bluetooth | Direct BLE (Phase 6) |

In the app, the **"Connect device" screen** (Phase 3) shows these instructions per brand, then asks for permission once. After that, sync is automatic.

---

## 2. Health parameters you can read

| Parameter | HealthDataType (health package) | Apple Watch | Wear OS/Samsung/Fitbit/Garmin | BLE sensor |
|---|---|---|---|---|
| Heart rate (bpm) | `HEART_RATE` | ✅ continuous | ✅ continuous | ✅ live stream |
| Resting heart rate | `RESTING_HEART_RATE` | ✅ | ✅ | — |
| Heart rate variability | `HEART_RATE_VARIABILITY_SDNN` / `_RMSSD` | ✅ | ✅ most | — |
| Steps | `STEPS` | ✅ | ✅ | — |
| Blood oxygen (SpO2 %) | `BLOOD_OXYGEN` | ✅ (Series 6+) | ✅ most | ✅ oximeter |
| Blood pressure | `BLOOD_PRESSURE_SYSTOLIC` / `_DIASTOLIC` | via paired BP cuff | ✅ Samsung BP watches / cuff | ✅ smart cuff |
| Sleep (duration & stages) | `SLEEP_SESSION` (Android) / `SLEEP_ASLEEP` (iOS) | ✅ | ✅ | — |
| Active calories | `ACTIVE_ENERGY_BURNED` | ✅ | ✅ | — |
| Body temperature | `BODY_TEMPERATURE` | ✅ (Series 8+) | ✅ some | ✅ smart thermometer |
| Blood glucose | `BLOOD_GLUCOSE` | via CGM apps | via CGM apps | ✅ some meters |
| Weight / BMI | `WEIGHT` | via smart scale | via smart scale | ✅ smart scale |
| ECG | `ELECTROCARDIOGRAM` (iOS only in plugin) | ✅ | brand-app only | ✅ Polar H10 raw |

**Recommended starter set for HealthOS:** heart rate, steps, SpO2, blood pressure, sleep, active calories — these power the dashboard card and AI triage.

---

## 3. Implementation phases

### Phase 1 — Foundation (deps + permissions + platform config)

**1a. Add the package**

```powershell
flutter pub add health
```

**1b. Android — [build.gradle.kts](android/app/build.gradle.kts):** Health Connect needs minSdk 26:

```kotlin
minSdk = maxOf(26, flutter.minSdkVersion)
```

**1c. Android — [MainActivity.kt](android/app/src/main/kotlin/com/roop/HealthOS/MainActivity.kt):** the plugin's permission flow needs `FlutterFragmentActivity`:

```kotlin
package com.roop.HealthOS

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

**1d. Android — [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml):** add inside `<manifest>` (before `<application>`):

```xml
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_BLOOD_PRESSURE"/>
<uses-permission android:name="android.permission.health.READ_OXYGEN_SATURATION"/>
<uses-permission android:name="android.permission.health.READ_SLEEP"/>
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED"/>
```

Inside the `MainActivity` `<activity>` tag, add a second intent filter (permission rationale, Android ≤13):

```xml
<intent-filter>
    <action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE"/>
</intent-filter>
```

After `</activity>`, add the Android 14+ rationale alias:

```xml
<activity-alias
    android:name="ViewPermissionUsageActivity"
    android:exported="true"
    android:targetActivity=".MainActivity"
    android:permission="android.permission.START_VIEW_PERMISSION_USAGE">
    <intent-filter>
        <action android:name="android.intent.action.VIEW_PERMISSION_USAGE"/>
        <category android:name="android.health.connect.category.HEALTH_PERMISSIONS"/>
    </intent-filter>
</activity-alias>
```

And inside the existing `<queries>` block:

```xml
<package android:name="com.google.android.apps.healthdata"/>
```

**1e. iOS — [Info.plist](ios/Runner/Info.plist):** add usage strings:

```xml
<key>NSHealthShareUsageDescription</key>
<string>HealthOS reads your heart rate, steps, blood pressure, oxygen saturation and sleep from Apple Health to show your vitals and personalize care guidance.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>HealthOS can save health measurements you record in the app to Apple Health.</string>
```

⚠️ **iOS also needs the HealthKit capability** enabled in Xcode (Signing & Capabilities → + HealthKit). This requires a **Mac**. Since the dev machine is Windows: **build Android first**, do iOS later via a Mac or Codemagic CI.

**1f. New model — `lib/src/models/vitals.dart`** (plain-class style, like [models.dart](lib/src/models/models.dart)):

```dart
class VitalsSummary {
  final double? heartRateAvg;   // bpm
  final int? steps;
  final double? systolic;       // mmHg
  final double? diastolic;      // mmHg
  final double? spo2;           // %
  final double? sleepHours;
  final double? activeCalories; // kcal
  final DateTime? lastSynced;
  final String source;          // 'Health Connect' | 'Apple Health' | 'BLE'
  // + toMap() / fromMap() for Firestore
}
```

### Phase 2 — Health service + Firestore sync

**New `lib/src/services/health_service.dart`** (same style as [ai_service.dart](lib/src/services/ai_service.dart), exposed via Riverpod):

```dart
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  static const _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_SESSION,        // SLEEP_ASLEEP on iOS
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  /// Wearable APIs exist only on phones.
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
       defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> requestPermissions() async {
    await _health.configure();
    return await _health.requestAuthorization(_types);
  }

  Future<List<HealthDataPoint>> fetchLast24h() async {
    final now = DateTime.now();
    final points = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: now.subtract(const Duration(hours: 24)),
      endTime: now,
    );
    return _health.removeDuplicates(points);
  }
  // then aggregate points into a VitalsSummary (avg HR, total steps, ...)
}
```

**New `lib/src/features/health/health_repository.dart`** — Firestore writes (follow [user_repository.dart](lib/src/features/auth/user_repository.dart) pattern):

- `users/{uid}/vitals/{yyyy-MM-dd}` → one **daily summary doc** (cheap reads, no per-sample spam)
- `users/{uid}.latestVitals` → snapshot map for instant dashboard load
- Providers: `healthServiceProvider`, `latestVitalsProvider` (Firestore stream), `vitalsSyncProvider` (silent re-sync on app open if permission already granted)

**Firestore security rule:**

```
match /users/{uid}/vitals/{day} {
  allow read, write: if request.auth.uid == uid;
}
```

### Phase 3 — UI

- **[dashboard_content.dart](lib/src/features/patient/dashboard_content.dart):** replace the 3 hardcoded values in `_HealthSummaryCard` (72 bpm / 118/76 / 6,420 steps) with `latestVitalsProvider` data. When no device is connected → show a "Connect a device" button instead.
- **New `lib/src/features/health/connect_device_screen.dart`:** per-brand setup instructions (matrix from §1), "Connect & sync" button → `requestPermissions()` → first sync → show last-synced time. Route `/connect-device` in [router.dart](lib/src/core/router.dart).

### Phase 4 — AI triage with real vitals

In [ai_service.dart](lib/src/services/ai_service.dart) `_patientContext()`, append the latest vitals (they'll already be in the user doc as `latestVitals`, which `userProfileProvider` returns):

```
Recent vitals (from wearable):
- Avg heart rate: 76 bpm
- Blood pressure: 118/76
- SpO2: 98%
- Steps yesterday: 6,420
- Sleep: 6.5 h
```

Gemini then triages with real signals (e.g. chest pain + HR 130 → EMERGENCY weighting).

### Phase 5 — Background sync

1. Start simple: sync on app open (already covers most use).
2. Add [`workmanager`](https://pub.dev/packages/workmanager) for Android periodic sync every 4–6 h; iOS `BGAppRefreshTask` best-effort.

### Phase 6 — Direct BLE sensors (rare/generic devices)

For sensors with **no phone ecosystem** (chest straps, finger oximeters, smart BP cuffs), connect directly with [`flutter_blue_plus`](https://pub.dev/packages/flutter_blue_plus) using **standard Bluetooth GATT services** — any compliant device works, regardless of brand:

| Sensor | GATT Service UUID | Characteristic |
|---|---|---|
| Heart rate strap | `0x180D` Heart Rate | `0x2A37` HR Measurement (live notify stream) |
| Pulse oximeter | `0x1822` PLX | `0x2A5E` SpO2 spot-check |
| Blood pressure cuff | `0x1810` Blood Pressure | `0x2A35` BP Measurement |
| Thermometer | `0x1809` Health Thermometer | `0x2A1C` Temperature |
| Smart scale | `0x181D` Weight Scale | `0x2A9D` Weight |

Flow: scan for those service UUIDs → user taps their device → subscribe to notifications → live readings on screen → save to the same `vitals` collection. Requires Bluetooth permissions (`BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT` on Android 12+, `NSBluetoothAlwaysUsageDescription` on iOS).

---

## 4. Testing without a real watch

1. Android emulator (API 34+) → install **Health Connect Toolbox** (Google's test app) → inject fake heart rate / steps / sleep.
2. Run HealthOS → Connect device → grant permissions → verify: dashboard shows injected values → Firestore `users/{uid}/vitals` doc created → AI triage prompt includes the vitals.
3. Real device test: any phone + any watch from the matrix in §1.
4. Web/desktop: `isSupported == false` → dashboard shows "Available on mobile" gracefully, no crash.

---

## 5. Notes & cautions

- **Privacy/compliance:** vitals are sensitive health data — lock down Firestore rules (§ Phase 2), collect only the types you display, and write a privacy policy before Play Store / App Store review (both stores audit health permissions).
- **Play Store:** apps using Health Connect must declare the health permissions in the Play Console data-safety form and justify each one.
- **Existing issue to fix while touching `ai_service.dart`:** the Gemini API key is hardcoded in source — move it to `--dart-define` or Firebase Remote Config and rotate the exposed key.
- **iOS leg requires a Mac** for the HealthKit entitlement; everything else in this plan works from Windows.

## 6. Suggested order of work

| Step | Effort | Outcome |
|---|---|---|
| Phase 1 + 2 (Android only) | ~1–2 days | Real vitals syncing to Firestore |
| Phase 3 | ~1 day | Live dashboard + connect screen |
| Phase 4 | ~½ day | AI triage uses real vitals |
| Phase 5 | ~½ day | Auto background sync |
| iOS enablement (needs Mac) | ~½ day | Apple Watch support |
| Phase 6 (BLE) | ~2–3 days | Generic sensors, live HR streaming |

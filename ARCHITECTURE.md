# HealthOS — Simplified AI Health Platform

## 1. System Overview
HealthOS is a unified health platform using a single Flutter app for both Patients and Doctors, powered by Firebase and Google's Gemini AI.

## 2. Tech Stack
- **Frontend:** Flutter
- **State Management:** Riverpod
- **Routing:** GoRouter (Role-based)
- **Backend:** Firebase (Auth, Firestore, Storage)
- **AI:** Gemini 1.5 via Vertex AI for Firebase

## 3. Data Requirements (Onboarding)
### Mandatory
- **Role:** Patient or Doctor
- **Full Name**
- **Email:** Verified via Google or Email/Password
- **DOB (Patients):** Required for clinical context
- **Gender (Patients):** Required for clinical context

### Optional
- **Height (cm)**
- **Weight (kg)**

## 4. Features (MVP)
- **AI Triage:** Patient symptom checker using Gemini 1.5 Flash.
- **Clinical Records:** Doctor dashboard to view patient history and AI-generated summaries.
- **Appointments:** Simple booking flow between patients and doctors.

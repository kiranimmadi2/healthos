# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## HealthOS App Overview

HealthOS is an **AI-powered unified health platform** that connects patients, doctors, hospitals, and labs in a single ecosystem. Four separate Flutter apps serve different user types, all sharing a common database and real-time capabilities via Supabase.

---

## User Types & Apps

### 1. **Patient App** (Mobile + Web)
**Target:** Individual patients managing their own health and family members

**Core Flows:**
- Register via phone OTP, email OTP, or Google
- Create personal health profile (name, DOB, phone, allergies, chronic conditions)
- View own health records (appointments, visits, prescriptions, lab reports)
- Use AI symptom checker to get triage recommendations
- Manage family members (spouse, children, parents, etc.)
- Book appointments for self or family members
- Receive notifications when doctors add new information
- View health summary and timeline

**Key Screens:**
- **Home** — Health ID card, upcoming appointments, family health quick card, notifications
- **Records** — Visits, prescriptions, lab reports, biomarkers in timeline view
- **Symptoms AI** — Describe symptoms → AI generates triage level + recommendations
- **Profile** — Personal info, medical history (allergies, conditions), emergency contact, family members
- **Family Hub** — Add family members (3-step form), manage permissions, book appointments for them

**Data Shown to Patient:**
- ✅ Own health ID, demographics, profile photo
- ✅ Own allergies, chronic conditions, blood type
- ✅ Visits (chief complaint, diagnosis, follow-up date)
- ✅ Visit vitals (BP, HR, temperature, weight, height, SpO2)
- ✅ Prescriptions (medications, dosage, instructions)
- ✅ Lab reports (test results, biomarkers, normal ranges)
- ✅ Appointments (scheduled date/time, doctor, status)
- ✅ Doctor notes marked as "shared" (not private notes)
- ✅ Family members' appointments and basic health info (if granted permission)
- ❌ Cannot see private doctor notes
- ❌ Cannot see doctors' internal clinical notes

---

### 2. **Doctor App** (Tablet-First + Web)
**Target:** Doctors viewing patients they have access to and creating clinical records

**Core Flows:**
- Register via phone OTP or Google
- Hospital admin pre-creates doctor profile (phone, specialization, hospital)
- View list of patients who granted access
- Create/view visits with vital signs and clinical notes
- Add prescription records
- Add lab results manually (for manual entry, not just file uploads)
- Take private notes on patients (not visible to patient by default)
- Share clinical notes with patients if needed
- View patient AI health summary
- Update patient allergies/conditions (doctor authority)

**Key Screens:**
- **Patient List** — Patients who granted access, search by name/health ID
- **Patient Detail** — Demographics, allergies (editable), conditions (editable), upcoming appt badge
  - Speed Dial FAB with options: New Visit, New Prescription, Add Lab Result, Quick Note
  - Tabs: Visits | Labs | Prescriptions | Notes
- **Create Visit** — Chief complaint, visit type, vital signs (BP, HR, temp, weight, height, SpO2), examination findings, diagnosis, ICD-10 code, treatment plan, follow-up date, triage level
- **Add Lab Result** — Test date, lab name, multiple test entries (test name, value, unit, reference range), notes
- **Quick Note** — Freeform text, toggle between private/shared with patient
- **Patient Medical History Edit** — Modify allergies and chronic conditions (doctor has clinical authority)
- **Health Summary** — AI-generated overview of patient's health status, key findings, risk factors, recommendations

**Data Shown to Doctor:**
- ✅ Patient full profile (name, age, blood type, contact)
- ✅ Allergies and chronic conditions (can edit)
- ✅ All visits created by this doctor or others
- ✅ All prescriptions
- ✅ All lab reports and biomarkers
- ✅ Upcoming appointments
- ✅ Their own notes (private and shared)
- ✅ Family members (if patient has any)
- ❌ Cannot see other doctors' patients unless access granted
- ❌ Cannot modify patient personal demographics (name, DOB)

**Data Links:**
- When doctor creates a **visit**, it stores:
  - Chief complaint, diagnosis, examination findings, notes, visit_type, follow_up_date, icd_code
  - Separately in **visit_vitals** table: BP, HR, temperature, weight, height, SpO2, recorded_at, recorded_by
- When doctor creates a **lab result**:
  - Creates lab_reports row with report_type, status, file_url
  - Creates biomarkers rows for each test value (test_name, value, normal_min, normal_max, unit)
- Vitals and notes are **linked to visits** so patient can see what happened when

---

### 3. **Hospital Portal** (Admin Web)
**Target:** Hospital administrators managing doctors, verify profiles, manage hospital data

**Core Features:**
- Hospital staff sign in via email+password or Google
- View all doctors in hospital
- Pre-create doctor profiles (name, email, phone, specialization)
- Verify/approve doctors (marks as verified)
- View hospital appointments and occupancy
- Manage hospital settings (name, address, license, contact)

**Data Shown:**
- Hospital doctors list with status (verified/unverified)
- Doctor specializations and contact info
- Appointment bookings
- Pending access requests from patients

---

### 4. **Lab Portal** (Technician Web)
**Target:** Lab technicians uploading test reports

**Core Features:**
- Lab staff sign in via email+password or Google
- Search patients by Health ID or name
- Upload lab report files (PDF, images)
- Enter biomarker values
- Assign report type (blood work, imaging, etc.)

**Data Shown:**
- Patient info (name, DOB, Health ID)
- Past lab reports (for comparison)
- Ability to add new report

---

## Data Model Overview

### Core Tables & How They Link

**`patients` table**
- `id` (UUID, primary key)
- `auth_id` (UUID, links to Supabase auth.users)
- `health_id` (string, unique, e.g., "HP-001-ABC")
- `full_name`, `date_of_birth`, `gender`
- `phone`, `email`
- `allergies` (JSON array: ["penicillin", "pollen"])
- `chronic_conditions` (JSON array: ["diabetes", "hypertension"])
- `blood_type`
- `emergency_contact_name`, `emergency_contact_phone`, `emergency_contact_relationship`
- `profile_photo_url`
- `created_at`, `updated_at`

**`doctors` table**
- `id` (UUID, primary key)
- `auth_id` (UUID, links to Supabase auth.users)
- `hospital_id` (UUID, links to hospitals)
- `full_name`, `phone`, `email`
- `specialization` (e.g., "Cardiologist", "Pediatrician")
- `verified` (boolean, marks if hospital admin approved them)
- `created_at`

**`access_grants` table** — Controls which patients each doctor can see
- `id` (UUID, primary key)
- `patient_id` (UUID, links to patients)
- `doctor_id` (UUID, links to doctors)
- `status` ("pending", "approved", "rejected")
- `access_level` ("read", "read_write")
- `created_at`

**`visits` table** — Clinical encounters (doctor-patient)
- `id` (UUID, primary key)
- `patient_id`, `doctor_id` (both UUIDs)
- `chief_complaint` (text)
- `examination_findings` (text)
- `diagnosis` (text)
- `notes` (text, treatment plan)
- `visit_type` ("consultation", "follow_up", "emergency", "procedure")
- `follow_up_date` (date, when patient should return)
- `icd_code` (ICD-10 code, e.g., "J20.9")
- `triage_level` ("emergency", "see_doctor", "home_care")
- `created_at`, `updated_at`

**`visit_vitals` table** — Vital signs recorded during visit (NEW)
- `id` (UUID, primary key)
- `visit_id`, `patient_id` (both UUIDs, links to visits and patients)
- `bp_systolic`, `bp_diastolic` (integers, e.g., 120, 80)
- `heart_rate` (integer, bpm)
- `temperature_c` (decimal, e.g., 37.2)
- `weight_kg`, `height_cm` (decimals)
- `spo2_percent` (decimal, oxygen saturation)
- `recorded_at`, `recorded_by` (who recorded it)

**`prescriptions` table**
- `id` (UUID, primary key)
- `patient_id`, `doctor_id` (both UUIDs)
- `medications` (JSON array of objects: `[{name: "Aspirin", dosage: "100mg", frequency: "daily"}]`)
- `instructions` (text)
- `created_at`

**`lab_reports` table** — Metadata for lab test batches
- `id` (UUID, primary key)
- `patient_id` (UUID)
- `report_type` ("blood_work", "imaging", "urinalysis", etc.)
- `status` ("pending", "ready", "reviewed")
- `file_url` (S3 URL if file uploaded)
- `created_at`

**`biomarkers` table** — Individual test values within a report
- `id` (UUID, primary key)
- `patient_id`, `report_id` (both UUIDs)
- `test_name` (e.g., "Hemoglobin")
- `value` (decimal, e.g., 12.5)
- `unit` (string, e.g., "g/dL")
- `normal_min`, `normal_max` (decimals, reference range)
- `created_at`

**`appointments` table** — Scheduled visits
- `id` (UUID, primary key)
- `patient_id`, `doctor_id` (both UUIDs)
- `scheduled_at` (datetime)
- `status` ("booked", "completed", "cancelled")
- `booked_by_patient_id` (UUID, NEW — who booked: patient or family manager)
- `booked_for_member_id` (UUID, NEW — if booked for family member)
- `created_at`

**`family_members` table** (NEW) — Patient's family members
- `id` (UUID, primary key)
- `primary_patient_id` (UUID, the patient managing the family)
- `member_patient_id` (UUID, NULL if family member hasn't joined HealthOS yet)
- `relationship` ("spouse", "child", "parent", "sibling", "guardian", "other")
- `full_name`, `date_of_birth`, `gender`, `phone`
- `is_dependent` (boolean, managed by primary patient without invite)
- `can_view_records`, `can_manage_appointments` (permissions)
- `invite_status` ("not_invited", "invited", "linked")
- `created_at`

**`doctor_notes` table** (NEW) — Doctor's clinical notes
- `id` (UUID, primary key)
- `patient_id`, `doctor_id` (both UUIDs)
- `content` (text)
- `is_private` (boolean, if true only doctor sees it; if false patient sees it)
- `created_at`, `updated_at`

**`notifications` table**
- `id` (UUID, primary key)
- `user_id` (UUID, Supabase auth user)
- `title`, `body` (text)
- `notification_type` ("appointment_booked", "visit_completed", "lab_result_ready", etc.)
- `related_id` (UUID, links to relevant record)
- `read_at` (nullable, when user read it)
- `created_at`

---

## Key User Flows

### **Flow 1: Patient Registers & Sets Up Profile**

```
1. Patient opens app
2. Taps "Sign Up"
3. Chooses: Phone OTP | Email OTP | Google Sign-In
4. Authenticates (Supabase creates auth.users row)
5. App checks: Does patient profile exist?
   → NO: Redirect to ProfileSetupScreen
   → YES: Redirect to /home
6. ProfileSetupScreen:
   - Full Name (pre-filled from Google if via Google)
   - Date of Birth
   - Gender
   - Blood Type
   - Phone (if not OTP method)
   - Allergies (comma-separated or tags)
   - Chronic Conditions (comma-separated or tags)
   - Emergency Contact (name, phone, relationship)
   - Profile Photo (optional, upload to Supabase Storage)
7. Taps "Create Profile" → App creates `patients` row
8. App generates unique Health ID (e.g., "HP-001-ABC")
9. Redirects to /home
```

**Data Created:**
- `auth.users` (created by Supabase Auth)
- `patients` table row with all profile info

---

### **Flow 2: Doctor Registers (Pre-Created by Hospital)**

```
1. Hospital admin creates doctor in Hospital Portal:
   - Full Name
   - Email
   - Phone
   - Specialization
   - Hospital (selects from hospital dropdown)
   → Creates `doctors` table row with verified=false
   → Sends email with link to doctor_app

2. Doctor opens link or opens doctor_app manually
3. Taps "Sign In with Google" or "Phone OTP"
4. Doctor authenticates (Supabase creates auth.users row)
5. App checks: Does doctor profile exist?
   → YES: Redirect to /home (dashboard)
   → NO: Show "Account Not Found" screen
      - "Your account hasn't been created yet."
      - "Contact your hospital admin to set up your profile."
      - Taps "Sign Out"

6. Once doctor profile exists in `doctors` table:
   - Doctor signs in again
   - App fetches `doctors` row where auth_id = current_user.id
   - Redirects to /home (patient list)
```

**Data Created:**
- `auth.users` (created by Supabase Auth)
- `doctors` table row (pre-created by hospital)

---

### **Flow 3: Patient Grants Doctor Access (QR or Health ID)**

```
Option A: Doctor scans patient's QR code
1. Patient's app generates QR from their Health ID (e.g., "HP-001-ABC")
2. Doctor opens doctor_app → Patient List screen
3. Taps "Scan QR Code" button
4. Scans patient's QR
5. App extracts Health ID
6. Creates `access_grants` row: 
   - patient_id = (lookup by health_id)
   - doctor_id = current_doctor.id
   - status = "approved" (auto-approve via QR)
7. Doctor immediately sees patient in their list

Option B: Doctor enters Health ID
1. Doctor taps "Enter Health ID"
2. Inputs patient health ID (e.g., "HP-001-ABC")
3. App creates `access_grants` row with status="pending"
4. Patient gets notification: "Dr. [Name] requested access to your records"
5. Patient approves/declines in their app
6. If approved: access_grants.status = "approved"
7. Doctor can now see patient

**Data Created/Updated:**
- `access_grants` table row (either auto-approved or pending)
```

---

### **Flow 4: Doctor Creates a Visit for Patient**

```
1. Doctor in doctor_app, viewing patient detail
2. Taps Speed Dial FAB → "New Visit"
3. Lands on CreateVisitScreen:
   
   a) Select Visit Type: [Consultation ▾]
   b) Chief Complaint: "Persistent cough"
   c) Expand "Vital Signs":
      - BP: 120 / 80 mmHg
      - HR: 88 bpm
      - Temp: 37.2 °C
      - Weight: 75 kg
      - Height: 180 cm
      - SpO2: 98 %
   d) Examination Findings: "[multiline text]"
   e) Diagnosis/Assessment: "[multiline text]"
   f) ICD-10 Code: "J20.9" (optional)
   g) Treatment Plan: "[multiline text]"
   h) Follow-up Date: [Pick date]
   i) Triage Level: [See Doctor ▾]
   
4. Taps "Save Visit"
5. App creates two DB rows:
   
   **visits row:**
   - patient_id, doctor_id
   - chief_complaint = "Persistent cough"
   - diagnosis = "[from step e]"
   - notes = "[examination + plan combined]"
   - visit_type = "consultation"
   - follow_up_date = [selected date]
   - icd_code = "J20.9"
   - triage_level = "see_doctor"
   
   **visit_vitals row:**
   - visit_id = [new visit's id]
   - bp_systolic=120, bp_diastolic=80
   - heart_rate=88
   - temperature_c=37.2
   - weight_kg=75, height_cm=180
   - spo2_percent=98
   - recorded_by = current_doctor.id

6. Patient gets notification: "Dr. [Name] added a new visit"
7. Patient sees visit in their Records tab with all details

**Data Created:**
- `visits` table row
- `visit_vitals` table row
```

---

### **Flow 5: Patient Books Appointment (for self or family member)**

```
1. Patient in patient_app, taps "Book Appointment" button
2. **NEW: "For Whom?" screen:**
   - Radio button: "For Me" (selected by default)
   - Radio buttons: "Priya (Spouse)", "Arjun (Child, 7 yrs)", etc.
   - Taps "Next"
   - If selecting family member → `selectedBookingMemberProvider` = that member

3. Doctor Selection screen:
   - Search by specialization or name
   - Select doctor
   - Doctor's calendar shows available slots

4. Date/Time Selection:
   - Pick date and time from calendar
   - Taps "Confirm"

5. Taps "Book Appointment"
6. App creates `appointments` row:
   - patient_id = current_patient.id
   - doctor_id = [selected doctor]
   - scheduled_at = [selected date/time]
   - booked_by_patient_id = current_patient.id
   - booked_for_member_id = [selected family member id, or NULL if for self]
   - status = "booked"

7. Both patient and doctor get notifications:
   - Patient: "Appointment confirmed with Dr. [Name] on [date]"
   - Doctor: "[Patient Name] booked appointment on [date]"

**Data Created:**
- `appointments` table row
```

---

### **Flow 6: Patient Adds Family Member**

```
1. Patient in patient_app, Profile tab
2. Taps "Add Family Member" button
3. **Step 1: Who are you adding?**
   - Grid of relationship buttons: Spouse | Parent | Child | Sibling | Guardian | Other
   - Tap one, advance to Step 2

4. **Step 2: Tell us about them**
   - Full Name *
   - Date of Birth (optional)
   - Gender (Male | Female | Other)
   - Phone (optional, for invite)
   - Taps "Next"

5. **Step 3: Set Permissions**
   - Radio: "I'll manage their health" (default for children)
     - Can book appointments, view records
   - Radio: "Can view my health records"
     - They see patient's reports, appointments (not full control)
   - If phone provided: highlighted "Send SMS Invite" button

6. Taps "Add Member"
7. App creates `family_members` row:
   - primary_patient_id = current_patient.id
   - member_patient_id = NULL (not linked yet)
   - relationship = [selected]
   - full_name = [entered]
   - date_of_birth = [entered]
   - gender = [selected]
   - phone = [entered]
   - is_dependent = true if managed, false if can view records
   - can_view_records, can_manage_appointments = [based on step 3]
   - invite_status = "not_invited" (unless phone provided → "invited")

8. If SMS sent: notification service sends SMS to family member
   - "Join HealthOS to manage [Patient Name]'s health: [link]"

9. Family member joins → creates `patients` table row
10. App auto-matches: family_members.member_patient_id = new_patients.id
11. Family member now appears as "Linked ✓" in patient's family list

**Data Created/Updated:**
- `family_members` table row
- When family member joins: `patients` table row + update family_members.member_patient_id
```

---

### **Flow 7: Patient Views Their Records**

```
1. Patient in patient_app, Records tab
2. Sees timeline of:
   - Upcoming appointments (blue badge)
   - Past visits (with chief complaint, diagnosis, follow-up date)
   - Prescriptions (medications and dosage)
   - Lab reports (test names and results)
   - Doctor notes (only if doctor marked as shared)

3. Taps on a visit:
   - Opens VisitDetailScreen
   - Shows:
     * Chief complaint
     * Diagnosis
     * Vital signs (from visit_vitals table)
       - "BP: 120/80 mmHg  •  HR: 88 bpm  •  Temp: 37.2°C"
       - "Weight: 75kg  •  Height: 180cm  •  SpO2: 98%"
     * Examination findings
     * Treatment plan
     * Follow-up date
     * Doctor name

4. Taps on a lab report:
   - Shows all biomarkers in that report
   - Test name, value, unit, normal range
   - Color-coded: green (normal), yellow (borderline), red (abnormal)

**Data Retrieved:**
- `visits` + `visit_vitals` (joined)
- `lab_reports` + `biomarkers` (joined)
- `prescriptions`
- `appointments`
- `doctor_notes` where is_private = false
- `notifications`
```

---

### **Flow 8: Doctor Views Patient Summary (AI)**

```
1. Doctor in doctor_app, patient detail screen
2. Taps "AI Summary" button
3. App sends request to Edge Function (ai-service):
   - patient_id = [selected patient]
   - Includes: all visits, prescriptions, lab results, appointments, allergies, conditions

4. AI (Gemini) generates summary:
   - Overview: "Patient has Type 2 diabetes for 3 years, mostly stable"
   - Key Findings: "HbA1c 7.2%, BP consistently >140/90"
   - Risk Factors: "Uncontrolled hypertension, family history of cardiac disease"
   - Recommendations: "Review BP medication, order cardiac workup, 2-week follow-up"

5. Doctor sees formatted screen with sections
6. Bottom disclaimer: "⚠️ AI-generated. Verify with clinical records."

**Data Sent to AI:**
- Patient's full medical history (visits, labs, prescriptions, allergies, conditions)
- AI generates text summary
```

---

## Key Business Rules & Validations

### **Patient Data Rules**
- ✅ Patients create their own profiles after first login
- ✅ Patients control who can access their records (via access_grants)
- ✅ Patients can only modify their own profile (except allergies/conditions if doctor updates)
- ✅ Patients see only their own family members and their own appointments
- ❌ Patients cannot see other patients' data
- ❌ Patients cannot delete visits or prescriptions (immutable records)

### **Doctor Data Rules**
- ✅ Doctors can only see patients who granted access (access_grants.approved)
- ✅ Doctors can create visits, prescriptions, lab results, notes for their patients
- ✅ Doctors can edit patient allergies and chronic conditions (clinical authority)
- ✅ Doctors can toggle notes as private or shared with patient
- ✅ Doctor's own notes are always visible to the doctor
- ❌ Doctors cannot modify patient personal demographics (name, DOB, phone)
- ❌ Doctors cannot see other doctors' patients
- ❌ Doctors cannot delete patient records

### **Family Member Rules**
- ✅ Patient can add family members (no invite needed for dependents like children)
- ✅ Patient can send SMS invite to adult family members
- ✅ Patient controls permissions per family member (view records, manage appointments)
- ✅ When family member joins HealthOS, they become linked
- ✅ Patient can book appointments on behalf of dependents
- ✅ Adult family members can accept/decline access
- ❌ Family members cannot access other family members' records (only primary patient can manage)

### **Appointment Rules**
- ✅ Patient can book appointments with doctors they've found
- ✅ Patient can book appointments for themselves or family members
- ✅ Appointment automatically approved (no doctor confirmation needed for booked status)
- ✅ Doctor can see all appointments (confirmed + pending)
- ✅ Patient can cancel appointment
- ❌ Doctor cannot create appointments (patient books them)

### **Notification Rules**
- ✅ Patient gets notified when:
  - Doctor creates a visit
  - Doctor adds lab results
  - Appointment is booked/cancelled
  - Lab results are ready
  - Doctor sends invitation (family member)
- ✅ Doctor gets notified when:
  - Patient books appointment
  - Patient grants access
  - Lab results ready for patient
- ✅ Notifications persist in-app and via FCM (Firebase Cloud Messaging)

---

## What's Currently Missing (Phase Implementation)

### **Phase 1: Google OAuth Fix** 🔴 CRITICAL
- Real Google credentials needed
- Mobile deep link configuration
- Profile setup screen pre-fill from Google
- Router fixes to check profile after auth
- Doctor "Account Not Found" screen

### **Phase 2: Database Migrations** 🔴 CRITICAL
- `family_members` table
- `visit_vitals` table
- `doctor_notes` table
- Alter `appointments` (booked_by/for columns)
- Alter `visits` (follow_up_date, icd_code, visit_type)

### **Phase 3: Patient App Features**
- Family Hub screens (add, list, detail, edit)
- "For whom?" appointment booking step
- Family health quick card on home

### **Phase 4: Doctor App Features**
- Enhanced visit creation with vitals
- Lab result manual entry
- Quick notes modal
- Medical history edit sheet
- AI summary screen

### **Phase 5: Hospital Portal Enhancements**
- Doctor onboarding flow
- Pending verification status

### **Phase 6: Lab Portal**
- Lab report upload and biomarker entry

---

## Data Flow Summary

```
Patient Registers
    ↓
Creates Profile (name, DOB, allergies, conditions, etc.)
    ↓
Unique Health ID Generated
    ↓
Doctor scans QR or enters Health ID
    ↓
Patient approves access (access_grants row created)
    ↓
Doctor can now see patient in their list
    ↓
Doctor creates visit → visit + visit_vitals rows
    ↓
Patient sees visit in Records tab with all details
    ↓
Patient adds family member (family_members row)
    ↓
Family member joins HealthOS (patients row)
    ↓
Family member linked (family_members.member_patient_id updated)
    ↓
Patient books appointment for family member
    ↓
Appointment created with booked_for_member_id set
    ↓
Doctor creates prescription/lab result/note
    ↓
Patient gets notification and sees data
```

---

## Relationship Between Key Entities

### Patient ↔ Doctor (via access_grants)
```
Patient A → [access_grants] ← Doctor B
            (approved by Patient A)
            
Doctor B can now:
- See Patient A's visits, prescriptions, labs, allergies, conditions
- Create new visits/prescriptions/labs for Patient A
- Edit Patient A's allergies/conditions
```

### Patient ↔ Family Member (via family_members)
```
Patient A → [family_members] ← Family Member (Spouse/Child)
            (can_view_records, can_manage_appointments)
            
Primary Patient can:
- Book appointments for family member
- View family member's appointments/records (if family member linked)

Family Member (if joined HealthOS):
- Sees own records
- Can view Patient A's records (if granted permission)
```

### Visit ↔ Vitals (via visit_id)
```
Visit → [visit_vitals] (one-to-many)
        (all vital signs recorded during that visit)

Patient sees vitals in visit detail
Doctor sees vitals when creating/reviewing visit
```

### Lab Report ↔ Biomarkers (via report_id)
```
Lab Report → [biomarkers] (one-to-many)
             (all test values in that report)

Patient sees all biomarkers in a report
Doctor can manually create biomarkers via AddLabResultScreen
```

### Appointment ↔ Patient ↔ Family Member
```
Appointment {
  patient_id = Patient A,
  booked_by_patient_id = Patient A,
  booked_for_member_id = Family Member B (or NULL if for self)
}

Doctor sees: "Appointment with Patient A (on behalf of Family Member B)"
Patient sees: "Appointment booked for Arjun (child) with Dr. X"
```

---

## UI/UX Principles

### For Patients
- **Health ID as identity** — Show prominently on home screen
- **Timeline view** — All health events in chronological order
- **Clear allergies warning** — Show prominently (life-critical info)
- **Family at a glance** — Quick card showing upcoming appts for family members
- **Simple appointment booking** — "For whom?" first step, then doctor selection
- **Read-only most data** — Only doctors can create visits/prescriptions

### For Doctors
- **Patient list from access grants** — Not all patients, only those who approved
- **Speed dial for common actions** — Visit, Prescription, Lab, Note
- **Vital signs prominent** — Always visible in visit detail and timeline
- **Clinical notes separate** — Private vs shared toggle for each note
- **Editable clinical data** — Allergies and conditions (doctor authority)
- **AI summary for context** — Quick understanding of patient's overall health

### For Hospital Admins
- **Doctor management** — Create, verify, assign to hospital
- **Access control** — Who can access hospital data
- **Audit trail** — See what doctors are doing

### For Lab Technicians
- **Simple upload** — Drag-drop or pick file
- **Biomarker entry** — Quick form to enter test values
- **Patient lookup** — By Health ID or name

---

## Key Features to Implement

✅ **Core (already done)**
- Patient registration (phone OTP, email OTP)
- Doctor profile (pre-created by hospital)
- Patient creates profile
- Basic appointments
- Basic visits and prescriptions
- Basic lab reports

🚧 **In Progress**
- Google OAuth (broken, needs fix)
- Family member management
- Enhanced visit creation with vitals
- Doctor notes (private/shared)
- AI health summary

❌ **Not Started**
- Hospital portal doctor management
- Lab portal file uploads
- Mobile push notifications
- Offline mode
- Advanced search and filtering
- Patient-doctor messaging
- Appointment rescheduling
- Video consultation

---

## References

- **ARCHITECTURE.md** — Complete feature specifications, DB schema, UI mockups, implementation roadmap (read this for detailed specs)
- **README.md** — Tech stack and setup
- This **CLAUDE.md** — How the app works, features, data links, what to show to users

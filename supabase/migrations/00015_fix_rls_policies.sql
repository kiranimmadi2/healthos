-- ========================================
-- Fix RLS Policies: Break Circular References
-- ========================================
-- Problem: policies on patients JOIN access_grants, whose policies JOIN patients → infinite recursion
-- Solution: SECURITY DEFINER helper functions that bypass RLS for cross-table lookups

-- ========================================
-- Step 1: Drop ALL existing policies
-- ========================================

-- patients
DROP POLICY IF EXISTS "patients_own_row" ON patients;
DROP POLICY IF EXISTS "doctors_view_granted_patients" ON patients;

-- doctors
DROP POLICY IF EXISTS "doctors_own_row" ON doctors;
DROP POLICY IF EXISTS "patients_view_granted_doctors" ON doctors;
DROP POLICY IF EXISTS "doctors_public_search" ON doctors;

-- hospitals
DROP POLICY IF EXISTS "hospitals_public_read" ON hospitals;

-- access_grants
DROP POLICY IF EXISTS "patients_manage_own_grants" ON access_grants;
DROP POLICY IF EXISTS "doctors_view_own_grants" ON access_grants;

-- visits
DROP POLICY IF EXISTS "patients_view_own_visits" ON visits;
DROP POLICY IF EXISTS "doctors_manage_granted_visits" ON visits;

-- lab_reports
DROP POLICY IF EXISTS "patients_view_own_reports" ON lab_reports;
DROP POLICY IF EXISTS "doctors_view_granted_reports" ON lab_reports;

-- biomarkers
DROP POLICY IF EXISTS "patients_view_own_biomarkers" ON biomarkers;
DROP POLICY IF EXISTS "doctors_view_granted_biomarkers" ON biomarkers;

-- prescriptions
DROP POLICY IF EXISTS "patients_view_own_prescriptions" ON prescriptions;
DROP POLICY IF EXISTS "doctors_manage_granted_prescriptions" ON prescriptions;

-- symptom_sessions
DROP POLICY IF EXISTS "patients_own_sessions" ON symptom_sessions;
DROP POLICY IF EXISTS "doctors_view_granted_sessions" ON symptom_sessions;

-- patient_embeddings
DROP POLICY IF EXISTS "service_role_only_embeddings" ON patient_embeddings;

-- ========================================
-- Step 2: Create SECURITY DEFINER helper functions
-- These bypass RLS so they don't trigger circular policy evaluation
-- ========================================

CREATE OR REPLACE FUNCTION get_patient_id_for_user(user_id UUID)
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM patients WHERE auth_id = user_id LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION get_doctor_id_for_user(user_id UUID)
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM doctors WHERE auth_id = user_id LIMIT 1;
$$;

-- Helper: check if a doctor has active access to a patient (bypasses RLS)
CREATE OR REPLACE FUNCTION doctor_has_access_to_patient(d_id UUID, p_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM access_grants
    WHERE doctor_id = d_id
      AND patient_id = p_id
      AND status = 'active'
      AND (expires_at IS NULL OR expires_at > NOW())
  );
$$;

-- Helper: get all patient IDs a doctor has access to (bypasses RLS)
CREATE OR REPLACE FUNCTION get_granted_patient_ids(d_id UUID)
RETURNS SETOF UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT patient_id FROM access_grants
  WHERE doctor_id = d_id
    AND status = 'active'
    AND (expires_at IS NULL OR expires_at > NOW());
$$;

-- ========================================
-- Step 3: Recreate ALL policies (no circular references)
-- ========================================

-- PATIENTS
CREATE POLICY "patient_select_own" ON patients
  FOR SELECT USING (auth_id = auth.uid());

CREATE POLICY "patient_insert_own" ON patients
  FOR INSERT WITH CHECK (auth_id = auth.uid());

CREATE POLICY "patient_update_own" ON patients
  FOR UPDATE USING (auth_id = auth.uid());

CREATE POLICY "doctor_select_granted_patients" ON patients
  FOR SELECT USING (
    id IN (SELECT get_granted_patient_ids(get_doctor_id_for_user(auth.uid())))
  );

-- DOCTORS
CREATE POLICY "doctor_select_own" ON doctors
  FOR SELECT USING (auth_id = auth.uid());

CREATE POLICY "doctor_insert_own" ON doctors
  FOR INSERT WITH CHECK (auth_id = auth.uid());

CREATE POLICY "doctor_update_own" ON doctors
  FOR UPDATE USING (auth_id = auth.uid());

CREATE POLICY "doctor_public_search" ON doctors
  FOR SELECT USING (verified = true);

-- HOSPITALS
CREATE POLICY "hospitals_public_read" ON hospitals
  FOR SELECT USING (true);

-- ACCESS GRANTS
CREATE POLICY "patient_manage_grants" ON access_grants
  FOR ALL USING (
    patient_id = get_patient_id_for_user(auth.uid())
  );

CREATE POLICY "doctor_view_grants" ON access_grants
  FOR SELECT USING (
    doctor_id = get_doctor_id_for_user(auth.uid())
  );

-- VISITS
CREATE POLICY "patient_view_visits" ON visits
  FOR SELECT USING (
    patient_id = get_patient_id_for_user(auth.uid())
  );

CREATE POLICY "doctor_manage_visits" ON visits
  FOR ALL USING (
    doctor_has_access_to_patient(
      get_doctor_id_for_user(auth.uid()),
      patient_id
    )
  );

-- LAB REPORTS
CREATE POLICY "patient_view_reports" ON lab_reports
  FOR SELECT USING (
    patient_id = get_patient_id_for_user(auth.uid())
  );

CREATE POLICY "doctor_view_reports" ON lab_reports
  FOR SELECT USING (
    doctor_has_access_to_patient(
      get_doctor_id_for_user(auth.uid()),
      patient_id
    )
  );

CREATE POLICY "service_insert_reports" ON lab_reports
  FOR INSERT WITH CHECK (
    auth.role() = 'service_role'
  );

CREATE POLICY "service_update_reports" ON lab_reports
  FOR UPDATE USING (
    auth.role() = 'service_role'
  );

-- BIOMARKERS
CREATE POLICY "patient_view_biomarkers" ON biomarkers
  FOR SELECT USING (
    patient_id = get_patient_id_for_user(auth.uid())
  );

CREATE POLICY "doctor_view_biomarkers" ON biomarkers
  FOR SELECT USING (
    doctor_has_access_to_patient(
      get_doctor_id_for_user(auth.uid()),
      patient_id
    )
  );

CREATE POLICY "service_insert_biomarkers" ON biomarkers
  FOR INSERT WITH CHECK (
    auth.role() = 'service_role'
  );

-- PRESCRIPTIONS
CREATE POLICY "patient_view_prescriptions" ON prescriptions
  FOR SELECT USING (
    patient_id = get_patient_id_for_user(auth.uid())
  );

CREATE POLICY "doctor_manage_prescriptions" ON prescriptions
  FOR ALL USING (
    doctor_has_access_to_patient(
      get_doctor_id_for_user(auth.uid()),
      patient_id
    )
  );

-- SYMPTOM SESSIONS
CREATE POLICY "patient_manage_sessions" ON symptom_sessions
  FOR ALL USING (
    patient_id = get_patient_id_for_user(auth.uid())
  );

CREATE POLICY "doctor_view_sessions" ON symptom_sessions
  FOR SELECT USING (
    doctor_has_access_to_patient(
      get_doctor_id_for_user(auth.uid()),
      patient_id
    )
  );

-- PATIENT EMBEDDINGS (service role only — used by Edge Functions)
CREATE POLICY "service_manage_embeddings" ON patient_embeddings
  FOR ALL USING (auth.role() = 'service_role');

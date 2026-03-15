-- ========================================
-- Row Level Security Policies
-- ========================================

-- PATIENTS
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patients_own_row" ON patients
  FOR ALL USING (auth_id = auth.uid());

CREATE POLICY "doctors_view_granted_patients" ON patients
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM access_grants ag
      JOIN doctors d ON d.id = ag.doctor_id
      WHERE ag.patient_id = patients.id
        AND d.auth_id = auth.uid()
        AND ag.status = 'active'
        AND (ag.expires_at IS NULL OR ag.expires_at > NOW())
    )
  );

-- DOCTORS
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "doctors_own_row" ON doctors
  FOR ALL USING (auth_id = auth.uid());

CREATE POLICY "patients_view_granted_doctors" ON doctors
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM access_grants ag
      JOIN patients p ON p.id = ag.patient_id
      WHERE ag.doctor_id = doctors.id
        AND p.auth_id = auth.uid()
        AND ag.status = 'active'
    )
  );

CREATE POLICY "doctors_public_search" ON doctors
  FOR SELECT USING (verified = true);

-- HOSPITALS
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "hospitals_public_read" ON hospitals
  FOR SELECT USING (true);

-- ACCESS GRANTS
ALTER TABLE access_grants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patients_manage_own_grants" ON access_grants
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM patients p
      WHERE p.id = access_grants.patient_id
        AND p.auth_id = auth.uid()
    )
  );

CREATE POLICY "doctors_view_own_grants" ON access_grants
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM doctors d
      WHERE d.id = access_grants.doctor_id
        AND d.auth_id = auth.uid()
    )
  );

-- VISITS
ALTER TABLE visits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patients_view_own_visits" ON visits
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM patients p
      WHERE p.id = visits.patient_id AND p.auth_id = auth.uid()
    )
  );

CREATE POLICY "doctors_manage_granted_visits" ON visits
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM doctors d
      JOIN access_grants ag ON ag.doctor_id = d.id
      WHERE d.auth_id = auth.uid()
        AND ag.patient_id = visits.patient_id
        AND ag.status = 'active'
    )
  );

-- LAB REPORTS
ALTER TABLE lab_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patients_view_own_reports" ON lab_reports
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM patients p
      WHERE p.id = lab_reports.patient_id AND p.auth_id = auth.uid()
    )
  );

CREATE POLICY "doctors_view_granted_reports" ON lab_reports
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM doctors d
      JOIN access_grants ag ON ag.doctor_id = d.id
      WHERE d.auth_id = auth.uid()
        AND ag.patient_id = lab_reports.patient_id
        AND ag.status = 'active'
    )
  );

-- BIOMARKERS
ALTER TABLE biomarkers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patients_view_own_biomarkers" ON biomarkers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM patients p
      WHERE p.id = biomarkers.patient_id AND p.auth_id = auth.uid()
    )
  );

CREATE POLICY "doctors_view_granted_biomarkers" ON biomarkers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM doctors d
      JOIN access_grants ag ON ag.doctor_id = d.id
      WHERE d.auth_id = auth.uid()
        AND ag.patient_id = biomarkers.patient_id
        AND ag.status = 'active'
    )
  );

-- PRESCRIPTIONS
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patients_view_own_prescriptions" ON prescriptions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM patients p
      WHERE p.id = prescriptions.patient_id AND p.auth_id = auth.uid()
    )
  );

CREATE POLICY "doctors_manage_granted_prescriptions" ON prescriptions
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM doctors d
      JOIN access_grants ag ON ag.doctor_id = d.id
      WHERE d.auth_id = auth.uid()
        AND ag.patient_id = prescriptions.patient_id
        AND ag.status = 'active'
    )
  );

-- SYMPTOM SESSIONS
ALTER TABLE symptom_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "patients_own_sessions" ON symptom_sessions
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM patients p
      WHERE p.id = symptom_sessions.patient_id AND p.auth_id = auth.uid()
    )
  );

CREATE POLICY "doctors_view_granted_sessions" ON symptom_sessions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM doctors d
      JOIN access_grants ag ON ag.doctor_id = d.id
      WHERE d.auth_id = auth.uid()
        AND ag.patient_id = symptom_sessions.patient_id
        AND ag.status = 'active'
    )
  );

-- PATIENT EMBEDDINGS
ALTER TABLE patient_embeddings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_role_only_embeddings" ON patient_embeddings
  FOR ALL USING (auth.role() = 'service_role');

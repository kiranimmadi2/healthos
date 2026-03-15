-- ========================================
-- Seed Data for Development
-- ========================================

-- Hospital
INSERT INTO hospitals (id, name, address, license, phone, email) VALUES
  ('h0000001-0000-0000-0000-000000000001', 'City General Hospital', '{"street": "123 Medical Ave", "city": "Mumbai", "state": "Maharashtra", "zip": "400001"}', 'HOSP-MH-2024-001', '+912212345678', 'admin@citygeneralhospital.com');

-- Test Patients (auth_id will be linked when they sign up)
INSERT INTO patients (id, health_id, phone, full_name, date_of_birth, gender, blood_group, allergies, chronic_conditions) VALUES
  ('p0000001-0000-0000-0000-000000000001', 'HOS-2024-AB12', '+919876543210', 'Rahul Sharma', '1990-05-15', 'male', 'O+', '{"Penicillin"}', '{"Hypertension"}'),
  ('p0000002-0000-0000-0000-000000000002', 'HOS-2024-CD34', '+919876543211', 'Priya Patel', '1985-11-22', 'female', 'A+', '{}', '{"Diabetes Type 2"}'),
  ('p0000003-0000-0000-0000-000000000003', 'HOS-2024-EF56', '+919876543212', 'Amit Kumar', '2000-03-08', 'male', 'B+', '{"Sulfa drugs"}', '{}');

-- Test Doctors
INSERT INTO doctors (id, full_name, specialization, hospital_id, license_number, verified, phone, email) VALUES
  ('d0000001-0000-0000-0000-000000000001', 'Dr. Ananya Singh', 'Cardiology', 'h0000001-0000-0000-0000-000000000001', 'MCI-2020-12345', true, '+919876543220', 'dr.ananya@citygeneralhospital.com'),
  ('d0000002-0000-0000-0000-000000000002', 'Dr. Rajesh Gupta', 'General Medicine', 'h0000001-0000-0000-0000-000000000001', 'MCI-2018-67890', true, '+919876543221', 'dr.rajesh@citygeneralhospital.com');

-- Access Grants
INSERT INTO access_grants (patient_id, doctor_id, hospital_id, status, access_level) VALUES
  ('p0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001', 'active', 'read'),
  ('p0000001-0000-0000-0000-000000000001', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001', 'active', 'full'),
  ('p0000002-0000-0000-0000-000000000002', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001', 'active', 'read');

-- Visits
INSERT INTO visits (patient_id, doctor_id, hospital_id, visited_at, chief_complaint, diagnosis, notes) VALUES
  ('p0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001', '2024-12-01 10:00:00+05:30', 'Chest pain on exertion', 'Stable angina', 'Prescribed beta-blocker. Follow-up in 2 weeks.'),
  ('p0000001-0000-0000-0000-000000000001', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001', '2025-01-15 11:00:00+05:30', 'Routine checkup', 'Hypertension - controlled', 'BP 130/85. Continue current medications.'),
  ('p0000002-0000-0000-0000-000000000002', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001', '2025-02-10 09:30:00+05:30', 'Elevated blood sugar', 'Diabetes Type 2 - suboptimal control', 'HbA1c 7.8%. Adjusted metformin dose.');

-- Lab Reports
INSERT INTO lab_reports (id, patient_id, visit_id, report_type, report_date, status, ai_summary, lab_name) VALUES
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', NULL, 'CBC', '2025-01-15', 'ready', 'Complete Blood Count within normal limits. Slight elevation in WBC count (11.2) which may indicate minor infection or stress response.', 'City Lab Services'),
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', NULL, 'Lipid Profile', '2025-01-15', 'ready', 'Elevated LDL cholesterol at 145 mg/dL. Total cholesterol borderline high. HDL within normal range. Consider dietary modifications and statin therapy.', 'City Lab Services'),
  ('r0000003-0000-0000-0000-000000000003', 'p0000002-0000-0000-0000-000000000002', NULL, 'HbA1c', '2025-02-10', 'ready', 'HbA1c at 7.8% indicates suboptimal glycemic control. Fasting glucose 156 mg/dL. Recommend medication adjustment and lifestyle changes.', 'MedTest Labs');

-- Biomarkers for CBC report
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 'Haemoglobin', 14.5, 'g/dL', 13.0, 17.0, '2025-01-15 00:00:00+05:30'),
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 'WBC Count', 11.2, '10^3/uL', 4.0, 11.0, '2025-01-15 00:00:00+05:30'),
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 'Platelet Count', 250, '10^3/uL', 150, 400, '2025-01-15 00:00:00+05:30'),
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 'RBC Count', 5.1, '10^6/uL', 4.5, 5.5, '2025-01-15 00:00:00+05:30');

-- Biomarkers for Lipid Profile
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', 'Total Cholesterol', 235, 'mg/dL', 0, 200, '2025-01-15 00:00:00+05:30'),
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', 'LDL Cholesterol', 145, 'mg/dL', 0, 100, '2025-01-15 00:00:00+05:30'),
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', 'HDL Cholesterol', 52, 'mg/dL', 40, 60, '2025-01-15 00:00:00+05:30'),
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', 'Triglycerides', 190, 'mg/dL', 0, 150, '2025-01-15 00:00:00+05:30');

-- Biomarkers for HbA1c report
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000003-0000-0000-0000-000000000003', 'p0000002-0000-0000-0000-000000000002', 'HbA1c', 7.8, '%', 4.0, 5.7, '2025-02-10 00:00:00+05:30'),
  ('r0000003-0000-0000-0000-000000000003', 'p0000002-0000-0000-0000-000000000002', 'Fasting Glucose', 156, 'mg/dL', 70, 100, '2025-02-10 00:00:00+05:30');

-- Prescriptions
INSERT INTO prescriptions (patient_id, doctor_id, medications, issued_at, valid_until, notes) VALUES
  ('p0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001',
   '[{"name": "Metoprolol", "dose": "50mg", "frequency": "Once daily", "duration": "3 months", "instructions": "Take in the morning with food"}, {"name": "Aspirin", "dose": "75mg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Take after lunch"}]',
   '2024-12-01 10:00:00+05:30', '2025-03-01 00:00:00+05:30', 'Review lipid panel before next visit'),
  ('p0000002-0000-0000-0000-000000000002', 'd0000002-0000-0000-0000-000000000002',
   '[{"name": "Metformin", "dose": "1000mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Take with meals"}, {"name": "Glimepiride", "dose": "2mg", "frequency": "Once daily", "duration": "3 months", "instructions": "Take before breakfast"}]',
   '2025-02-10 09:30:00+05:30', '2025-05-10 00:00:00+05:30', 'Monitor blood glucose daily. Recheck HbA1c in 3 months.');

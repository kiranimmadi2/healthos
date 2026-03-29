-- ========================================
-- Seed Data for Development
-- ========================================
-- This file contains realistic test data for all HealthOS tables.
-- All existing seed data is preserved; new rows are appended.
-- ========================================

-- ========================================
-- HOSPITALS (3 total)
-- ========================================
INSERT INTO hospitals (id, name, address, license, phone, email) VALUES
  ('h0000001-0000-0000-0000-000000000001', 'City General Hospital',
   '{"street": "123 Medical Ave", "city": "Mumbai", "state": "Maharashtra", "zip": "400001"}',
   'HOSP-MH-2024-001', '+912212345678', 'admin@citygeneralhospital.com'),

  ('h0000002-0000-0000-0000-000000000002', 'Apollo Wellness Centre',
   '{"street": "45 Residency Road", "city": "Bengaluru", "state": "Karnataka", "zip": "560025"}',
   'HOSP-KA-2024-002', '+918041234567', 'admin@apollowellness.com'),

  ('h0000003-0000-0000-0000-000000000003', 'Fortis Heart & Multi-Speciality Hospital',
   '{"street": "8/2 Sector 62", "city": "Gurugram", "state": "Haryana", "zip": "122001"}',
   'HOSP-HR-2024-003', '+911244567890', 'admin@fortisheart.com');

-- ========================================
-- PATIENTS (20 total — 3 existing + 17 new)
-- ========================================
INSERT INTO patients (id, health_id, phone, full_name, date_of_birth, gender, blood_group, allergies, chronic_conditions) VALUES
  -- Existing 3
  ('p0000001-0000-0000-0000-000000000001', 'HOS-2024-AB12', '+919876543210', 'Rahul Sharma',    '1990-05-15', 'male',   'O+',  '{"Penicillin"}',             '{"Hypertension"}'),
  ('p0000002-0000-0000-0000-000000000002', 'HOS-2024-CD34', '+919876543211', 'Priya Patel',     '1985-11-22', 'female', 'A+',  '{}',                         '{"Diabetes Type 2"}'),
  ('p0000003-0000-0000-0000-000000000003', 'HOS-2024-EF56', '+919876543212', 'Amit Kumar',      '2000-03-08', 'male',   'B+',  '{"Sulfa drugs"}',            '{}'),
  -- New 17
  ('p0000004-0000-0000-0000-000000000004', 'HOS-2024-GH78', '+919876543213', 'Sneha Reddy',     '1992-07-19', 'female', 'AB+', '{}',                         '{"Asthma"}'),
  ('p0000005-0000-0000-0000-000000000005', 'HOS-2024-IJ90', '+919876543214', 'Vikram Deshmukh', '1978-01-30', 'male',   'A-',  '{"Aspirin"}',                '{"Hypertension","Hyperlipidemia"}'),
  ('p0000006-0000-0000-0000-000000000006', 'HOS-2024-KL12', '+919876543215', 'Anita Joshi',     '1988-09-05', 'female', 'O-',  '{}',                         '{"Hypothyroidism"}'),
  ('p0000007-0000-0000-0000-000000000007', 'HOS-2024-MN34', '+919876543216', 'Suresh Nair',     '1965-12-14', 'male',   'B-',  '{"Ibuprofen"}',              '{"Diabetes Type 2","Coronary Artery Disease"}'),
  ('p0000008-0000-0000-0000-000000000008', 'HOS-2024-OP56', '+919876543217', 'Kavitha Menon',   '1995-04-22', 'female', 'A+',  '{}',                         '{}'),
  ('p0000009-0000-0000-0000-000000000009', 'HOS-2024-QR78', '+919876543218', 'Deepak Verma',    '1982-06-11', 'male',   'O+',  '{"Latex"}',                  '{"GERD"}'),
  ('p0000010-0000-0000-0000-000000000010', 'HOS-2024-ST90', '+919876543219', 'Meera Iyer',      '1999-02-28', 'female', 'B+',  '{}',                         '{}'),
  ('p0000011-0000-0000-0000-000000000011', 'HOS-2024-UV12', '+919876543220', 'Arjun Malhotra',  '1975-08-03', 'male',   'AB-', '{"Codeine"}',                '{"Chronic Kidney Disease"}'),
  ('p0000012-0000-0000-0000-000000000012', 'HOS-2024-WX34', '+919876543230', 'Pooja Saxena',    '1991-10-17', 'female', 'O+',  '{}',                         '{"PCOS"}'),
  ('p0000013-0000-0000-0000-000000000013', 'HOS-2024-YZ56', '+919876543231', 'Ramesh Yadav',    '1960-03-25', 'male',   'A+',  '{"Metformin"}',              '{"Diabetes Type 2","Hypertension","Neuropathy"}'),
  ('p0000014-0000-0000-0000-000000000014', 'HOS-2024-AB78', '+919876543232', 'Divya Kulkarni',  '1997-11-09', 'female', 'B+',  '{}',                         '{}'),
  ('p0000015-0000-0000-0000-000000000015', 'HOS-2024-CD90', '+919876543233', 'Manish Tiwari',   '1987-05-20', 'male',   'O-',  '{"Erythromycin"}',           '{"Migraine"}'),
  ('p0000016-0000-0000-0000-000000000016', 'HOS-2024-EF78', '+919876543234', 'Lakshmi Pillai',  '1993-01-14', 'female', 'AB+', '{}',                         '{"Anemia"}'),
  ('p0000017-0000-0000-0000-000000000017', 'HOS-2024-GH90', '+919876543235', 'Sanjay Bhatt',    '1970-07-08', 'male',   'A-',  '{"Cephalosporins"}',         '{"COPD","Hypertension"}'),
  ('p0000018-0000-0000-0000-000000000018', 'HOS-2024-IJ12', '+919876543236', 'Nisha Agarwal',   '1996-12-03', 'female', 'B-',  '{}',                         '{}'),
  ('p0000019-0000-0000-0000-000000000019', 'HOS-2024-KL90', '+919876543237', 'Rajendra Prasad', '1955-09-18', 'male',   'O+',  '{"Contrast dye"}',           '{"Atrial Fibrillation","Heart Failure"}'),
  ('p0000020-0000-0000-0000-000000000020', 'HOS-2024-MN90', '+919876543238', 'Fatima Sheikh',   '1989-04-07', 'female', 'A+',  '{}',                         '{"Rheumatoid Arthritis"}');

-- ========================================
-- DOCTORS (10 total — 2 existing + 8 new)
-- ========================================
INSERT INTO doctors (id, full_name, specialization, hospital_id, license_number, verified, phone, email) VALUES
  -- Existing 2
  ('d0000001-0000-0000-0000-000000000001', 'Dr. Ananya Singh',     'Cardiology',        'h0000001-0000-0000-0000-000000000001', 'MCI-2020-12345', true,  '+919876543220', 'dr.ananya@citygeneralhospital.com'),
  ('d0000002-0000-0000-0000-000000000002', 'Dr. Rajesh Gupta',     'General Medicine',   'h0000001-0000-0000-0000-000000000001', 'MCI-2018-67890', true,  '+919876543221', 'dr.rajesh@citygeneralhospital.com'),
  -- New 8
  ('d0000003-0000-0000-0000-000000000003', 'Dr. Meghna Rao',       'Dermatology',        'h0000002-0000-0000-0000-000000000002', 'MCI-2019-11111', true,  '+919876543222', 'dr.meghna@apollowellness.com'),
  ('d0000004-0000-0000-0000-000000000004', 'Dr. Sunil Chandra',    'Orthopedics',        'h0000002-0000-0000-0000-000000000002', 'MCI-2017-22222', true,  '+919876543223', 'dr.sunil@apollowellness.com'),
  ('d0000005-0000-0000-0000-000000000005', 'Dr. Priyanka Bose',    'Pediatrics',         'h0000001-0000-0000-0000-000000000001', 'MCI-2021-33333', true,  '+919876543224', 'dr.priyanka@citygeneralhospital.com'),
  ('d0000006-0000-0000-0000-000000000006', 'Dr. Arun Kapoor',      'Neurology',          'h0000003-0000-0000-0000-000000000003', 'MCI-2016-44444', true,  '+919876543225', 'dr.arun@fortisheart.com'),
  ('d0000007-0000-0000-0000-000000000007', 'Dr. Shalini Mehta',    'Endocrinology',      'h0000003-0000-0000-0000-000000000003', 'MCI-2020-55555', true,  '+919876543226', 'dr.shalini@fortisheart.com'),
  ('d0000008-0000-0000-0000-000000000008', 'Dr. Vivek Pandey',     'Pulmonology',        'h0000001-0000-0000-0000-000000000001', 'MCI-2015-66666', true,  '+919876543227', 'dr.vivek@citygeneralhospital.com'),
  ('d0000009-0000-0000-0000-000000000009', 'Dr. Nandini Krishnan', 'Gynecology',         'h0000002-0000-0000-0000-000000000002', 'MCI-2022-77777', true,  '+919876543228', 'dr.nandini@apollowellness.com'),
  ('d0000010-0000-0000-0000-000000000010','Dr. Harish Sethi',      'Oncology',           'h0000003-0000-0000-0000-000000000003', 'MCI-2014-88888', false, '+919876543229', 'dr.harish@fortisheart.com');

-- ========================================
-- ACCESS GRANTS (mix of active, revoked, expired)
-- ========================================
INSERT INTO access_grants (patient_id, doctor_id, hospital_id, status, access_level) VALUES
  -- Existing 3
  ('p0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001', 'active',  'read'),
  ('p0000001-0000-0000-0000-000000000001', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001', 'active',  'full'),
  ('p0000002-0000-0000-0000-000000000002', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001', 'active',  'read'),
  -- New grants
  ('p0000003-0000-0000-0000-000000000003', 'd0000005-0000-0000-0000-000000000005', 'h0000001-0000-0000-0000-000000000001', 'active',  'full'),
  ('p0000004-0000-0000-0000-000000000004', 'd0000003-0000-0000-0000-000000000003', 'h0000002-0000-0000-0000-000000000002', 'active',  'read'),
  ('p0000004-0000-0000-0000-000000000004', 'd0000008-0000-0000-0000-000000000008', 'h0000001-0000-0000-0000-000000000001', 'active',  'full'),
  ('p0000005-0000-0000-0000-000000000005', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001', 'active',  'full'),
  ('p0000006-0000-0000-0000-000000000006', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003', 'active',  'full'),
  ('p0000007-0000-0000-0000-000000000007', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001', 'active',  'read'),
  ('p0000007-0000-0000-0000-000000000007', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003', 'active',  'full'),
  ('p0000008-0000-0000-0000-000000000008', 'd0000009-0000-0000-0000-000000000009', 'h0000002-0000-0000-0000-000000000002', 'active',  'read'),
  ('p0000009-0000-0000-0000-000000000009', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001', 'active',  'read'),
  ('p0000010-0000-0000-0000-000000000010', 'd0000003-0000-0000-0000-000000000003', 'h0000002-0000-0000-0000-000000000002', 'active',  'full'),
  ('p0000011-0000-0000-0000-000000000011', 'd0000006-0000-0000-0000-000000000006', 'h0000003-0000-0000-0000-000000000003', 'active',  'full'),
  ('p0000012-0000-0000-0000-000000000012', 'd0000009-0000-0000-0000-000000000009', 'h0000002-0000-0000-0000-000000000002', 'active',  'full'),
  ('p0000013-0000-0000-0000-000000000013', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003', 'active',  'full'),
  ('p0000013-0000-0000-0000-000000000013', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001', 'revoked', 'read'),
  ('p0000014-0000-0000-0000-000000000014', 'd0000004-0000-0000-0000-000000000004', 'h0000002-0000-0000-0000-000000000002', 'active',  'read'),
  ('p0000015-0000-0000-0000-000000000015', 'd0000006-0000-0000-0000-000000000006', 'h0000003-0000-0000-0000-000000000003', 'active',  'full'),
  ('p0000016-0000-0000-0000-000000000016', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001', 'active',  'read'),
  ('p0000017-0000-0000-0000-000000000017', 'd0000008-0000-0000-0000-000000000008', 'h0000001-0000-0000-0000-000000000001', 'active',  'full'),
  ('p0000018-0000-0000-0000-000000000018', 'd0000004-0000-0000-0000-000000000004', 'h0000002-0000-0000-0000-000000000002', 'active',  'read'),
  ('p0000019-0000-0000-0000-000000000019', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001', 'active',  'full'),
  ('p0000020-0000-0000-0000-000000000020', 'd0000004-0000-0000-0000-000000000004', 'h0000002-0000-0000-0000-000000000002', 'active',  'full');

-- ========================================
-- VISITS (30 total — 3 existing + 27 new)
-- ========================================
INSERT INTO visits (id, patient_id, doctor_id, hospital_id, visited_at, chief_complaint, diagnosis, notes) VALUES
  -- Existing 3
  ('v0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2024-12-01 10:00:00+05:30', 'Chest pain on exertion', 'Stable angina', 'Prescribed beta-blocker. Follow-up in 2 weeks.'),
  ('v0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-01-15 11:00:00+05:30', 'Routine checkup', 'Hypertension - controlled', 'BP 130/85. Continue current medications.'),
  ('v0000003-0000-0000-0000-000000000003', 'p0000002-0000-0000-0000-000000000002', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-02-10 09:30:00+05:30', 'Elevated blood sugar', 'Diabetes Type 2 - suboptimal control', 'HbA1c 7.8%. Adjusted metformin dose.'),
  -- New 27
  ('v0000004-0000-0000-0000-000000000004', 'p0000004-0000-0000-0000-000000000004', 'd0000008-0000-0000-0000-000000000008', 'h0000001-0000-0000-0000-000000000001',
   '2025-01-05 14:00:00+05:30', 'Wheezing and breathlessness', 'Acute asthma exacerbation', 'Nebulization given. Peak flow improved from 250 to 380. Added inhaled corticosteroid.'),
  ('v0000005-0000-0000-0000-000000000005', 'p0000005-0000-0000-0000-000000000005', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2025-01-10 10:30:00+05:30', 'Palpitations and dizziness', 'Paroxysmal atrial fibrillation', 'ECG shows intermittent AF. Started on anticoagulation. Echocardiogram ordered.'),
  ('v0000006-0000-0000-0000-000000000006', 'p0000006-0000-0000-0000-000000000006', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003',
   '2025-01-12 11:00:00+05:30', 'Fatigue, weight gain, cold intolerance', 'Hypothyroidism', 'TSH elevated at 12.4. Started levothyroxine 50mcg. Recheck in 6 weeks.'),
  ('v0000007-0000-0000-0000-000000000007', 'p0000007-0000-0000-0000-000000000007', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2025-01-18 09:00:00+05:30', 'Chest tightness, exertional dyspnea', 'Unstable angina', 'Troponin negative. ECG ST depression in V4-V6. Admitted for observation. Angiography planned.'),
  ('v0000008-0000-0000-0000-000000000008', 'p0000007-0000-0000-0000-000000000007', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003',
   '2025-01-25 15:00:00+05:30', 'Follow-up for diabetes management', 'Diabetes Type 2 - uncontrolled', 'HbA1c 9.2%. Added insulin glargine at bedtime. Reinforced dietary counselling.'),
  ('v0000009-0000-0000-0000-000000000009', 'p0000008-0000-0000-0000-000000000008', 'd0000009-0000-0000-0000-000000000009', 'h0000002-0000-0000-0000-000000000002',
   '2025-02-01 10:00:00+05:30', 'Irregular periods, acne', 'Polycystic ovary syndrome workup', 'Ultrasound and hormonal panel ordered. BMI 27.3. Lifestyle counselling initiated.'),
  ('v0000010-0000-0000-0000-000000000010', 'p0000009-0000-0000-0000-000000000009', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-02-05 11:30:00+05:30', 'Persistent heartburn and acid reflux', 'GERD - moderate', 'Started on pantoprazole 40mg. Advised dietary modifications and elevation of bed head.'),
  ('v0000011-0000-0000-0000-000000000011', 'p0000010-0000-0000-0000-000000000010', 'd0000003-0000-0000-0000-000000000003', 'h0000002-0000-0000-0000-000000000002',
   '2025-02-08 14:30:00+05:30', 'Itchy rash on forearms for 2 weeks', 'Contact dermatitis', 'Prescribed topical betamethasone and oral cetirizine. Avoid known irritants.'),
  ('v0000012-0000-0000-0000-000000000012', 'p0000011-0000-0000-0000-000000000011', 'd0000006-0000-0000-0000-000000000006', 'h0000003-0000-0000-0000-000000000003',
   '2025-02-12 10:00:00+05:30', 'Recurrent headaches with visual aura', 'Migraine with aura', 'MRI brain normal. Started on propranolol prophylaxis. Sumatriptan for acute attacks.'),
  ('v0000013-0000-0000-0000-000000000013', 'p0000012-0000-0000-0000-000000000012', 'd0000009-0000-0000-0000-000000000009', 'h0000002-0000-0000-0000-000000000002',
   '2025-02-14 09:00:00+05:30', 'Heavy menstrual bleeding', 'Menorrhagia secondary to PCOS', 'Ultrasound shows bulky uterus. Started on tranexamic acid and OCP. Iron supplementation.'),
  ('v0000014-0000-0000-0000-000000000014', 'p0000013-0000-0000-0000-000000000013', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003',
   '2025-02-18 11:00:00+05:30', 'Numbness and tingling in feet', 'Diabetic peripheral neuropathy', 'Monofilament test positive. Started pregabalin 75mg. Optimized glycemic control.'),
  ('v0000015-0000-0000-0000-000000000015', 'p0000013-0000-0000-0000-000000000013', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-02-20 15:30:00+05:30', 'Routine BP monitoring', 'Hypertension - stage 2', 'BP 158/96. Amlodipine increased to 10mg. 24-hour ABPM suggested.'),
  ('v0000016-0000-0000-0000-000000000016', 'p0000014-0000-0000-0000-000000000014', 'd0000004-0000-0000-0000-000000000004', 'h0000002-0000-0000-0000-000000000002',
   '2025-02-22 10:00:00+05:30', 'Right knee pain after sports injury', 'ACL sprain grade 2', 'MRI confirms partial ACL tear. Conservative management with physiotherapy. Knee brace advised.'),
  ('v0000017-0000-0000-0000-000000000017', 'p0000015-0000-0000-0000-000000000015', 'd0000006-0000-0000-0000-000000000006', 'h0000003-0000-0000-0000-000000000003',
   '2025-02-25 14:00:00+05:30', 'Severe headache with nausea', 'Migraine without aura', 'CT head normal. Started on prophylactic topiramate. Triptan for acute relief.'),
  ('v0000018-0000-0000-0000-000000000018', 'p0000016-0000-0000-0000-000000000016', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-01 09:30:00+05:30', 'Weakness and easy fatiguability', 'Iron deficiency anemia', 'Hb 8.2 g/dL. Ferritin 8 ng/mL. Started on oral iron and vitamin C. GI evaluation if no response.'),
  ('v0000019-0000-0000-0000-000000000019', 'p0000017-0000-0000-0000-000000000017', 'd0000008-0000-0000-0000-000000000008', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-03 11:00:00+05:30', 'Chronic cough with sputum, exertional dyspnea', 'COPD exacerbation', 'SpO2 92%. Chest X-ray hyperinflated. Nebulization + oral steroids. Smoking cessation counselled.'),
  ('v0000020-0000-0000-0000-000000000020', 'p0000018-0000-0000-0000-000000000018', 'd0000004-0000-0000-0000-000000000004', 'h0000002-0000-0000-0000-000000000002',
   '2025-03-05 10:30:00+05:30', 'Bilateral hand joint pain and stiffness', 'Rheumatoid arthritis flare', 'Swollen MCP and PIP joints. ESR 48, CRP 3.2. DMARD adjustment. Methotrexate dose increased.'),
  ('v0000021-0000-0000-0000-000000000021', 'p0000019-0000-0000-0000-000000000019', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-07 09:00:00+05:30', 'Breathlessness on lying flat, swollen ankles', 'Congestive heart failure - NYHA III', 'BNP elevated. Echo shows EF 30%. Optimized diuretics and ACE inhibitor. Cardiology follow-up weekly.'),
  ('v0000022-0000-0000-0000-000000000022', 'p0000020-0000-0000-0000-000000000020', 'd0000004-0000-0000-0000-000000000004', 'h0000002-0000-0000-0000-000000000002',
   '2025-03-08 14:00:00+05:30', 'Morning stiffness in knees lasting >1 hour', 'Rheumatoid arthritis - active', 'DAS28 score 4.8. Anti-CCP positive. Continue methotrexate + hydroxychloroquine.'),
  ('v0000023-0000-0000-0000-000000000023', 'p0000003-0000-0000-0000-000000000003', 'd0000005-0000-0000-0000-000000000005', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-10 10:00:00+05:30', 'Fever and sore throat for 3 days', 'Acute pharyngitis - viral', 'Rapid strep test negative. Symptomatic treatment with paracetamol and warm gargles.'),
  ('v0000024-0000-0000-0000-000000000024', 'p0000005-0000-0000-0000-000000000005', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-12 11:30:00+05:30', 'Follow-up after echo and Holter', 'Paroxysmal AF - controlled on medication', 'Echo EF 55%. Holter shows 3 episodes AF. Rate control adequate. Continue current regimen.'),
  ('v0000025-0000-0000-0000-000000000025', 'p0000011-0000-0000-0000-000000000011', 'd0000006-0000-0000-0000-000000000006', 'h0000003-0000-0000-0000-000000000003',
   '2025-03-14 09:30:00+05:30', 'Tremor in right hand, slowed movements', 'Early Parkinsonism - evaluation', 'Resting tremor noted. Cogwheel rigidity present. MRI and DaTscan ordered. Started on low-dose levodopa.'),
  ('v0000026-0000-0000-0000-000000000026', 'p0000009-0000-0000-0000-000000000009', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-15 10:00:00+05:30', 'Follow-up for GERD', 'GERD - improving', 'Symptoms 60% better. Continue PPI for 4 more weeks. Endoscopy if symptoms persist.'),
  ('v0000027-0000-0000-0000-000000000027', 'p0000006-0000-0000-0000-000000000006', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003',
   '2025-03-18 11:00:00+05:30', 'Follow-up for hypothyroidism', 'Hypothyroidism - improving', 'TSH improved to 6.8 from 12.4. Increased levothyroxine to 75mcg. Recheck in 6 weeks.'),
  ('v0000028-0000-0000-0000-000000000028', 'p0000015-0000-0000-0000-000000000015', 'd0000006-0000-0000-0000-000000000006', 'h0000003-0000-0000-0000-000000000003',
   '2025-03-20 14:30:00+05:30', 'Migraine frequency check', 'Migraine - improved on prophylaxis', 'Frequency reduced from 8 to 3 per month. Continue topiramate. Added magnesium supplementation.'),
  ('v0000029-0000-0000-0000-000000000029', 'p0000016-0000-0000-0000-000000000016', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-22 09:00:00+05:30', 'Follow-up for anemia', 'Iron deficiency anemia - responding', 'Hb improved to 9.8 from 8.2. Continue oral iron for 3 more months. Recheck ferritin.'),
  ('v0000030-0000-0000-0000-000000000030', 'p0000019-0000-0000-0000-000000000019', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-25 10:30:00+05:30', 'Follow-up for heart failure', 'CHF NYHA III - stable on treatment', 'Weight stable. No orthopnea. Ankle edema minimal. Continue current regimen. BNP trending down.');

-- ========================================
-- LAB REPORTS (50 total — 3 existing + 47 new)
-- ========================================
INSERT INTO lab_reports (id, patient_id, visit_id, report_type, report_date, status, ai_summary, lab_name) VALUES
  -- Existing 3
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', NULL, 'CBC', '2025-01-15', 'ready',
   'Complete Blood Count within normal limits. Slight elevation in WBC count (11.2) which may indicate minor infection or stress response.', 'City Lab Services'),
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', NULL, 'Lipid Profile', '2025-01-15', 'ready',
   'Elevated LDL cholesterol at 145 mg/dL. Total cholesterol borderline high. HDL within normal range. Consider dietary modifications and statin therapy.', 'City Lab Services'),
  ('r0000003-0000-0000-0000-000000000003', 'p0000002-0000-0000-0000-000000000002', NULL, 'HbA1c', '2025-02-10', 'ready',
   'HbA1c at 7.8% indicates suboptimal glycemic control. Fasting glucose 156 mg/dL. Recommend medication adjustment and lifestyle changes.', 'MedTest Labs'),

  -- Report 4: CBC for Sneha Reddy
  ('r0000004-0000-0000-0000-000000000004', 'p0000004-0000-0000-0000-000000000004', 'v0000004-0000-0000-0000-000000000004', 'CBC', '2025-01-05', 'ready',
   'CBC shows eosinophilia (8.2%) consistent with allergic/asthmatic condition. Other parameters within normal limits.', 'City Lab Services'),

  -- Report 5: Lipid Profile for Vikram Deshmukh
  ('r0000005-0000-0000-0000-000000000005', 'p0000005-0000-0000-0000-000000000005', 'v0000005-0000-0000-0000-000000000005', 'Lipid Profile', '2025-01-10', 'ready',
   'Severely elevated LDL at 188 mg/dL. Total cholesterol 278. Triglycerides 220. High cardiovascular risk. Statin therapy strongly recommended.', 'City Lab Services'),

  -- Report 6: Thyroid Panel for Anita Joshi
  ('r0000006-0000-0000-0000-000000000006', 'p0000006-0000-0000-0000-000000000006', 'v0000006-0000-0000-0000-000000000006', 'Thyroid Panel', '2025-01-12', 'ready',
   'TSH markedly elevated at 12.4 mIU/L. Free T4 low at 0.6 ng/dL. Consistent with primary hypothyroidism. Initiate replacement therapy.', 'Fortis Diagnostics'),

  -- Report 7: Metabolic Panel for Suresh Nair
  ('r0000007-0000-0000-0000-000000000007', 'p0000007-0000-0000-0000-000000000007', 'v0000007-0000-0000-0000-000000000007', 'Comprehensive Metabolic Panel', '2025-01-18', 'ready',
   'Fasting glucose 210 mg/dL. Creatinine 1.4 mg/dL (eGFR 52). Potassium 5.2 mEq/L. Suggestive of diabetic nephropathy. Nephrology referral advised.', 'City Lab Services'),

  -- Report 8: HbA1c for Suresh Nair
  ('r0000008-0000-0000-0000-000000000008', 'p0000007-0000-0000-0000-000000000007', 'v0000008-0000-0000-0000-000000000008', 'HbA1c', '2025-01-25', 'ready',
   'HbA1c 9.2% indicates poor glycemic control. Significant risk of microvascular complications. Intensification of therapy warranted.', 'Fortis Diagnostics'),

  -- Report 9: CBC for Kavitha Menon
  ('r0000009-0000-0000-0000-000000000009', 'p0000008-0000-0000-0000-000000000008', 'v0000009-0000-0000-0000-000000000009', 'CBC', '2025-02-01', 'ready',
   'CBC within normal limits. No abnormalities detected.', 'Apollo Diagnostics'),

  -- Report 10: Liver Function Test for Deepak Verma
  ('r0000010-0000-0000-0000-000000000010', 'p0000009-0000-0000-0000-000000000009', 'v0000010-0000-0000-0000-000000000010', 'Liver Function Test', '2025-02-05', 'ready',
   'ALT mildly elevated at 52 U/L. AST normal. Bilirubin normal. May be related to PPI use or fatty liver. Ultrasound abdomen recommended.', 'City Lab Services'),

  -- Report 11: CBC for Meera Iyer
  ('r0000011-0000-0000-0000-000000000011', 'p0000010-0000-0000-0000-000000000010', NULL, 'CBC', '2025-02-08', 'ready',
   'All parameters within normal limits. Healthy blood picture.', 'Apollo Diagnostics'),

  -- Report 12: Metabolic Panel for Arjun Malhotra
  ('r0000012-0000-0000-0000-000000000012', 'p0000011-0000-0000-0000-000000000011', 'v0000012-0000-0000-0000-000000000012', 'Comprehensive Metabolic Panel', '2025-02-12', 'ready',
   'Creatinine 2.8 mg/dL, eGFR 28. BUN 42. Potassium 5.5. Stage 4 CKD. Urgent nephrology review required.', 'Fortis Diagnostics'),

  -- Report 13: Hormonal Panel for Pooja Saxena
  ('r0000013-0000-0000-0000-000000000013', 'p0000012-0000-0000-0000-000000000012', 'v0000013-0000-0000-0000-000000000013', 'Hormonal Panel', '2025-02-14', 'ready',
   'LH:FSH ratio 2.8:1 (elevated). Testosterone 68 ng/dL (elevated). DHEAS elevated. Consistent with PCOS. Insulin resistance screening advised.', 'Apollo Diagnostics'),

  -- Report 14: HbA1c for Ramesh Yadav
  ('r0000014-0000-0000-0000-000000000014', 'p0000013-0000-0000-0000-000000000013', 'v0000014-0000-0000-0000-000000000014', 'HbA1c', '2025-02-18', 'ready',
   'HbA1c 8.5%. Suboptimal control despite dual oral therapy. Consider adding basal insulin. Neuropathy screening positive.', 'Fortis Diagnostics'),

  -- Report 15: Lipid Profile for Ramesh Yadav
  ('r0000015-0000-0000-0000-000000000015', 'p0000013-0000-0000-0000-000000000013', 'v0000015-0000-0000-0000-000000000015', 'Lipid Profile', '2025-02-20', 'ready',
   'Total cholesterol 242. LDL 158. HDL 38 (low). Triglycerides 230 (high). High cardiovascular risk. Statin indicated.', 'City Lab Services'),

  -- Report 16: CBC for Divya Kulkarni
  ('r0000016-0000-0000-0000-000000000016', 'p0000014-0000-0000-0000-000000000014', NULL, 'CBC', '2025-02-22', 'ready',
   'Mild leukocytosis (12.1) likely reactive. Otherwise normal blood counts.', 'Apollo Diagnostics'),

  -- Report 17: Thyroid Panel for Lakshmi Pillai
  ('r0000017-0000-0000-0000-000000000017', 'p0000016-0000-0000-0000-000000000016', 'v0000018-0000-0000-0000-000000000018', 'Thyroid Panel', '2025-03-01', 'ready',
   'Thyroid function within normal limits. TSH 2.1, Free T4 1.2, Free T3 3.1. No thyroid dysfunction detected.', 'City Lab Services'),

  -- Report 18: CBC for Lakshmi Pillai
  ('r0000018-0000-0000-0000-000000000018', 'p0000016-0000-0000-0000-000000000016', 'v0000018-0000-0000-0000-000000000018', 'CBC', '2025-03-01', 'ready',
   'Hb 8.2 g/dL. MCV 68 fL (microcytic). Ferritin 8 ng/mL. Iron 28 mcg/dL. Classic iron deficiency anemia pattern.', 'City Lab Services'),

  -- Report 19: Liver Function Test for Sanjay Bhatt
  ('r0000019-0000-0000-0000-000000000019', 'p0000017-0000-0000-0000-000000000017', 'v0000019-0000-0000-0000-000000000019', 'Liver Function Test', '2025-03-03', 'ready',
   'ALT 38, AST 42, ALP 110. Albumin 3.2 (slightly low). Bilirubin normal. Borderline findings; monitor.', 'City Lab Services'),

  -- Report 20: CBC for Sanjay Bhatt
  ('r0000020-0000-0000-0000-000000000020', 'p0000017-0000-0000-0000-000000000017', 'v0000019-0000-0000-0000-000000000019', 'CBC', '2025-03-03', 'ready',
   'Hb 13.8. WBC 9.2. Polycythemia absent. Platelet count normal. No significant abnormality.', 'City Lab Services'),

  -- Report 21: Metabolic Panel for Nisha Agarwal
  ('r0000021-0000-0000-0000-000000000021', 'p0000018-0000-0000-0000-000000000018', 'v0000020-0000-0000-0000-000000000020', 'Comprehensive Metabolic Panel', '2025-03-05', 'ready',
   'All parameters within normal limits. Glucose 88, Creatinine 0.8, Electrolytes balanced. Healthy metabolic profile.', 'Apollo Diagnostics'),

  -- Report 22: ESR/CRP for Nisha Agarwal (RA workup)
  ('r0000022-0000-0000-0000-000000000022', 'p0000018-0000-0000-0000-000000000018', 'v0000020-0000-0000-0000-000000000020', 'Inflammatory Markers', '2025-03-05', 'ready',
   'ESR 48 mm/hr (elevated). CRP 3.2 mg/dL (elevated). RF positive. Anti-CCP 85 U/mL (strongly positive). Confirms RA diagnosis.', 'Apollo Diagnostics'),

  -- Report 23: BNP + Metabolic Panel for Rajendra Prasad
  ('r0000023-0000-0000-0000-000000000023', 'p0000019-0000-0000-0000-000000000019', 'v0000021-0000-0000-0000-000000000021', 'Comprehensive Metabolic Panel', '2025-03-07', 'ready',
   'Creatinine 1.6 (eGFR 42). BUN 38. Sodium 134 (mildly low). BNP 890 pg/mL (markedly elevated). Consistent with decompensated heart failure.', 'City Lab Services'),

  -- Report 24: Lipid Profile for Rajendra Prasad
  ('r0000024-0000-0000-0000-000000000024', 'p0000019-0000-0000-0000-000000000019', 'v0000021-0000-0000-0000-000000000021', 'Lipid Profile', '2025-03-07', 'ready',
   'Total cholesterol 198. LDL 118. HDL 42. Triglycerides 190 (borderline high). On statin therapy - adequate response.', 'City Lab Services'),

  -- Report 25: ESR/CRP for Fatima Sheikh
  ('r0000025-0000-0000-0000-000000000025', 'p0000020-0000-0000-0000-000000000020', 'v0000022-0000-0000-0000-000000000022', 'Inflammatory Markers', '2025-03-08', 'ready',
   'ESR 52. CRP 4.1. RF 68 IU/mL. Anti-CCP 120 U/mL. Active inflammatory disease. DAS28 score elevated.', 'Apollo Diagnostics'),

  -- Report 26: CBC for Amit Kumar
  ('r0000026-0000-0000-0000-000000000026', 'p0000003-0000-0000-0000-000000000003', 'v0000023-0000-0000-0000-000000000023', 'CBC', '2025-03-10', 'ready',
   'Mild lymphocytosis consistent with viral infection. WBC 10.8, Lymphocytes 48%. Otherwise normal.', 'City Lab Services'),

  -- Report 27: Lipid Profile follow-up for Vikram
  ('r0000027-0000-0000-0000-000000000027', 'p0000005-0000-0000-0000-000000000005', 'v0000024-0000-0000-0000-000000000024', 'Lipid Profile', '2025-03-12', 'ready',
   'On statin 8 weeks: Total cholesterol 218 (down from 278). LDL 132 (down from 188). Good response. Continue therapy.', 'City Lab Services'),

  -- Report 28: Metabolic Panel for Arjun Malhotra follow-up
  ('r0000028-0000-0000-0000-000000000028', 'p0000011-0000-0000-0000-000000000011', 'v0000025-0000-0000-0000-000000000025', 'Comprehensive Metabolic Panel', '2025-03-14', 'ready',
   'Creatinine stable at 2.9. eGFR 27. Potassium 5.3. Stable CKD stage 4. Continue nephroprotective measures.', 'Fortis Diagnostics'),

  -- Report 29: Thyroid Panel follow-up for Anita Joshi
  ('r0000029-0000-0000-0000-000000000029', 'p0000006-0000-0000-0000-000000000006', 'v0000027-0000-0000-0000-000000000027', 'Thyroid Panel', '2025-03-18', 'ready',
   'TSH improved to 6.8 from 12.4 on levothyroxine 50mcg. Free T4 0.9 (improving). Dose increase recommended.', 'Fortis Diagnostics'),

  -- Report 30: CBC for Lakshmi Pillai follow-up
  ('r0000030-0000-0000-0000-000000000030', 'p0000016-0000-0000-0000-000000000016', 'v0000029-0000-0000-0000-000000000029', 'CBC', '2025-03-22', 'ready',
   'Hb improved to 9.8 from 8.2. MCV 72 (improving). Reticulocyte count 2.8% indicating bone marrow response. Continue iron therapy.', 'City Lab Services'),

  -- Report 31: BNP follow-up for Rajendra Prasad
  ('r0000031-0000-0000-0000-000000000031', 'p0000019-0000-0000-0000-000000000019', 'v0000030-0000-0000-0000-000000000030', 'Comprehensive Metabolic Panel', '2025-03-25', 'ready',
   'BNP 580 (improved from 890). Creatinine 1.5. Sodium 136. Electrolytes stable. Heart failure responding to treatment.', 'City Lab Services'),

  -- Reports 32-37: Additional CBC reports for various patients
  ('r0000032-0000-0000-0000-000000000032', 'p0000002-0000-0000-0000-000000000002', NULL, 'CBC', '2025-02-10', 'ready',
   'CBC normal. Hb 12.8 g/dL. WBC 7.4. Platelets 265. No abnormality detected.', 'MedTest Labs'),
  ('r0000033-0000-0000-0000-000000000033', 'p0000005-0000-0000-0000-000000000005', NULL, 'CBC', '2025-01-10', 'ready',
   'Hb 15.2. Slightly elevated hematocrit at 48%. WBC and platelets normal.', 'City Lab Services'),
  ('r0000034-0000-0000-0000-000000000034', 'p0000009-0000-0000-0000-000000000009', NULL, 'CBC', '2025-02-05', 'ready',
   'CBC within normal limits. Hb 14.1. WBC 6.8. Platelets 230.', 'City Lab Services'),
  ('r0000035-0000-0000-0000-000000000035', 'p0000012-0000-0000-0000-000000000012', NULL, 'CBC', '2025-02-14', 'ready',
   'Hb 10.2 g/dL (low). MCV 78. Suggestive of early iron deficiency. Iron studies recommended.', 'Apollo Diagnostics'),
  ('r0000036-0000-0000-0000-000000000036', 'p0000015-0000-0000-0000-000000000015', NULL, 'CBC', '2025-02-25', 'ready',
   'CBC normal. Hb 14.8. WBC 7.2. Platelets 198. No abnormality.', 'Fortis Diagnostics'),
  ('r0000037-0000-0000-0000-000000000037', 'p0000020-0000-0000-0000-000000000020', NULL, 'CBC', '2025-03-08', 'ready',
   'Hb 11.4 g/dL (mildly low). Mild normocytic anemia. May be related to chronic disease. WBC and platelets normal.', 'Apollo Diagnostics'),

  -- Reports 38-42: Metabolic Panels
  ('r0000038-0000-0000-0000-000000000038', 'p0000001-0000-0000-0000-000000000001', NULL, 'Comprehensive Metabolic Panel', '2025-01-15', 'ready',
   'Glucose 98. Creatinine 1.0. eGFR >90. Electrolytes normal. Liver enzymes normal. Healthy metabolic profile.', 'City Lab Services'),
  ('r0000039-0000-0000-0000-000000000039', 'p0000004-0000-0000-0000-000000000004', NULL, 'Comprehensive Metabolic Panel', '2025-01-05', 'ready',
   'All parameters within normal range. Glucose 92. Creatinine 0.7. No metabolic derangement.', 'City Lab Services'),
  ('r0000040-0000-0000-0000-000000000040', 'p0000010-0000-0000-0000-000000000010', NULL, 'Comprehensive Metabolic Panel', '2025-02-08', 'ready',
   'Normal metabolic panel. Glucose 86. Creatinine 0.6. Liver enzymes within range. Healthy young adult profile.', 'Apollo Diagnostics'),
  ('r0000041-0000-0000-0000-000000000041', 'p0000014-0000-0000-0000-000000000014', NULL, 'Comprehensive Metabolic Panel', '2025-02-22', 'ready',
   'Normal metabolic panel. Glucose 90. Creatinine 0.7. Electrolytes balanced.', 'Apollo Diagnostics'),
  ('r0000042-0000-0000-0000-000000000042', 'p0000008-0000-0000-0000-000000000008', NULL, 'Comprehensive Metabolic Panel', '2025-02-01', 'ready',
   'Glucose 94. Creatinine 0.8. All liver enzymes normal. Electrolytes balanced. Healthy profile.', 'Apollo Diagnostics'),

  -- Reports 43-46: Liver Function Tests
  ('r0000043-0000-0000-0000-000000000043', 'p0000007-0000-0000-0000-000000000007', NULL, 'Liver Function Test', '2025-01-25', 'ready',
   'ALT 28, AST 32, ALP 95. Bilirubin 0.8. Albumin 3.8. Normal liver function despite diabetes medications.', 'Fortis Diagnostics'),
  ('r0000044-0000-0000-0000-000000000044', 'p0000013-0000-0000-0000-000000000013', NULL, 'Liver Function Test', '2025-02-18', 'ready',
   'ALT 45, AST 38, ALP 105. Albumin 3.6. Mildly elevated ALT, likely related to fatty liver. Ultrasound advised.', 'Fortis Diagnostics'),
  ('r0000045-0000-0000-0000-000000000045', 'p0000005-0000-0000-0000-000000000005', NULL, 'Liver Function Test', '2025-01-10', 'ready',
   'ALT 62 (elevated), AST 48 (mildly elevated). ALP normal. Fatty liver suspected. Lifestyle modifications needed.', 'City Lab Services'),
  ('r0000046-0000-0000-0000-000000000046', 'p0000011-0000-0000-0000-000000000011', NULL, 'Liver Function Test', '2025-02-12', 'ready',
   'ALT 34, AST 30, ALP 88. Bilirubin 0.9. Albumin 3.4 (borderline). Normal liver function. Low albumin may be renal.', 'Fortis Diagnostics'),

  -- Reports 47-50: More thyroid and lipid reports
  ('r0000047-0000-0000-0000-000000000047', 'p0000016-0000-0000-0000-000000000016', NULL, 'Thyroid Panel', '2025-03-22', 'ready',
   'TSH 2.4. Free T4 1.1. Free T3 2.9. Euthyroid. Anemia not thyroid related.', 'City Lab Services'),
  ('r0000048-0000-0000-0000-000000000048', 'p0000007-0000-0000-0000-000000000007', NULL, 'Lipid Profile', '2025-01-25', 'ready',
   'Total cholesterol 258. LDL 168. HDL 35 (low). Triglycerides 275 (high). Very high cardiovascular risk. Aggressive statin therapy needed.', 'Fortis Diagnostics'),
  ('r0000049-0000-0000-0000-000000000049', 'p0000017-0000-0000-0000-000000000017', NULL, 'Lipid Profile', '2025-03-03', 'ready',
   'Total cholesterol 210. LDL 125. HDL 45. Triglycerides 200. Borderline high. Continue current statin.', 'City Lab Services'),
  ('r0000050-0000-0000-0000-000000000050', 'p0000003-0000-0000-0000-000000000003', NULL, 'Lipid Profile', '2025-03-10', 'ready',
   'Total cholesterol 185. LDL 105. HDL 52. Triglycerides 140. Within acceptable limits for age.', 'City Lab Services');

-- ========================================
-- BIOMARKERS
-- ========================================

-- Existing biomarkers for report 1 (CBC - Rahul Sharma)
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 'Haemoglobin',    14.5,  'g/dL',     13.0, 17.0, '2025-01-15 00:00:00+05:30'),
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 'WBC Count',      11.2,  '10^3/uL',   4.0, 11.0, '2025-01-15 00:00:00+05:30'),
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 'Platelet Count', 250,   '10^3/uL', 150,   400,   '2025-01-15 00:00:00+05:30'),
  ('r0000001-0000-0000-0000-000000000001', 'p0000001-0000-0000-0000-000000000001', 'RBC Count',        5.1, '10^6/uL',   4.5,   5.5, '2025-01-15 00:00:00+05:30');

-- Existing biomarkers for report 2 (Lipid Profile - Rahul Sharma)
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', 'Total Cholesterol', 235, 'mg/dL', 0,   200, '2025-01-15 00:00:00+05:30'),
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', 'LDL Cholesterol',  145, 'mg/dL', 0,   100, '2025-01-15 00:00:00+05:30'),
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', 'HDL Cholesterol',   52, 'mg/dL', 40,   60, '2025-01-15 00:00:00+05:30'),
  ('r0000002-0000-0000-0000-000000000002', 'p0000001-0000-0000-0000-000000000001', 'Triglycerides',    190, 'mg/dL', 0,   150, '2025-01-15 00:00:00+05:30');

-- Existing biomarkers for report 3 (HbA1c - Priya Patel)
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000003-0000-0000-0000-000000000003', 'p0000002-0000-0000-0000-000000000002', 'HbA1c',           7.8, '%',     4.0,   5.7, '2025-02-10 00:00:00+05:30'),
  ('r0000003-0000-0000-0000-000000000003', 'p0000002-0000-0000-0000-000000000002', 'Fasting Glucose', 156,  'mg/dL', 70,   100,  '2025-02-10 00:00:00+05:30');

-- Report 4: CBC for Sneha Reddy
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000004-0000-0000-0000-000000000004', 'p0000004-0000-0000-0000-000000000004', 'Haemoglobin',    12.8, 'g/dL',    12.0, 16.0, '2025-01-05 00:00:00+05:30'),
  ('r0000004-0000-0000-0000-000000000004', 'p0000004-0000-0000-0000-000000000004', 'WBC Count',       8.4, '10^3/uL',  4.0, 11.0, '2025-01-05 00:00:00+05:30'),
  ('r0000004-0000-0000-0000-000000000004', 'p0000004-0000-0000-0000-000000000004', 'Eosinophils',     8.2, '%',        1.0,  4.0, '2025-01-05 00:00:00+05:30'),
  ('r0000004-0000-0000-0000-000000000004', 'p0000004-0000-0000-0000-000000000004', 'Platelet Count', 285,  '10^3/uL', 150,  400,  '2025-01-05 00:00:00+05:30');

-- Report 5: Lipid Profile for Vikram Deshmukh
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000005-0000-0000-0000-000000000005', 'p0000005-0000-0000-0000-000000000005', 'Total Cholesterol', 278, 'mg/dL', 0,   200, '2025-01-10 00:00:00+05:30'),
  ('r0000005-0000-0000-0000-000000000005', 'p0000005-0000-0000-0000-000000000005', 'LDL Cholesterol',  188, 'mg/dL', 0,   100, '2025-01-10 00:00:00+05:30'),
  ('r0000005-0000-0000-0000-000000000005', 'p0000005-0000-0000-0000-000000000005', 'HDL Cholesterol',   38, 'mg/dL', 40,   60, '2025-01-10 00:00:00+05:30'),
  ('r0000005-0000-0000-0000-000000000005', 'p0000005-0000-0000-0000-000000000005', 'Triglycerides',    220, 'mg/dL', 0,   150, '2025-01-10 00:00:00+05:30');

-- Report 6: Thyroid Panel for Anita Joshi
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000006-0000-0000-0000-000000000006', 'p0000006-0000-0000-0000-000000000006', 'TSH',      12.4,  'mIU/L',  0.4,  4.0, '2025-01-12 00:00:00+05:30'),
  ('r0000006-0000-0000-0000-000000000006', 'p0000006-0000-0000-0000-000000000006', 'Free T4',   0.6,  'ng/dL',  0.8,  1.8, '2025-01-12 00:00:00+05:30'),
  ('r0000006-0000-0000-0000-000000000006', 'p0000006-0000-0000-0000-000000000006', 'Free T3',   1.8,  'pg/mL',  2.3,  4.2, '2025-01-12 00:00:00+05:30');

-- Report 7: Metabolic Panel for Suresh Nair
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000007-0000-0000-0000-000000000007', 'p0000007-0000-0000-0000-000000000007', 'Fasting Glucose', 210,  'mg/dL',  70,  100, '2025-01-18 00:00:00+05:30'),
  ('r0000007-0000-0000-0000-000000000007', 'p0000007-0000-0000-0000-000000000007', 'Creatinine',       1.4, 'mg/dL',  0.7,  1.2, '2025-01-18 00:00:00+05:30'),
  ('r0000007-0000-0000-0000-000000000007', 'p0000007-0000-0000-0000-000000000007', 'BUN',             38,   'mg/dL',   7,   20, '2025-01-18 00:00:00+05:30'),
  ('r0000007-0000-0000-0000-000000000007', 'p0000007-0000-0000-0000-000000000007', 'Potassium',        5.2, 'mEq/L',  3.5,  5.0, '2025-01-18 00:00:00+05:30'),
  ('r0000007-0000-0000-0000-000000000007', 'p0000007-0000-0000-0000-000000000007', 'Sodium',         138,   'mEq/L', 136,  145,  '2025-01-18 00:00:00+05:30'),
  ('r0000007-0000-0000-0000-000000000007', 'p0000007-0000-0000-0000-000000000007', 'eGFR',            52,   'mL/min', 90,  120,  '2025-01-18 00:00:00+05:30');

-- Report 8: HbA1c for Suresh Nair
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000008-0000-0000-0000-000000000008', 'p0000007-0000-0000-0000-000000000007', 'HbA1c',           9.2, '%',     4.0, 5.7, '2025-01-25 00:00:00+05:30'),
  ('r0000008-0000-0000-0000-000000000008', 'p0000007-0000-0000-0000-000000000007', 'Fasting Glucose', 198,  'mg/dL', 70,  100, '2025-01-25 00:00:00+05:30');

-- Report 10: Liver Function Test for Deepak Verma
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000010-0000-0000-0000-000000000010', 'p0000009-0000-0000-0000-000000000009', 'ALT',        52,  'U/L',    7,   56, '2025-02-05 00:00:00+05:30'),
  ('r0000010-0000-0000-0000-000000000010', 'p0000009-0000-0000-0000-000000000009', 'AST',        28,  'U/L',   10,   40, '2025-02-05 00:00:00+05:30'),
  ('r0000010-0000-0000-0000-000000000010', 'p0000009-0000-0000-0000-000000000009', 'ALP',        78,  'U/L',   44,  147, '2025-02-05 00:00:00+05:30'),
  ('r0000010-0000-0000-0000-000000000010', 'p0000009-0000-0000-0000-000000000009', 'Total Bilirubin', 0.8, 'mg/dL', 0.1, 1.2, '2025-02-05 00:00:00+05:30'),
  ('r0000010-0000-0000-0000-000000000010', 'p0000009-0000-0000-0000-000000000009', 'Albumin',     4.2, 'g/dL',  3.5,  5.0, '2025-02-05 00:00:00+05:30');

-- Report 12: Metabolic Panel for Arjun Malhotra (CKD)
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000012-0000-0000-0000-000000000012', 'p0000011-0000-0000-0000-000000000011', 'Creatinine',       2.8, 'mg/dL',  0.7,  1.2, '2025-02-12 00:00:00+05:30'),
  ('r0000012-0000-0000-0000-000000000012', 'p0000011-0000-0000-0000-000000000011', 'BUN',             42,   'mg/dL',   7,   20,   '2025-02-12 00:00:00+05:30'),
  ('r0000012-0000-0000-0000-000000000012', 'p0000011-0000-0000-0000-000000000011', 'eGFR',            28,   'mL/min', 90,  120,   '2025-02-12 00:00:00+05:30'),
  ('r0000012-0000-0000-0000-000000000012', 'p0000011-0000-0000-0000-000000000011', 'Potassium',        5.5, 'mEq/L',  3.5,  5.0, '2025-02-12 00:00:00+05:30'),
  ('r0000012-0000-0000-0000-000000000012', 'p0000011-0000-0000-0000-000000000011', 'Sodium',         137,   'mEq/L', 136,  145,   '2025-02-12 00:00:00+05:30'),
  ('r0000012-0000-0000-0000-000000000012', 'p0000011-0000-0000-0000-000000000011', 'Phosphorus',       5.8, 'mg/dL',  2.5,  4.5, '2025-02-12 00:00:00+05:30');

-- Report 14: HbA1c for Ramesh Yadav
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000014-0000-0000-0000-000000000014', 'p0000013-0000-0000-0000-000000000013', 'HbA1c',           8.5, '%',     4.0, 5.7, '2025-02-18 00:00:00+05:30'),
  ('r0000014-0000-0000-0000-000000000014', 'p0000013-0000-0000-0000-000000000013', 'Fasting Glucose', 178,  'mg/dL', 70,  100, '2025-02-18 00:00:00+05:30');

-- Report 15: Lipid Profile for Ramesh Yadav
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000015-0000-0000-0000-000000000015', 'p0000013-0000-0000-0000-000000000013', 'Total Cholesterol', 242, 'mg/dL', 0,   200, '2025-02-20 00:00:00+05:30'),
  ('r0000015-0000-0000-0000-000000000015', 'p0000013-0000-0000-0000-000000000013', 'LDL Cholesterol',  158, 'mg/dL', 0,   100, '2025-02-20 00:00:00+05:30'),
  ('r0000015-0000-0000-0000-000000000015', 'p0000013-0000-0000-0000-000000000013', 'HDL Cholesterol',   38, 'mg/dL', 40,   60, '2025-02-20 00:00:00+05:30'),
  ('r0000015-0000-0000-0000-000000000015', 'p0000013-0000-0000-0000-000000000013', 'Triglycerides',    230, 'mg/dL', 0,   150, '2025-02-20 00:00:00+05:30');

-- Report 17: Thyroid Panel for Lakshmi Pillai
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000017-0000-0000-0000-000000000017', 'p0000016-0000-0000-0000-000000000016', 'TSH',     2.1, 'mIU/L', 0.4, 4.0, '2025-03-01 00:00:00+05:30'),
  ('r0000017-0000-0000-0000-000000000017', 'p0000016-0000-0000-0000-000000000016', 'Free T4', 1.2, 'ng/dL', 0.8, 1.8, '2025-03-01 00:00:00+05:30'),
  ('r0000017-0000-0000-0000-000000000017', 'p0000016-0000-0000-0000-000000000016', 'Free T3', 3.1, 'pg/mL', 2.3, 4.2, '2025-03-01 00:00:00+05:30');

-- Report 18: CBC for Lakshmi Pillai (anemia)
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000018-0000-0000-0000-000000000018', 'p0000016-0000-0000-0000-000000000016', 'Haemoglobin',    8.2,  'g/dL',     12.0, 16.0, '2025-03-01 00:00:00+05:30'),
  ('r0000018-0000-0000-0000-000000000018', 'p0000016-0000-0000-0000-000000000016', 'MCV',           68,    'fL',        80,   100,  '2025-03-01 00:00:00+05:30'),
  ('r0000018-0000-0000-0000-000000000018', 'p0000016-0000-0000-0000-000000000016', 'Ferritin',       8,    'ng/mL',     12,   150,  '2025-03-01 00:00:00+05:30'),
  ('r0000018-0000-0000-0000-000000000018', 'p0000016-0000-0000-0000-000000000016', 'Serum Iron',    28,    'mcg/dL',    60,   170,  '2025-03-01 00:00:00+05:30'),
  ('r0000018-0000-0000-0000-000000000018', 'p0000016-0000-0000-0000-000000000016', 'TIBC',         420,    'mcg/dL',   250,   370,  '2025-03-01 00:00:00+05:30');

-- Report 19: Liver Function Test for Sanjay Bhatt
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000019-0000-0000-0000-000000000019', 'p0000017-0000-0000-0000-000000000017', 'ALT',       38,  'U/L',   7,   56,  '2025-03-03 00:00:00+05:30'),
  ('r0000019-0000-0000-0000-000000000019', 'p0000017-0000-0000-0000-000000000017', 'AST',       42,  'U/L',  10,   40,  '2025-03-03 00:00:00+05:30'),
  ('r0000019-0000-0000-0000-000000000019', 'p0000017-0000-0000-0000-000000000017', 'ALP',      110,  'U/L',  44,  147,  '2025-03-03 00:00:00+05:30'),
  ('r0000019-0000-0000-0000-000000000019', 'p0000017-0000-0000-0000-000000000017', 'Albumin',    3.2, 'g/dL', 3.5,  5.0, '2025-03-03 00:00:00+05:30');

-- Report 23: Metabolic Panel for Rajendra Prasad (heart failure)
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000023-0000-0000-0000-000000000023', 'p0000019-0000-0000-0000-000000000019', 'Creatinine',       1.6,  'mg/dL',  0.7,   1.2, '2025-03-07 00:00:00+05:30'),
  ('r0000023-0000-0000-0000-000000000023', 'p0000019-0000-0000-0000-000000000019', 'BUN',             38,    'mg/dL',   7,    20,   '2025-03-07 00:00:00+05:30'),
  ('r0000023-0000-0000-0000-000000000023', 'p0000019-0000-0000-0000-000000000019', 'Sodium',         134,    'mEq/L', 136,   145,   '2025-03-07 00:00:00+05:30'),
  ('r0000023-0000-0000-0000-000000000023', 'p0000019-0000-0000-0000-000000000019', 'Potassium',        4.8,  'mEq/L',  3.5,   5.0, '2025-03-07 00:00:00+05:30'),
  ('r0000023-0000-0000-0000-000000000023', 'p0000019-0000-0000-0000-000000000019', 'BNP',            890,    'pg/mL',   0,   100,   '2025-03-07 00:00:00+05:30');

-- Report 24: Lipid Profile for Rajendra Prasad
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000024-0000-0000-0000-000000000024', 'p0000019-0000-0000-0000-000000000019', 'Total Cholesterol', 198, 'mg/dL', 0,   200, '2025-03-07 00:00:00+05:30'),
  ('r0000024-0000-0000-0000-000000000024', 'p0000019-0000-0000-0000-000000000019', 'LDL Cholesterol',  118, 'mg/dL', 0,   100, '2025-03-07 00:00:00+05:30'),
  ('r0000024-0000-0000-0000-000000000024', 'p0000019-0000-0000-0000-000000000019', 'HDL Cholesterol',   42, 'mg/dL', 40,   60, '2025-03-07 00:00:00+05:30'),
  ('r0000024-0000-0000-0000-000000000024', 'p0000019-0000-0000-0000-000000000019', 'Triglycerides',    190, 'mg/dL', 0,   150, '2025-03-07 00:00:00+05:30');

-- Report 27: Lipid Profile follow-up for Vikram Deshmukh
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000027-0000-0000-0000-000000000027', 'p0000005-0000-0000-0000-000000000005', 'Total Cholesterol', 218, 'mg/dL', 0,   200, '2025-03-12 00:00:00+05:30'),
  ('r0000027-0000-0000-0000-000000000027', 'p0000005-0000-0000-0000-000000000005', 'LDL Cholesterol',  132, 'mg/dL', 0,   100, '2025-03-12 00:00:00+05:30'),
  ('r0000027-0000-0000-0000-000000000027', 'p0000005-0000-0000-0000-000000000005', 'HDL Cholesterol',   44, 'mg/dL', 40,   60, '2025-03-12 00:00:00+05:30'),
  ('r0000027-0000-0000-0000-000000000027', 'p0000005-0000-0000-0000-000000000005', 'Triglycerides',    168, 'mg/dL', 0,   150, '2025-03-12 00:00:00+05:30');

-- Report 28: Metabolic Panel follow-up for Arjun Malhotra
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000028-0000-0000-0000-000000000028', 'p0000011-0000-0000-0000-000000000011', 'Creatinine',  2.9, 'mg/dL',  0.7,  1.2, '2025-03-14 00:00:00+05:30'),
  ('r0000028-0000-0000-0000-000000000028', 'p0000011-0000-0000-0000-000000000011', 'eGFR',       27,   'mL/min', 90,  120,   '2025-03-14 00:00:00+05:30'),
  ('r0000028-0000-0000-0000-000000000028', 'p0000011-0000-0000-0000-000000000011', 'Potassium',   5.3, 'mEq/L',  3.5,  5.0, '2025-03-14 00:00:00+05:30'),
  ('r0000028-0000-0000-0000-000000000028', 'p0000011-0000-0000-0000-000000000011', 'Phosphorus',  5.6, 'mg/dL',  2.5,  4.5, '2025-03-14 00:00:00+05:30');

-- Report 29: Thyroid follow-up for Anita Joshi
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000029-0000-0000-0000-000000000029', 'p0000006-0000-0000-0000-000000000006', 'TSH',     6.8, 'mIU/L', 0.4, 4.0, '2025-03-18 00:00:00+05:30'),
  ('r0000029-0000-0000-0000-000000000029', 'p0000006-0000-0000-0000-000000000006', 'Free T4', 0.9, 'ng/dL', 0.8, 1.8, '2025-03-18 00:00:00+05:30'),
  ('r0000029-0000-0000-0000-000000000029', 'p0000006-0000-0000-0000-000000000006', 'Free T3', 2.4, 'pg/mL', 2.3, 4.2, '2025-03-18 00:00:00+05:30');

-- Report 30: CBC follow-up for Lakshmi Pillai
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000030-0000-0000-0000-000000000030', 'p0000016-0000-0000-0000-000000000016', 'Haemoglobin',      9.8, 'g/dL',    12.0, 16.0, '2025-03-22 00:00:00+05:30'),
  ('r0000030-0000-0000-0000-000000000030', 'p0000016-0000-0000-0000-000000000016', 'MCV',             72,   'fL',       80,   100,  '2025-03-22 00:00:00+05:30'),
  ('r0000030-0000-0000-0000-000000000030', 'p0000016-0000-0000-0000-000000000016', 'Reticulocyte Count', 2.8, '%',      0.5,   2.5, '2025-03-22 00:00:00+05:30');

-- Report 31: BNP follow-up for Rajendra Prasad
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000031-0000-0000-0000-000000000031', 'p0000019-0000-0000-0000-000000000019', 'BNP',        580,  'pg/mL',  0,   100, '2025-03-25 00:00:00+05:30'),
  ('r0000031-0000-0000-0000-000000000031', 'p0000019-0000-0000-0000-000000000019', 'Creatinine',  1.5, 'mg/dL',  0.7,  1.2, '2025-03-25 00:00:00+05:30'),
  ('r0000031-0000-0000-0000-000000000031', 'p0000019-0000-0000-0000-000000000019', 'Sodium',     136,   'mEq/L', 136,  145,  '2025-03-25 00:00:00+05:30');

-- Report 38: Metabolic Panel for Rahul Sharma
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000038-0000-0000-0000-000000000038', 'p0000001-0000-0000-0000-000000000001', 'Fasting Glucose',  98, 'mg/dL', 70,  100, '2025-01-15 00:00:00+05:30'),
  ('r0000038-0000-0000-0000-000000000038', 'p0000001-0000-0000-0000-000000000001', 'Creatinine',       1.0, 'mg/dL', 0.7, 1.2, '2025-01-15 00:00:00+05:30'),
  ('r0000038-0000-0000-0000-000000000038', 'p0000001-0000-0000-0000-000000000001', 'Sodium',         140,   'mEq/L', 136, 145, '2025-01-15 00:00:00+05:30'),
  ('r0000038-0000-0000-0000-000000000038', 'p0000001-0000-0000-0000-000000000001', 'Potassium',        4.2, 'mEq/L', 3.5, 5.0, '2025-01-15 00:00:00+05:30');

-- Report 45: Liver Function Test for Vikram Deshmukh
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000045-0000-0000-0000-000000000045', 'p0000005-0000-0000-0000-000000000005', 'ALT',       62, 'U/L',   7,  56, '2025-01-10 00:00:00+05:30'),
  ('r0000045-0000-0000-0000-000000000045', 'p0000005-0000-0000-0000-000000000005', 'AST',       48, 'U/L',  10,  40, '2025-01-10 00:00:00+05:30'),
  ('r0000045-0000-0000-0000-000000000045', 'p0000005-0000-0000-0000-000000000005', 'ALP',       92, 'U/L',  44, 147, '2025-01-10 00:00:00+05:30'),
  ('r0000045-0000-0000-0000-000000000045', 'p0000005-0000-0000-0000-000000000005', 'Albumin',    3.9, 'g/dL', 3.5, 5.0, '2025-01-10 00:00:00+05:30');

-- Report 48: Lipid Profile for Suresh Nair
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000048-0000-0000-0000-000000000048', 'p0000007-0000-0000-0000-000000000007', 'Total Cholesterol', 258, 'mg/dL', 0,   200, '2025-01-25 00:00:00+05:30'),
  ('r0000048-0000-0000-0000-000000000048', 'p0000007-0000-0000-0000-000000000007', 'LDL Cholesterol',  168, 'mg/dL', 0,   100, '2025-01-25 00:00:00+05:30'),
  ('r0000048-0000-0000-0000-000000000048', 'p0000007-0000-0000-0000-000000000007', 'HDL Cholesterol',   35, 'mg/dL', 40,   60, '2025-01-25 00:00:00+05:30'),
  ('r0000048-0000-0000-0000-000000000048', 'p0000007-0000-0000-0000-000000000007', 'Triglycerides',    275, 'mg/dL', 0,   150, '2025-01-25 00:00:00+05:30');

-- Report 50: Lipid Profile for Amit Kumar
INSERT INTO biomarkers (report_id, patient_id, name, value, unit, normal_min, normal_max, recorded_at) VALUES
  ('r0000050-0000-0000-0000-000000000050', 'p0000003-0000-0000-0000-000000000003', 'Total Cholesterol', 185, 'mg/dL', 0,   200, '2025-03-10 00:00:00+05:30'),
  ('r0000050-0000-0000-0000-000000000050', 'p0000003-0000-0000-0000-000000000003', 'LDL Cholesterol',  105, 'mg/dL', 0,   100, '2025-03-10 00:00:00+05:30'),
  ('r0000050-0000-0000-0000-000000000050', 'p0000003-0000-0000-0000-000000000003', 'HDL Cholesterol',   52, 'mg/dL', 40,   60, '2025-03-10 00:00:00+05:30'),
  ('r0000050-0000-0000-0000-000000000050', 'p0000003-0000-0000-0000-000000000003', 'Triglycerides',    140, 'mg/dL', 0,   150, '2025-03-10 00:00:00+05:30');

-- ========================================
-- PRESCRIPTIONS (20 total — 2 existing + 18 new)
-- ========================================
INSERT INTO prescriptions (patient_id, doctor_id, medications, issued_at, valid_until, notes) VALUES
  -- Existing 2
  ('p0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001',
   '[{"name": "Metoprolol", "dose": "50mg", "frequency": "Once daily", "duration": "3 months", "instructions": "Take in the morning with food"}, {"name": "Aspirin", "dose": "75mg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Take after lunch"}]',
   '2024-12-01 10:00:00+05:30', '2025-03-01 00:00:00+05:30', 'Review lipid panel before next visit'),

  ('p0000002-0000-0000-0000-000000000002', 'd0000002-0000-0000-0000-000000000002',
   '[{"name": "Metformin", "dose": "1000mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Take with meals"}, {"name": "Glimepiride", "dose": "2mg", "frequency": "Once daily", "duration": "3 months", "instructions": "Take before breakfast"}]',
   '2025-02-10 09:30:00+05:30', '2025-05-10 00:00:00+05:30', 'Monitor blood glucose daily. Recheck HbA1c in 3 months.'),

  -- New 18
  ('p0000004-0000-0000-0000-000000000004', 'd0000008-0000-0000-0000-000000000008',
   '[{"name": "Budesonide Inhaler", "dose": "200mcg", "frequency": "Twice daily", "duration": "3 months", "instructions": "Rinse mouth after use"}, {"name": "Salbutamol Inhaler", "dose": "100mcg", "frequency": "As needed", "duration": "Ongoing", "instructions": "Use for acute breathlessness, max 8 puffs/day"}, {"name": "Montelukast", "dose": "10mg", "frequency": "Once daily", "duration": "3 months", "instructions": "Take at bedtime"}]',
   '2025-01-05 14:00:00+05:30', '2025-04-05 00:00:00+05:30', 'Review peak flow diary at follow-up.'),

  ('p0000005-0000-0000-0000-000000000005', 'd0000001-0000-0000-0000-000000000001',
   '[{"name": "Apixaban", "dose": "5mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Do not skip doses"}, {"name": "Metoprolol", "dose": "50mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Rate control for AF"}, {"name": "Atorvastatin", "dose": "40mg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Take at night"}]',
   '2025-01-10 10:30:00+05:30', '2025-07-10 00:00:00+05:30', 'CHA2DS2-VASc score 3. Anticoagulation essential.'),

  ('p0000006-0000-0000-0000-000000000006', 'd0000007-0000-0000-0000-000000000007',
   '[{"name": "Levothyroxine", "dose": "50mcg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Take empty stomach, 30 min before breakfast"}]',
   '2025-01-12 11:00:00+05:30', '2025-07-12 00:00:00+05:30', 'Recheck TSH in 6 weeks. Increase dose if needed.'),

  ('p0000007-0000-0000-0000-000000000007', 'd0000001-0000-0000-0000-000000000001',
   '[{"name": "Clopidogrel", "dose": "75mg", "frequency": "Once daily", "duration": "12 months", "instructions": "Take after food"}, {"name": "Atorvastatin", "dose": "80mg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "High-intensity statin"}, {"name": "Ramipril", "dose": "5mg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Monitor potassium and creatinine"}]',
   '2025-01-18 09:00:00+05:30', '2026-01-18 00:00:00+05:30', 'Post-unstable angina regimen. Compliance critical.'),

  ('p0000007-0000-0000-0000-000000000007', 'd0000007-0000-0000-0000-000000000007',
   '[{"name": "Metformin", "dose": "1000mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Take with meals"}, {"name": "Insulin Glargine", "dose": "16 units", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Inject subcutaneously at bedtime"}, {"name": "Glimepiride", "dose": "2mg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Take before breakfast"}]',
   '2025-01-25 15:00:00+05:30', '2025-07-25 00:00:00+05:30', 'Titrate insulin by 2 units every 3 days until fasting glucose < 130.'),

  ('p0000009-0000-0000-0000-000000000009', 'd0000002-0000-0000-0000-000000000002',
   '[{"name": "Pantoprazole", "dose": "40mg", "frequency": "Once daily", "duration": "8 weeks", "instructions": "Take 30 min before breakfast"}, {"name": "Domperidone", "dose": "10mg", "frequency": "Three times daily", "duration": "2 weeks", "instructions": "Take before meals"}]',
   '2025-02-05 11:30:00+05:30', '2025-04-05 00:00:00+05:30', 'Avoid spicy food, caffeine, and late-night meals.'),

  ('p0000010-0000-0000-0000-000000000010', 'd0000003-0000-0000-0000-000000000003',
   '[{"name": "Betamethasone Cream 0.05%", "dose": "Thin layer", "frequency": "Twice daily", "duration": "2 weeks", "instructions": "Apply to affected areas only"}, {"name": "Cetirizine", "dose": "10mg", "frequency": "Once daily", "duration": "2 weeks", "instructions": "Take at bedtime"}]',
   '2025-02-08 14:30:00+05:30', '2025-02-22 00:00:00+05:30', 'Avoid contact with irritants. Moisturize regularly.'),

  ('p0000011-0000-0000-0000-000000000011', 'd0000006-0000-0000-0000-000000000006',
   '[{"name": "Propranolol", "dose": "40mg", "frequency": "Twice daily", "duration": "3 months", "instructions": "Migraine prophylaxis"}, {"name": "Sumatriptan", "dose": "50mg", "frequency": "As needed", "duration": "Ongoing", "instructions": "For acute migraine, max 2 doses in 24 hours"}]',
   '2025-02-12 10:00:00+05:30', '2025-05-12 00:00:00+05:30', 'Maintain headache diary. Avoid known triggers.'),

  ('p0000012-0000-0000-0000-000000000012', 'd0000009-0000-0000-0000-000000000009',
   '[{"name": "Tranexamic Acid", "dose": "500mg", "frequency": "Three times daily", "duration": "5 days per cycle", "instructions": "Take during heavy menstrual days"}, {"name": "Ferrous Sulphate", "dose": "200mg", "frequency": "Twice daily", "duration": "3 months", "instructions": "Take with vitamin C for better absorption"}, {"name": "Combined OCP (Ethinylestradiol + Levonorgestrel)", "dose": "1 tablet", "frequency": "Once daily", "duration": "6 months", "instructions": "Start on day 1 of cycle"}]',
   '2025-02-14 09:00:00+05:30', '2025-08-14 00:00:00+05:30', 'Monitor menstrual pattern. Recheck hemoglobin in 3 months.'),

  ('p0000013-0000-0000-0000-000000000013', 'd0000007-0000-0000-0000-000000000007',
   '[{"name": "Pregabalin", "dose": "75mg", "frequency": "Twice daily", "duration": "3 months", "instructions": "For neuropathic pain"}, {"name": "Metformin", "dose": "1000mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Take with meals"}, {"name": "Insulin Glargine", "dose": "12 units", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Inject at bedtime"}]',
   '2025-02-18 11:00:00+05:30', '2025-08-18 00:00:00+05:30', 'Target HbA1c < 7%. Foot care education given.'),

  ('p0000015-0000-0000-0000-000000000015', 'd0000006-0000-0000-0000-000000000006',
   '[{"name": "Topiramate", "dose": "50mg", "frequency": "Twice daily", "duration": "6 months", "instructions": "Titrate slowly. Stay hydrated."}, {"name": "Sumatriptan", "dose": "50mg", "frequency": "As needed", "duration": "Ongoing", "instructions": "For acute migraine attacks"}]',
   '2025-02-25 14:00:00+05:30', '2025-08-25 00:00:00+05:30', 'Avoid triggers: bright lights, stress, irregular sleep.'),

  ('p0000016-0000-0000-0000-000000000016', 'd0000002-0000-0000-0000-000000000002',
   '[{"name": "Ferrous Sulphate", "dose": "200mg", "frequency": "Three times daily", "duration": "3 months", "instructions": "Take with orange juice on empty stomach"}, {"name": "Vitamin C", "dose": "500mg", "frequency": "Once daily", "duration": "3 months", "instructions": "Enhances iron absorption"}, {"name": "Folic Acid", "dose": "5mg", "frequency": "Once daily", "duration": "3 months", "instructions": "Supports red blood cell production"}]',
   '2025-03-01 09:30:00+05:30', '2025-06-01 00:00:00+05:30', 'Recheck CBC in 4 weeks. If no response, consider IV iron.'),

  ('p0000017-0000-0000-0000-000000000017', 'd0000008-0000-0000-0000-000000000008',
   '[{"name": "Tiotropium Inhaler", "dose": "18mcg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Use HandiHaler device"}, {"name": "Salbutamol Inhaler", "dose": "100mcg", "frequency": "As needed", "duration": "Ongoing", "instructions": "Rescue inhaler"}, {"name": "Prednisolone", "dose": "40mg", "frequency": "Once daily", "duration": "5 days", "instructions": "Short course for exacerbation. Take with food."}]',
   '2025-03-03 11:00:00+05:30', '2025-09-03 00:00:00+05:30', 'Smoking cessation is the single most important intervention.'),

  ('p0000018-0000-0000-0000-000000000018', 'd0000004-0000-0000-0000-000000000004',
   '[{"name": "Methotrexate", "dose": "15mg", "frequency": "Once weekly", "duration": "Ongoing", "instructions": "Take on same day each week. Avoid alcohol."}, {"name": "Folic Acid", "dose": "5mg", "frequency": "Once daily (except MTX day)", "duration": "Ongoing", "instructions": "Prevents methotrexate side effects"}, {"name": "Hydroxychloroquine", "dose": "200mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Take with food. Annual eye exam required."}]',
   '2025-03-05 10:30:00+05:30', '2025-09-05 00:00:00+05:30', 'Monitor LFT and CBC every 3 months while on MTX.'),

  ('p0000019-0000-0000-0000-000000000019', 'd0000001-0000-0000-0000-000000000001',
   '[{"name": "Furosemide", "dose": "40mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Take in morning and afternoon"}, {"name": "Ramipril", "dose": "5mg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "ACE inhibitor for heart failure"}, {"name": "Spironolactone", "dose": "25mg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Monitor potassium"}, {"name": "Carvedilol", "dose": "12.5mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Beta-blocker for CHF. Take with food."}]',
   '2025-03-07 09:00:00+05:30', '2025-09-07 00:00:00+05:30', 'Daily weight monitoring. Report gain > 2kg in 3 days. Fluid restriction 1.5L/day.'),

  ('p0000020-0000-0000-0000-000000000020', 'd0000004-0000-0000-0000-000000000004',
   '[{"name": "Methotrexate", "dose": "12.5mg", "frequency": "Once weekly", "duration": "Ongoing", "instructions": "Take on Saturdays"}, {"name": "Hydroxychloroquine", "dose": "200mg", "frequency": "Twice daily", "duration": "Ongoing", "instructions": "Take with meals"}, {"name": "Folic Acid", "dose": "5mg", "frequency": "Once daily (except MTX day)", "duration": "Ongoing", "instructions": "Take daily except Saturday"}]',
   '2025-03-08 14:00:00+05:30', '2025-09-08 00:00:00+05:30', 'DAS28 elevated. If no improvement in 3 months, consider biologic DMARD.'),

  ('p0000006-0000-0000-0000-000000000006', 'd0000007-0000-0000-0000-000000000007',
   '[{"name": "Levothyroxine", "dose": "75mcg", "frequency": "Once daily", "duration": "Ongoing", "instructions": "Take empty stomach, 30 min before breakfast. Increased from 50mcg."}]',
   '2025-03-18 11:00:00+05:30', '2025-09-18 00:00:00+05:30', 'TSH improving but not at target. Recheck in 6 weeks after dose increase.'),

  ('p0000003-0000-0000-0000-000000000003', 'd0000005-0000-0000-0000-000000000005',
   '[{"name": "Paracetamol", "dose": "500mg", "frequency": "Three times daily", "duration": "5 days", "instructions": "Take as needed for fever"}, {"name": "Chlorhexidine Gargle", "dose": "10ml", "frequency": "Three times daily", "duration": "5 days", "instructions": "Gargle and spit, do not swallow"}]',
   '2025-03-10 10:00:00+05:30', '2025-03-15 00:00:00+05:30', 'Viral pharyngitis. No antibiotics needed. Rest and fluids.');

-- ========================================
-- APPOINTMENTS (15 total — mix of past completed and future scheduled)
-- ========================================
INSERT INTO appointments (patient_id, doctor_id, hospital_id, scheduled_at, duration_minutes, status, reason, notes) VALUES
  -- Past completed appointments
  ('p0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-01 10:00:00+05:30', 30, 'completed', 'Follow-up for stable angina', 'Patient doing well on current medications.'),

  ('p0000002-0000-0000-0000-000000000002', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-05 11:00:00+05:30', 30, 'completed', 'Diabetes quarterly review', 'HbA1c repeat ordered.'),

  ('p0000005-0000-0000-0000-000000000005', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-12 11:30:00+05:30', 45, 'completed', 'AF follow-up with echo results', 'Echo and Holter reviewed. Stable.'),

  ('p0000007-0000-0000-0000-000000000007', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003',
   '2025-03-15 10:00:00+05:30', 30, 'completed', 'Diabetes and CKD review', 'Creatinine stable. Adjusted insulin.'),

  ('p0000016-0000-0000-0000-000000000016', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-22 09:00:00+05:30', 30, 'completed', 'Anemia follow-up CBC review', 'Hb improving. Continue iron.'),

  -- Cancelled appointment
  ('p0000009-0000-0000-0000-000000000009', 'd0000002-0000-0000-0000-000000000002', 'h0000001-0000-0000-0000-000000000001',
   '2025-03-20 14:00:00+05:30', 30, 'cancelled', 'GERD follow-up', 'Patient rescheduled due to travel.'),

  -- Future scheduled appointments
  ('p0000001-0000-0000-0000-000000000001', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2026-04-02 10:00:00+05:30', 30, 'scheduled', 'Cardiology quarterly review', NULL),

  ('p0000004-0000-0000-0000-000000000004', 'd0000008-0000-0000-0000-000000000008', 'h0000001-0000-0000-0000-000000000001',
   '2026-04-05 14:00:00+05:30', 30, 'scheduled', 'Asthma review and peak flow check', NULL),

  ('p0000006-0000-0000-0000-000000000006', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003',
   '2026-04-08 11:00:00+05:30', 30, 'scheduled', 'Thyroid function recheck', NULL),

  ('p0000011-0000-0000-0000-000000000011', 'd0000006-0000-0000-0000-000000000006', 'h0000003-0000-0000-0000-000000000003',
   '2026-04-10 09:30:00+05:30', 45, 'scheduled', 'Neurology follow-up for Parkinsonism evaluation', NULL),

  ('p0000013-0000-0000-0000-000000000013', 'd0000007-0000-0000-0000-000000000007', 'h0000003-0000-0000-0000-000000000003',
   '2026-04-12 15:00:00+05:30', 30, 'scheduled', 'Diabetes and neuropathy follow-up', NULL),

  ('p0000019-0000-0000-0000-000000000019', 'd0000001-0000-0000-0000-000000000001', 'h0000001-0000-0000-0000-000000000001',
   '2026-04-01 09:00:00+05:30', 45, 'scheduled', 'Heart failure weekly follow-up', NULL),

  ('p0000017-0000-0000-0000-000000000017', 'd0000008-0000-0000-0000-000000000008', 'h0000001-0000-0000-0000-000000000001',
   '2026-04-03 11:00:00+05:30', 30, 'scheduled', 'COPD maintenance check', NULL),

  ('p0000012-0000-0000-0000-000000000012', 'd0000009-0000-0000-0000-000000000009', 'h0000002-0000-0000-0000-000000000002',
   '2026-04-07 10:00:00+05:30', 30, 'scheduled', 'PCOS and menstrual pattern review', NULL),

  ('p0000020-0000-0000-0000-000000000020', 'd0000004-0000-0000-0000-000000000004', 'h0000002-0000-0000-0000-000000000002',
   '2026-04-15 14:30:00+05:30', 30, 'scheduled', 'RA disease activity assessment', NULL);

-- ========================================
-- SYMPTOM SESSIONS (10 total — varied triage levels)
-- ========================================
INSERT INTO symptom_sessions (patient_id, symptoms_input, ai_response, triage_level) VALUES
  ('p0000001-0000-0000-0000-000000000001',
   'I have been having chest pain when I climb stairs. It goes away when I rest. No sweating or radiation to arm.',
   '{"possible_conditions": ["Stable Angina", "Musculoskeletal chest pain"], "recommendation": "Given your history of hypertension, this sounds like stable angina. Please schedule an appointment with your cardiologist for an ECG and stress test. Avoid heavy exertion until evaluated.", "urgency": "moderate", "red_flags": ["chest pain on exertion"], "follow_up": "See cardiologist within 1 week"}',
   'see_doctor'),

  ('p0000003-0000-0000-0000-000000000003',
   'I have a runny nose, sore throat, and mild fever of 99.5F since yesterday.',
   '{"possible_conditions": ["Common Cold", "Viral Upper Respiratory Infection"], "recommendation": "This appears to be a viral upper respiratory infection. Rest, stay hydrated, and take paracetamol for fever. Monitor temperature. If fever exceeds 102F or symptoms worsen after 5 days, see a doctor.", "urgency": "low", "red_flags": [], "follow_up": "Self-monitor for 5 days"}',
   'home_care'),

  ('p0000008-0000-0000-0000-000000000008',
   'I have been having irregular periods for the last 4 months. Sometimes skipping a month. Also noticed more acne than usual.',
   '{"possible_conditions": ["PCOS", "Thyroid Disorder", "Stress-related amenorrhea"], "recommendation": "Irregular periods with acne could suggest hormonal imbalance such as PCOS. Please schedule an appointment with a gynecologist for hormonal panel and ultrasound evaluation.", "urgency": "moderate", "red_flags": [], "follow_up": "Gynecology appointment within 2 weeks"}',
   'see_doctor'),

  ('p0000010-0000-0000-0000-000000000010',
   'I have a red itchy rash on both forearms that appeared after using a new hand wash. Small bumps and dry skin.',
   '{"possible_conditions": ["Contact Dermatitis", "Allergic Dermatitis"], "recommendation": "This is likely contact dermatitis from the new hand wash. Discontinue use immediately. Apply calamine lotion for relief. If rash worsens, spreads, or develops blisters, see a dermatologist.", "urgency": "low", "red_flags": [], "follow_up": "Self-monitor for 1 week"}',
   'home_care'),

  ('p0000019-0000-0000-0000-000000000019',
   'I am feeling very breathless even at rest. My ankles are very swollen. I cannot lie flat to sleep. I feel like I am drowning.',
   '{"possible_conditions": ["Acute Decompensated Heart Failure", "Pulmonary Edema"], "recommendation": "URGENT: Your symptoms suggest worsening heart failure with possible fluid overload. Please go to the nearest emergency department IMMEDIATELY. Do not delay. Sit upright and call emergency services if breathing worsens.", "urgency": "critical", "red_flags": ["breathlessness at rest", "orthopnea", "severe ankle edema", "known heart failure"], "follow_up": "Emergency department NOW"}',
   'emergency'),

  ('p0000014-0000-0000-0000-000000000014',
   'I twisted my right knee while playing badminton yesterday. There is swelling and I cannot fully bend it. Pain is 6 out of 10.',
   '{"possible_conditions": ["Ligament Sprain", "Meniscal Injury", "ACL Injury"], "recommendation": "Apply RICE (Rest, Ice, Compression, Elevation). Take a painkiller like paracetamol. If swelling does not reduce in 48 hours or knee feels unstable, see an orthopedic surgeon for imaging.", "urgency": "moderate", "red_flags": ["knee instability", "significant swelling"], "follow_up": "Orthopedic consultation within 3 days"}',
   'see_doctor'),

  ('p0000015-0000-0000-0000-000000000015',
   'I have a throbbing headache on the right side of my head. Feeling nauseous. Light is bothering me. Had similar episodes before.',
   '{"possible_conditions": ["Migraine with photophobia", "Tension headache"], "recommendation": "This sounds like a migraine episode. Move to a dark, quiet room. Take your prescribed triptan if available. Apply a cold compress. If this is the worst headache of your life or accompanied by fever/stiff neck, seek emergency care.", "urgency": "low", "red_flags": [], "follow_up": "Discuss prophylaxis with neurologist at next visit"}',
   'home_care'),

  ('p0000007-0000-0000-0000-000000000007',
   'I am having severe chest pain radiating to my left arm. Sweating profusely. Feeling like something heavy is sitting on my chest.',
   '{"possible_conditions": ["Acute Myocardial Infarction", "Unstable Angina"], "recommendation": "EMERGENCY: Your symptoms suggest a possible heart attack. Call 108 (ambulance) IMMEDIATELY. Chew an aspirin 325mg if available and not allergic. Do NOT drive yourself to the hospital. Time is critical.", "urgency": "critical", "red_flags": ["chest pain radiating to arm", "diaphoresis", "known CAD", "crushing chest pain"], "follow_up": "Emergency department IMMEDIATELY"}',
   'emergency'),

  ('p0000009-0000-0000-0000-000000000009',
   'I have been having burning sensation in my chest after meals especially at night. Sour taste in mouth. Occasional belching.',
   '{"possible_conditions": ["GERD", "Peptic Ulcer Disease"], "recommendation": "These are typical symptoms of acid reflux (GERD). Avoid spicy/fatty food, caffeine, and eating 3 hours before bed. Elevate the head of your bed. If you have a PPI prescribed, take it regularly. See your doctor if symptoms persist despite lifestyle changes.", "urgency": "low", "red_flags": [], "follow_up": "Doctor visit if no improvement in 2 weeks"}',
   'home_care'),

  ('p0000017-0000-0000-0000-000000000017',
   'I am coughing a lot more than usual with thick yellow sputum. Feeling breathless walking to the bathroom. Temperature 100.8F.',
   '{"possible_conditions": ["COPD Exacerbation", "Acute Bronchitis", "Pneumonia"], "recommendation": "Given your COPD history, increased cough with colored sputum and fever suggests an infective exacerbation. Please see your pulmonologist today or visit the nearest clinic. You may need antibiotics and steroid adjustment. Use your rescue inhaler as needed.", "urgency": "high", "red_flags": ["increased sputum", "fever with COPD", "worsening breathlessness"], "follow_up": "Same-day doctor visit"}',
   'see_doctor');

-- ========================================
-- NOTIFICATIONS (sample notifications for patients and doctors)
-- ========================================
INSERT INTO notifications (patient_id, doctor_id, title, body, type, read_at, action_route, metadata) VALUES
  -- Patient notifications
  ('p0000001-0000-0000-0000-000000000001', NULL, 'Lab Report Ready',
   'Your CBC and Lipid Profile reports from City Lab Services are now available.',
   'lab_result', '2025-01-16 08:00:00+05:30', '/reports', '{"report_ids": ["r0000001-0000-0000-0000-000000000001", "r0000002-0000-0000-0000-000000000002"]}'),

  ('p0000001-0000-0000-0000-000000000001', NULL, 'Upcoming Appointment',
   'You have an appointment with Dr. Ananya Singh (Cardiology) on April 2, 2026 at 10:00 AM.',
   'appointment', NULL, '/appointments', '{"doctor_name": "Dr. Ananya Singh", "specialization": "Cardiology"}'),

  ('p0000002-0000-0000-0000-000000000002', NULL, 'Lab Report Ready',
   'Your HbA1c report from MedTest Labs is now available. Please review with your doctor.',
   'lab_result', '2025-02-11 09:00:00+05:30', '/reports', '{"report_ids": ["r0000003-0000-0000-0000-000000000003"]}'),

  ('p0000004-0000-0000-0000-000000000004', NULL, 'Prescription Updated',
   'Dr. Vivek Pandey has prescribed new medications for your asthma management.',
   'prescription', '2025-01-06 10:00:00+05:30', '/prescriptions', NULL),

  ('p0000006-0000-0000-0000-000000000006', NULL, 'Lab Report Ready',
   'Your Thyroid Panel results are ready. TSH levels require attention.',
   'lab_result', NULL, '/reports', '{"report_ids": ["r0000029-0000-0000-0000-000000000029"]}'),

  ('p0000019-0000-0000-0000-000000000019', NULL, 'Appointment Reminder',
   'Reminder: You have a heart failure follow-up with Dr. Ananya Singh tomorrow at 9:00 AM.',
   'appointment', NULL, '/appointments', '{"doctor_name": "Dr. Ananya Singh"}'),

  ('p0000016-0000-0000-0000-000000000016', NULL, 'Lab Report Ready',
   'Your follow-up CBC results show improvement. Hb has risen to 9.8 g/dL.',
   'lab_result', '2025-03-23 08:30:00+05:30', '/reports', '{"report_ids": ["r0000030-0000-0000-0000-000000000030"]}'),

  ('p0000013-0000-0000-0000-000000000013', NULL, 'Medication Reminder',
   'Please remember to take your Insulin Glargine at bedtime tonight.',
   'medication', NULL, NULL, '{"medication_name": "Insulin Glargine", "dose": "12 units"}'),

  -- Doctor notifications
  (NULL, 'd0000001-0000-0000-0000-000000000001', 'New Patient Assignment',
   'Rajendra Prasad (O+, 70M) has granted you full access to their medical records.',
   'access_grant', '2025-03-07 08:00:00+05:30', '/patients/p0000019-0000-0000-0000-000000000019', '{"patient_name": "Rajendra Prasad"}'),

  (NULL, 'd0000001-0000-0000-0000-000000000001', 'Upcoming Appointments',
   'You have 3 appointments scheduled for next week.',
   'info', NULL, '/appointments', '{"appointment_count": 3}'),

  (NULL, 'd0000002-0000-0000-0000-000000000002', 'Critical Lab Result',
   'Patient Lakshmi Pillai has Hb 8.2 g/dL. Iron deficiency anemia confirmed. Review required.',
   'lab_result', '2025-03-01 14:00:00+05:30', '/patients/p0000016-0000-0000-0000-000000000016', '{"patient_name": "Lakshmi Pillai", "critical_value": "Hb 8.2"}'),

  (NULL, 'd0000007-0000-0000-0000-000000000007', 'New Patient Assignment',
   'Ramesh Yadav has granted you full access for diabetes and neuropathy management.',
   'access_grant', '2025-02-18 09:00:00+05:30', '/patients/p0000013-0000-0000-0000-000000000013', '{"patient_name": "Ramesh Yadav"}'),

  (NULL, 'd0000008-0000-0000-0000-000000000008', 'Appointment Scheduled',
   'Sneha Reddy has booked an appointment for April 5, 2026 at 2:00 PM for asthma review.',
   'appointment', NULL, '/appointments', '{"patient_name": "Sneha Reddy"}'),

  (NULL, 'd0000006-0000-0000-0000-000000000006', 'Lab Results Available',
   'MRI and DaTscan results for Arjun Malhotra are now available for review.',
   'lab_result', NULL, '/patients/p0000011-0000-0000-0000-000000000011', '{"patient_name": "Arjun Malhotra"}'),

  (NULL, 'd0000009-0000-0000-0000-000000000009', 'Appointment Scheduled',
   'Pooja Saxena has booked a follow-up appointment for April 7, 2026 for PCOS review.',
   'appointment', '2025-03-26 10:00:00+05:30', '/appointments', '{"patient_name": "Pooja Saxena"}');

-- ============================================================
-- 1. Create Storage Buckets
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('lab-reports', 'lab-reports', false),
  ('avatars', 'avatars', true),
  ('prescription-images', 'prescription-images', false)
ON CONFLICT (id) DO NOTHING;

-- RLS policies for lab-reports bucket
CREATE POLICY "auth_upload_lab_reports"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'lab-reports' AND auth.role() = 'authenticated');

CREATE POLICY "auth_view_lab_reports"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'lab-reports' AND auth.role() = 'authenticated');

-- RLS policies for avatars bucket (public read, authenticated write)
CREATE POLICY "public_view_avatars"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "auth_upload_avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "auth_update_avatars"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');

-- RLS policies for prescription-images bucket
CREATE POLICY "auth_upload_prescriptions"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'prescription-images' AND auth.role() = 'authenticated');

CREATE POLICY "auth_view_prescriptions"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'prescription-images' AND auth.role() = 'authenticated');

-- ============================================================
-- 2. Fix missing ON DELETE CASCADE
-- ============================================================

-- biomarkers.patient_id: was missing CASCADE
ALTER TABLE biomarkers DROP CONSTRAINT IF EXISTS biomarkers_patient_id_fkey;
ALTER TABLE biomarkers ADD CONSTRAINT biomarkers_patient_id_fkey
  FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE;

-- appointments.doctor_id: was missing CASCADE
ALTER TABLE appointments DROP CONSTRAINT IF EXISTS appointments_doctor_id_fkey;
ALTER TABLE appointments ADD CONSTRAINT appointments_doctor_id_fkey
  FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE;

-- appointments.hospital_id: add SET NULL on delete
ALTER TABLE appointments DROP CONSTRAINT IF EXISTS appointments_hospital_id_fkey;
ALTER TABLE appointments ADD CONSTRAINT appointments_hospital_id_fkey
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE SET NULL;

-- ============================================================
-- 3. Fix notifications RLS to use SECURITY DEFINER helpers
-- ============================================================

DROP POLICY IF EXISTS "Patients can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Doctors can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Service role can insert notifications" ON notifications;

CREATE POLICY "patient_view_notifications" ON notifications
  FOR SELECT USING (
    patient_id = get_patient_id_for_user(auth.uid())
  );

CREATE POLICY "doctor_view_notifications" ON notifications
  FOR SELECT USING (
    doctor_id = get_doctor_id_for_user(auth.uid())
  );

CREATE POLICY "patient_mark_read_notifications" ON notifications
  FOR UPDATE USING (
    patient_id = get_patient_id_for_user(auth.uid())
  );

CREATE POLICY "doctor_mark_read_notifications" ON notifications
  FOR UPDATE USING (
    doctor_id = get_doctor_id_for_user(auth.uid())
  );

CREATE POLICY "service_insert_notifications" ON notifications
  FOR INSERT WITH CHECK (true);

-- ============================================================
-- 4. Fix appointments RLS to use SECURITY DEFINER helpers
-- ============================================================

DROP POLICY IF EXISTS "Patients can view own appointments" ON appointments;
DROP POLICY IF EXISTS "Patients can create own appointments" ON appointments;
DROP POLICY IF EXISTS "Patients can update own appointments" ON appointments;
DROP POLICY IF EXISTS "Doctors can view their appointments" ON appointments;
DROP POLICY IF EXISTS "Doctors can update their appointments" ON appointments;

CREATE POLICY "patient_view_appointments" ON appointments
  FOR SELECT USING (patient_id = get_patient_id_for_user(auth.uid()));

CREATE POLICY "patient_create_appointments" ON appointments
  FOR INSERT WITH CHECK (patient_id = get_patient_id_for_user(auth.uid()));

CREATE POLICY "patient_update_appointments" ON appointments
  FOR UPDATE USING (patient_id = get_patient_id_for_user(auth.uid()));

CREATE POLICY "doctor_view_appointments" ON appointments
  FOR SELECT USING (doctor_id = get_doctor_id_for_user(auth.uid()));

CREATE POLICY "doctor_update_appointments" ON appointments
  FOR UPDATE USING (doctor_id = get_doctor_id_for_user(auth.uid()));

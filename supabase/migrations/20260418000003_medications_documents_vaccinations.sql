-- ─────────────────────────────────────────────────────────────────────────────
-- Medication Schedules (patient-configured dose reminders)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE medication_schedules (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id      UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  prescription_id UUID REFERENCES prescriptions(id) ON DELETE SET NULL,

  drug_name       TEXT NOT NULL,
  dosage          TEXT NOT NULL,
  instructions    TEXT,

  -- Local-time dose slots (HH:MM, patient's local). Stored as JSON array so we
  -- can support e.g. ['08:00', '14:00', '22:00']. Used only for reminder
  -- scheduling; actual adherence is logged into medication_logs.
  dose_times      JSONB NOT NULL DEFAULT '[]'::jsonb,

  -- ISO weekdays on which to remind (1=Mon … 7=Sun). Empty array = every day.
  weekdays        INT[] DEFAULT ARRAY[]::INT[],

  started_on      DATE NOT NULL DEFAULT CURRENT_DATE,
  ended_on        DATE,
  is_active       BOOLEAN DEFAULT true,

  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_medication_schedules_patient ON medication_schedules (patient_id);
CREATE INDEX idx_medication_schedules_active  ON medication_schedules (patient_id, is_active)
  WHERE is_active;

-- ─────────────────────────────────────────────────────────────────────────────
-- Medication Logs (dose-taken / skipped entries)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE medication_logs (
  id                    UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  schedule_id           UUID NOT NULL REFERENCES medication_schedules(id) ON DELETE CASCADE,
  patient_id            UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  scheduled_at          TIMESTAMPTZ NOT NULL,
  taken_at              TIMESTAMPTZ,
  status                TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
                          'pending', 'taken', 'skipped', 'missed'
                        )),
  note                  TEXT,

  created_at            TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_medication_logs_schedule ON medication_logs (schedule_id);
CREATE INDEX idx_medication_logs_patient_due ON medication_logs (patient_id, scheduled_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- Patient Documents (self-uploaded reports/insurance/etc.)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE patient_documents (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id    UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  title         TEXT NOT NULL,
  kind          TEXT NOT NULL CHECK (kind IN (
                  'report', 'insurance', 'prescription', 'vaccine_cert', 'other'
                )),
  notes         TEXT,

  storage_path  TEXT NOT NULL,        -- key inside the `patient-documents` bucket
  file_url      TEXT,                 -- cached signed/public URL if any
  mime_type     TEXT,
  size_bytes    BIGINT,

  uploaded_at   TIMESTAMPTZ DEFAULT NOW(),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_patient_documents_patient ON patient_documents (patient_id, uploaded_at DESC);
CREATE INDEX idx_patient_documents_kind    ON patient_documents (patient_id, kind);

-- ─────────────────────────────────────────────────────────────────────────────
-- Vaccinations
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE vaccinations (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id    UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,

  vaccine_name  TEXT NOT NULL,
  manufacturer  TEXT,
  dose_number   INT,
  total_doses   INT,

  date_given    DATE NOT NULL,
  next_due      DATE,

  lot_number    TEXT,
  administered_at TEXT,          -- free-text clinic/place name
  document_id   UUID REFERENCES patient_documents(id) ON DELETE SET NULL,

  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_vaccinations_patient ON vaccinations (patient_id, date_given DESC);
CREATE INDEX idx_vaccinations_next_due ON vaccinations (patient_id, next_due)
  WHERE next_due IS NOT NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- Storage bucket for self-uploaded documents
-- ─────────────────────────────────────────────────────────────────────────────

INSERT INTO storage.buckets (id, name, public)
VALUES ('patient-documents', 'patient-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Patients can upload/read/delete their own files in patient-documents/.
-- Path convention: {patient_id}/{uuid}.{ext}
CREATE POLICY "patients manage own documents"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'patient-documents'
    AND (storage.foldername(name))[1] = get_patient_id_for_user(auth.uid())::text
  )
  WITH CHECK (
    bucket_id = 'patient-documents'
    AND (storage.foldername(name))[1] = get_patient_id_for_user(auth.uid())::text
  );

-- ─────────────────────────────────────────────────────────────────────────────
-- Row-level security
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE medication_schedules  ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_logs       ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_documents     ENABLE ROW LEVEL SECURITY;
ALTER TABLE vaccinations          ENABLE ROW LEVEL SECURITY;

-- medication_schedules: patient manages own
CREATE POLICY "patient manages own medication schedules"
  ON medication_schedules FOR ALL
  USING   (patient_id = get_patient_id_for_user(auth.uid()))
  WITH CHECK (patient_id = get_patient_id_for_user(auth.uid()));

-- doctor sees schedules via access grant
CREATE POLICY "doctor reads medication schedules via access"
  ON medication_schedules FOR SELECT
  USING (doctor_has_access_to_patient(get_doctor_id_for_user(auth.uid()), patient_id));

-- medication_logs: patient manages own
CREATE POLICY "patient manages own medication logs"
  ON medication_logs FOR ALL
  USING   (patient_id = get_patient_id_for_user(auth.uid()))
  WITH CHECK (patient_id = get_patient_id_for_user(auth.uid()));

-- patient_documents: patient owns
CREATE POLICY "patient manages own documents"
  ON patient_documents FOR ALL
  USING   (patient_id = get_patient_id_for_user(auth.uid()))
  WITH CHECK (patient_id = get_patient_id_for_user(auth.uid()));

-- doctor reads patient documents via access
CREATE POLICY "doctor reads patient documents via access"
  ON patient_documents FOR SELECT
  USING (doctor_has_access_to_patient(get_doctor_id_for_user(auth.uid()), patient_id));

-- vaccinations: patient owns
CREATE POLICY "patient manages own vaccinations"
  ON vaccinations FOR ALL
  USING   (patient_id = get_patient_id_for_user(auth.uid()))
  WITH CHECK (patient_id = get_patient_id_for_user(auth.uid()));

CREATE POLICY "doctor reads vaccinations via access"
  ON vaccinations FOR SELECT
  USING (doctor_has_access_to_patient(get_doctor_id_for_user(auth.uid()), patient_id));

-- ─────────────────────────────────────────────────────────────────────────────
-- updated_at triggers
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TRIGGER set_medication_schedules_updated_at
  BEFORE UPDATE ON medication_schedules
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_vaccinations_updated_at
  BEFORE UPDATE ON vaccinations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

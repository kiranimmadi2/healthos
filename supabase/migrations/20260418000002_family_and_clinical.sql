-- ─────────────────────────────────────────────────────────────────────────────
-- Family Members
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE family_members (
  id                        UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  primary_patient_id        UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  member_patient_id         UUID REFERENCES patients(id) ON DELETE SET NULL,

  relationship              TEXT NOT NULL CHECK (relationship IN (
                              'spouse', 'child', 'parent', 'sibling', 'guardian', 'other'
                            )),
  full_name                 TEXT NOT NULL,
  date_of_birth             DATE,
  gender                    TEXT CHECK (gender IN ('male', 'female', 'other')),
  phone                     TEXT,

  is_dependent              BOOLEAN DEFAULT false,
  can_view_records          BOOLEAN DEFAULT false,
  can_manage_appointments   BOOLEAN DEFAULT false,

  invite_status             TEXT DEFAULT 'not_invited' CHECK (invite_status IN (
                              'not_invited', 'invited', 'linked'
                            )),
  invited_at                TIMESTAMPTZ,
  linked_at                 TIMESTAMPTZ,

  created_at                TIMESTAMPTZ DEFAULT NOW(),
  updated_at                TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_family_members_primary ON family_members (primary_patient_id);
CREATE INDEX idx_family_members_member  ON family_members (member_patient_id);
CREATE INDEX idx_family_members_phone   ON family_members (phone);

-- ─────────────────────────────────────────────────────────────────────────────
-- Visit Vitals
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE visit_vitals (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  visit_id       UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,
  patient_id     UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  bp_systolic    INT,
  bp_diastolic   INT,
  heart_rate     INT,
  temperature_c  NUMERIC(4,1),
  weight_kg      NUMERIC(5,1),
  height_cm      NUMERIC(5,1),
  spo2_percent   NUMERIC(4,1),
  recorded_at    TIMESTAMPTZ DEFAULT NOW(),
  recorded_by    UUID REFERENCES doctors(id)
);

CREATE INDEX idx_visit_vitals_visit   ON visit_vitals (visit_id);
CREATE INDEX idx_visit_vitals_patient ON visit_vitals (patient_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- Doctor Notes
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE doctor_notes (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id  UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id   UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  is_private  BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_doctor_notes_patient ON doctor_notes (patient_id);
CREATE INDEX idx_doctor_notes_doctor  ON doctor_notes (doctor_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- Alter existing tables
-- ─────────────────────────────────────────────────────────────────────────────

-- Appointments: track who booked on whose behalf
ALTER TABLE appointments
  ADD COLUMN IF NOT EXISTS booked_by_patient_id UUID REFERENCES patients(id),
  ADD COLUMN IF NOT EXISTS booked_for_member_id UUID REFERENCES family_members(id);

-- Visits: clinical metadata
ALTER TABLE visits
  ADD COLUMN IF NOT EXISTS follow_up_date DATE,
  ADD COLUMN IF NOT EXISTS icd_code       TEXT,
  ADD COLUMN IF NOT EXISTS visit_type     TEXT DEFAULT 'consultation'
    CHECK (visit_type IN ('consultation', 'follow_up', 'emergency', 'procedure'));

-- ─────────────────────────────────────────────────────────────────────────────
-- RLS Policies
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE visit_vitals   ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctor_notes   ENABLE ROW LEVEL SECURITY;

-- family_members: primary patient manages own family
CREATE POLICY "patient manages own family"
  ON family_members FOR ALL
  USING   (primary_patient_id = get_patient_id_for_user(auth.uid()))
  WITH CHECK (primary_patient_id = get_patient_id_for_user(auth.uid()));

-- family_members: linked member can read their own entry
CREATE POLICY "linked member reads own entry"
  ON family_members FOR SELECT
  USING (member_patient_id = get_patient_id_for_user(auth.uid()));

-- visit_vitals: doctor writes, patient reads own, doctor reads with access
CREATE POLICY "doctor writes vitals"
  ON visit_vitals FOR INSERT
  WITH CHECK (recorded_by = get_doctor_id_for_user(auth.uid()));

CREATE POLICY "patient reads own vitals"
  ON visit_vitals FOR SELECT
  USING (patient_id = get_patient_id_for_user(auth.uid()));

CREATE POLICY "doctor reads vitals with access"
  ON visit_vitals FOR SELECT
  USING (doctor_has_access_to_patient(get_doctor_id_for_user(auth.uid()), patient_id));

-- doctor_notes: doctor owns, patient sees non-private notes only
CREATE POLICY "doctor manages own notes"
  ON doctor_notes FOR ALL
  USING   (doctor_id = get_doctor_id_for_user(auth.uid()))
  WITH CHECK (doctor_id = get_doctor_id_for_user(auth.uid()));

CREATE POLICY "patient reads shared notes"
  ON doctor_notes FOR SELECT
  USING (patient_id = get_patient_id_for_user(auth.uid()) AND is_private = false);

-- ─────────────────────────────────────────────────────────────────────────────
-- updated_at triggers
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TRIGGER set_family_members_updated_at
  BEFORE UPDATE ON family_members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_visit_vitals_updated_at
  BEFORE UPDATE ON visit_vitals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_doctor_notes_updated_at
  BEFORE UPDATE ON doctor_notes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

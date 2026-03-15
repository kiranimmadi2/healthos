-- Prescriptions
CREATE TABLE prescriptions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE NOT NULL,
  visit_id UUID REFERENCES visits(id),
  doctor_id UUID REFERENCES doctors(id),
  medications JSONB NOT NULL,
  issued_at TIMESTAMPTZ NOT NULL,
  valid_until TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_prescriptions_patient ON prescriptions (patient_id);
CREATE INDEX idx_prescriptions_doctor ON prescriptions (doctor_id);
CREATE INDEX idx_prescriptions_date ON prescriptions (issued_at DESC);

-- Access grants (patient controls who sees their data)
CREATE TABLE access_grants (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE NOT NULL,
  doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE NOT NULL,
  hospital_id UUID REFERENCES hospitals(id),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'revoked', 'expired')),
  access_level TEXT DEFAULT 'read' CHECK (access_level IN ('read', 'full')),
  granted_at TIMESTAMPTZ DEFAULT NOW(),
  revoked_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  UNIQUE(patient_id, doctor_id)
);

CREATE INDEX idx_access_grants_patient ON access_grants (patient_id);
CREATE INDEX idx_access_grants_doctor ON access_grants (doctor_id);
CREATE INDEX idx_access_grants_status ON access_grants (status);

-- Clinical visits
CREATE TABLE visits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE NOT NULL,
  doctor_id UUID REFERENCES doctors(id),
  hospital_id UUID REFERENCES hospitals(id),
  visited_at TIMESTAMPTZ NOT NULL,
  chief_complaint TEXT,
  diagnosis TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_visits_patient ON visits (patient_id);
CREATE INDEX idx_visits_doctor ON visits (doctor_id);
CREATE INDEX idx_visits_date ON visits (visited_at DESC);

-- Symptom check sessions (AI interactions)
CREATE TABLE symptom_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE NOT NULL,
  symptoms_input TEXT NOT NULL,
  ai_response JSONB NOT NULL,
  triage_level TEXT CHECK (triage_level IN ('home_care', 'see_doctor', 'emergency')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_symptom_sessions_patient ON symptom_sessions (patient_id);
CREATE INDEX idx_symptom_sessions_date ON symptom_sessions (created_at DESC);
CREATE INDEX idx_symptom_sessions_triage ON symptom_sessions (triage_level);

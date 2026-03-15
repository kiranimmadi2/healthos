-- Individual biomarker values (for graphs and trends)
CREATE TABLE biomarkers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  report_id UUID REFERENCES lab_reports(id) ON DELETE CASCADE NOT NULL,
  patient_id UUID REFERENCES patients(id) NOT NULL,
  name TEXT NOT NULL,
  value NUMERIC NOT NULL,
  unit TEXT,
  normal_min NUMERIC,
  normal_max NUMERIC,
  is_abnormal BOOLEAN GENERATED ALWAYS AS
    (value < normal_min OR value > normal_max) STORED,
  recorded_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_biomarkers_report ON biomarkers (report_id);
CREATE INDEX idx_biomarkers_patient ON biomarkers (patient_id);
CREATE INDEX idx_biomarkers_name ON biomarkers (name);
CREATE INDEX idx_biomarkers_patient_name ON biomarkers (patient_id, name, recorded_at);

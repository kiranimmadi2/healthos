-- Lab reports
CREATE TABLE lab_reports (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE NOT NULL,
  visit_id UUID REFERENCES visits(id),
  report_type TEXT NOT NULL,
  report_date DATE NOT NULL,
  file_url TEXT,
  parsed_data JSONB,
  ai_summary TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'ready', 'error')),
  lab_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_lab_reports_patient ON lab_reports (patient_id);
CREATE INDEX idx_lab_reports_date ON lab_reports (report_date DESC);
CREATE INDEX idx_lab_reports_type ON lab_reports (report_type);
CREATE INDEX idx_lab_reports_status ON lab_reports (status);

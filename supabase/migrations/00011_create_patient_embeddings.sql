-- AI embeddings for RAG (Retrieval Augmented Generation)
CREATE TABLE patient_embeddings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  patient_id UUID REFERENCES patients(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  embedding vector(1536) NOT NULL,
  source_type TEXT CHECK (source_type IN ('lab_report', 'visit', 'prescription', 'symptom_session')),
  source_id UUID,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_patient_embeddings_patient ON patient_embeddings (patient_id);
CREATE INDEX idx_patient_embeddings_vector ON patient_embeddings
  USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

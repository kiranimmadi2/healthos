-- Generate Health ID function
CREATE OR REPLACE FUNCTION generate_health_id()
RETURNS TEXT AS $$
DECLARE
  new_id TEXT;
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  suffix TEXT := '';
  i INT;
BEGIN
  LOOP
    suffix := '';
    FOR i IN 1..4 LOOP
      suffix := suffix || substr(chars, floor(random() * length(chars) + 1)::int, 1);
    END LOOP;
    new_id := 'HOS-' || EXTRACT(YEAR FROM NOW())::TEXT || '-' || suffix;
    EXIT WHEN NOT EXISTS (SELECT 1 FROM patients WHERE health_id = new_id);
  END LOOP;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- Match embeddings for RAG (vector similarity search)
CREATE OR REPLACE FUNCTION match_patient_embeddings(
  query_embedding vector(1536),
  match_patient_id UUID,
  match_threshold FLOAT DEFAULT 0.7,
  match_count INT DEFAULT 5
)
RETURNS TABLE (
  id UUID,
  content TEXT,
  source_type TEXT,
  source_id UUID,
  similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    pe.id,
    pe.content,
    pe.source_type,
    pe.source_id,
    1 - (pe.embedding <=> query_embedding) AS similarity
  FROM patient_embeddings pe
  WHERE pe.patient_id = match_patient_id
    AND 1 - (pe.embedding <=> query_embedding) > match_threshold
  ORDER BY pe.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

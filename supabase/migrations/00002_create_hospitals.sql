-- Hospitals table (created first as doctors reference it)
CREATE TABLE hospitals (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  address JSONB,
  license TEXT UNIQUE,
  phone TEXT,
  email TEXT,
  logo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_hospitals_name ON hospitals USING gin (name gin_trgm_ops);

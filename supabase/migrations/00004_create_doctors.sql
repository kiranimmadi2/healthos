-- Doctors table
CREATE TABLE doctors (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  full_name TEXT NOT NULL,
  specialization TEXT,
  hospital_id UUID REFERENCES hospitals(id),
  license_number TEXT UNIQUE NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  phone TEXT,
  email TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_doctors_auth_id ON doctors (auth_id);
CREATE INDEX idx_doctors_hospital ON doctors (hospital_id);
CREATE INDEX idx_doctors_name ON doctors USING gin (full_name gin_trgm_ops);
CREATE INDEX idx_doctors_specialization ON doctors (specialization);

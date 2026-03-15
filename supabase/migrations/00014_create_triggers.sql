-- Auto-generate health_id on patient insert
CREATE OR REPLACE FUNCTION auto_generate_health_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.health_id IS NULL OR NEW.health_id = '' THEN
    NEW.health_id := generate_health_id();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_health_id
  BEFORE INSERT ON patients
  FOR EACH ROW
  EXECUTE FUNCTION auto_generate_health_id();

-- Auto-update updated_at on patients
CREATE TRIGGER trigger_patients_updated_at
  BEFORE UPDATE ON patients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Auto-update updated_at on doctors
CREATE TRIGGER trigger_doctors_updated_at
  BEFORE UPDATE ON doctors
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Auto-update updated_at on hospitals
CREATE TRIGGER trigger_hospitals_updated_at
  BEFORE UPDATE ON hospitals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

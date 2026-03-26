-- ============================================================
-- Migration: Add updated_at columns to tables missing them
-- Tables affected: visits, lab_reports, biomarkers,
--                  prescriptions, symptom_sessions, notifications
-- ============================================================
-- Uses the existing update_updated_at() function defined in
-- 00013_create_functions.sql to auto-set updated_at on UPDATE.
-- ============================================================

-- ---------- visits ----------
ALTER TABLE public.visits
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.visits
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ---------- lab_reports ----------
ALTER TABLE public.lab_reports
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.lab_reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ---------- biomarkers ----------
ALTER TABLE public.biomarkers
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.biomarkers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ---------- prescriptions ----------
ALTER TABLE public.prescriptions
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.prescriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ---------- symptom_sessions ----------
ALTER TABLE public.symptom_sessions
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.symptom_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ---------- notifications ----------
ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.notifications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

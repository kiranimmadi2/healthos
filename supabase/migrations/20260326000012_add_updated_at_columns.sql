-- ============================================================
-- Migration: Add updated_at columns to tables missing them
-- Tables affected: visits, lab_reports, biomarkers,
--                  prescriptions, symptom_sessions,
--                  notifications, appointments (trigger only)
-- ============================================================
-- Uses the existing update_updated_at() function defined in
-- 00013_create_functions.sql to auto-set updated_at on UPDATE.
-- This migration is idempotent (safe to run multiple times).
-- ============================================================

-- ---------- visits ----------
ALTER TABLE public.visits
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_visits') THEN
    CREATE TRIGGER set_updated_at_visits
      BEFORE UPDATE ON public.visits
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- ---------- lab_reports ----------
ALTER TABLE public.lab_reports
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_lab_reports') THEN
    CREATE TRIGGER set_updated_at_lab_reports
      BEFORE UPDATE ON public.lab_reports
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- ---------- biomarkers ----------
ALTER TABLE public.biomarkers
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_biomarkers') THEN
    CREATE TRIGGER set_updated_at_biomarkers
      BEFORE UPDATE ON public.biomarkers
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- ---------- prescriptions ----------
ALTER TABLE public.prescriptions
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_prescriptions') THEN
    CREATE TRIGGER set_updated_at_prescriptions
      BEFORE UPDATE ON public.prescriptions
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- ---------- symptom_sessions ----------
ALTER TABLE public.symptom_sessions
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_symptom_sessions') THEN
    CREATE TRIGGER set_updated_at_symptom_sessions
      BEFORE UPDATE ON public.symptom_sessions
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- ---------- notifications ----------
ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_notifications') THEN
    CREATE TRIGGER set_updated_at_notifications
      BEFORE UPDATE ON public.notifications
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- ---------- appointments (already has updated_at column, just needs trigger) ----------
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_appointments') THEN
    CREATE TRIGGER set_updated_at_appointments
      BEFORE UPDATE ON public.appointments
      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- ============================================================
-- Notifications table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id uuid REFERENCES public.patients(id) ON DELETE CASCADE,
  doctor_id uuid REFERENCES public.doctors(id) ON DELETE CASCADE,
  title text NOT NULL,
  body text NOT NULL,
  type text DEFAULT 'info',
  read_at timestamptz,
  action_route text,
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_notifications_patient_id ON public.notifications(patient_id);
CREATE INDEX idx_notifications_doctor_id ON public.notifications(doctor_id);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Patients can view own notifications"
  ON public.notifications FOR SELECT
  USING (
    patient_id IN (SELECT id FROM public.patients WHERE auth_id = auth.uid())
  );

CREATE POLICY "Doctors can view own notifications"
  ON public.notifications FOR SELECT
  USING (
    doctor_id IN (SELECT id FROM public.doctors WHERE auth_id = auth.uid())
  );

CREATE POLICY "Service role can insert notifications"
  ON public.notifications FOR INSERT
  WITH CHECK (true);

-- ============================================================
-- Appointments table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.appointments (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  patient_id uuid NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE,
  doctor_id uuid NOT NULL REFERENCES public.doctors(id),
  hospital_id uuid REFERENCES public.hospitals(id),
  scheduled_at timestamptz NOT NULL,
  duration_minutes integer DEFAULT 30,
  status text DEFAULT 'scheduled',
  reason text,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_appointments_patient_id ON public.appointments(patient_id);
CREATE INDEX idx_appointments_doctor_id ON public.appointments(doctor_id);
CREATE INDEX idx_appointments_scheduled_at ON public.appointments(scheduled_at);
CREATE INDEX idx_appointments_status ON public.appointments(status);

ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Patients can view own appointments"
  ON public.appointments FOR SELECT
  USING (
    patient_id IN (SELECT id FROM public.patients WHERE auth_id = auth.uid())
  );

CREATE POLICY "Patients can create own appointments"
  ON public.appointments FOR INSERT
  WITH CHECK (
    patient_id IN (SELECT id FROM public.patients WHERE auth_id = auth.uid())
  );

CREATE POLICY "Patients can update own appointments"
  ON public.appointments FOR UPDATE
  USING (
    patient_id IN (SELECT id FROM public.patients WHERE auth_id = auth.uid())
  );

CREATE POLICY "Doctors can view their appointments"
  ON public.appointments FOR SELECT
  USING (
    doctor_id IN (SELECT id FROM public.doctors WHERE auth_id = auth.uid())
  );

CREATE POLICY "Doctors can update their appointments"
  ON public.appointments FOR UPDATE
  USING (
    doctor_id IN (SELECT id FROM public.doctors WHERE auth_id = auth.uid())
  );

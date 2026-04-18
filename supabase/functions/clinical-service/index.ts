/**
 * Clinical Microservice
 *
 * Handles all clinical data operations:
 * - Visits (doctor-patient encounters)
 * - Lab Reports (upload, status tracking)
 * - Biomarkers (test values, trends)
 * - Prescriptions (medications)
 *
 * Routes:
 *   GET    /visits/patient/:patientId      → List visits for patient
 *   GET    /visits/:id                     → Get visit by ID
 *   POST   /visits                         → Create visit
 *   PUT    /visits/:id                     → Update visit
 *
 *   GET    /reports/patient/:patientId     → List lab reports for patient
 *   GET    /reports/:id                    → Get report by ID
 *   POST   /reports                        → Create lab report
 *   PUT    /reports/:id                    → Update report (status, parsed data)
 *
 *   GET    /biomarkers/patient/:patientId  → All biomarkers for patient
 *   GET    /biomarkers/report/:reportId    → Biomarkers for a report
 *   GET    /biomarkers/trends/:patientId   → Biomarker trends over time
 *   GET    /biomarkers/abnormal/:patientId → Abnormal values only
 *
 *   GET    /prescriptions/patient/:patientId → List prescriptions
 *   GET    /prescriptions/:id                → Get prescription by ID
 *   POST   /prescriptions                    → Create prescription
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { Router } from '../_shared/router.ts';
import { createServiceHandler, requireAuth, json, errorResponse } from '../_shared/middleware.ts';
import { supabaseAdmin } from '../_shared/supabase-client.ts';

const router = new Router();

// ─── Visits ─────────────────────────────────────────────────

router.get('/visits/patient/:patientId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '50');
  const offset = parseInt(ctx.query.get('offset') || '0');

  const { data, error, count } = await supabaseAdmin
    .from('visits')
    .select('*', { count: 'exact' })
    .eq('patient_id', ctx.params.patientId)
    .order('visited_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

router.get('/visits/:id', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('visits')
    .select('*')
    .eq('id', ctx.params.id)
    .single();

  if (error) return errorResponse(`Visit not found: ${error.message}`, 404);
  return json(data);
}));

router.post('/visits', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  if (!body.patient_id || !body.doctor_id) {
    return errorResponse('patient_id and doctor_id are required');
  }

  const { data, error } = await supabaseAdmin
    .from('visits')
    .insert({
      patient_id: body.patient_id,
      doctor_id: body.doctor_id,
      hospital_id: body.hospital_id,
      visited_at: body.visited_at || new Date().toISOString(),
      chief_complaint: body.chief_complaint,
      diagnosis: body.diagnosis,
      notes: body.notes,
    })
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);
  return json(data, 201);
}));

router.put('/visits/:id', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  const { data, error } = await supabaseAdmin
    .from('visits')
    .update(body)
    .eq('id', ctx.params.id)
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);
  return json(data);
}));

// ─── Lab Reports ────────────────────────────────────────────

router.get('/reports/patient/:patientId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '50');
  const offset = parseInt(ctx.query.get('offset') || '0');
  const status = ctx.query.get('status');
  const reportType = ctx.query.get('type');

  let query = supabaseAdmin
    .from('lab_reports')
    .select('*', { count: 'exact' })
    .eq('patient_id', ctx.params.patientId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (status) query = query.eq('status', status);
  if (reportType) query = query.eq('report_type', reportType);

  const { data, error, count } = await query;

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

router.get('/reports/:id', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('lab_reports')
    .select('*')
    .eq('id', ctx.params.id)
    .single();

  if (error) return errorResponse(`Report not found: ${error.message}`, 404);
  return json(data);
}));

router.post('/reports', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  if (!body.patient_id) {
    return errorResponse('patient_id is required');
  }

  const { data, error } = await supabaseAdmin
    .from('lab_reports')
    .insert({
      patient_id: body.patient_id,
      visit_id: body.visit_id,
      report_type: body.report_type,
      report_date: body.report_date,
      file_url: body.file_url,
      lab_name: body.lab_name,
      status: 'pending',
    })
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);
  return json(data, 201);
}));

router.put('/reports/:id', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  const { data, error } = await supabaseAdmin
    .from('lab_reports')
    .update({
      ...body,
      updated_at: new Date().toISOString(),
    })
    .eq('id', ctx.params.id)
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);
  return json(data);
}));

// ─── Biomarkers ─────────────────────────────────────────────

router.get('/biomarkers/patient/:patientId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '100');
  const offset = parseInt(ctx.query.get('offset') || '0');

  const { data, error, count } = await supabaseAdmin
    .from('biomarkers')
    .select('*', { count: 'exact' })
    .eq('patient_id', ctx.params.patientId)
    .order('recorded_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

router.get('/biomarkers/report/:reportId', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('biomarkers')
    .select('*')
    .eq('report_id', ctx.params.reportId)
    .order('name');

  if (error) return errorResponse(error.message, 500);
  return json(data);
}));

router.get('/biomarkers/trends/:patientId', requireAuth(async (ctx) => {
  const name = ctx.query.get('name');
  if (!name) return errorResponse('Query parameter "name" is required (biomarker name)');

  const { data, error } = await supabaseAdmin
    .from('biomarkers')
    .select('value, unit, normal_min, normal_max, is_abnormal, recorded_at')
    .eq('patient_id', ctx.params.patientId)
    .eq('name', name)
    .order('recorded_at', { ascending: true });

  if (error) return errorResponse(error.message, 500);
  return json({ name, data_points: data });
}));

router.get('/biomarkers/abnormal/:patientId', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('biomarkers')
    .select('*')
    .eq('patient_id', ctx.params.patientId)
    .eq('is_abnormal', true)
    .order('recorded_at', { ascending: false });

  if (error) return errorResponse(error.message, 500);
  return json(data);
}));

// ─── Prescriptions ──────────────────────────────────────────

router.get('/prescriptions/patient/:patientId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '50');
  const offset = parseInt(ctx.query.get('offset') || '0');

  const { data, error, count } = await supabaseAdmin
    .from('prescriptions')
    .select('*', { count: 'exact' })
    .eq('patient_id', ctx.params.patientId)
    .order('issued_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

router.get('/prescriptions/:id', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('prescriptions')
    .select('*')
    .eq('id', ctx.params.id)
    .single();

  if (error) return errorResponse(`Prescription not found: ${error.message}`, 404);
  return json(data);
}));

router.post('/prescriptions', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  if (!body.patient_id || !body.doctor_id || !body.medications) {
    return errorResponse('patient_id, doctor_id, and medications are required');
  }

  const { data, error } = await supabaseAdmin
    .from('prescriptions')
    .insert({
      patient_id: body.patient_id,
      doctor_id: body.doctor_id,
      visit_id: body.visit_id,
      medications: body.medications,
      issued_at: body.issued_at || new Date().toISOString(),
      valid_until: body.valid_until,
      notes: body.notes,
    })
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);
  return json(data, 201);
}));

// ─── Visit Vitals ───────────────────────────────────────────

router.post('/vitals', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();
  if (!body.visit_id || !body.patient_id) {
    return errorResponse('visit_id and patient_id are required');
  }
  const { data, error } = await supabaseAdmin
    .from('visit_vitals')
    .insert({
      visit_id: body.visit_id,
      patient_id: body.patient_id,
      bp_systolic: body.bp_systolic ?? null,
      bp_diastolic: body.bp_diastolic ?? null,
      heart_rate: body.heart_rate ?? null,
      temperature_c: body.temperature_c ?? null,
      weight_kg: body.weight_kg ?? null,
      height_cm: body.height_cm ?? null,
      spo2_percent: body.spo2_percent ?? null,
      recorded_by: ctx.userId,
    })
    .select()
    .single();
  if (error) return errorResponse(error.message, 422);
  return json(data, 201);
}));

router.get('/vitals/visit/:visitId', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('visit_vitals')
    .select()
    .eq('visit_id', ctx.params.visitId)
    .maybeSingle();
  if (error) return errorResponse(error.message, 500);
  return json(data);
}));

router.get('/vitals/patient/:patientId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '20');
  const offset = parseInt(ctx.query.get('offset') || '0');
  const { data, error } = await supabaseAdmin
    .from('visit_vitals')
    .select()
    .eq('patient_id', ctx.params.patientId)
    .order('recorded_at', { ascending: false })
    .range(offset, offset + limit - 1);
  if (error) return errorResponse(error.message, 500);
  return json(data);
}));

// ─── Doctor Notes ────────────────────────────────────────────

router.get('/notes/patient/:patientId', requireAuth(async (ctx) => {
  const includePrivate = ctx.query.get('include_private') !== 'false';
  const limit = parseInt(ctx.query.get('limit') || '50');
  const offset = parseInt(ctx.query.get('offset') || '0');

  let query = supabaseAdmin
    .from('doctor_notes')
    .select()
    .eq('patient_id', ctx.params.patientId);
  if (!includePrivate) query = query.eq('is_private', false);

  const { data, error } = await query
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);
  if (error) return errorResponse(error.message, 500);
  return json(data);
}));

router.post('/notes', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();
  if (!body.patient_id || !body.content) {
    return errorResponse('patient_id and content are required');
  }
  const { data, error } = await supabaseAdmin
    .from('doctor_notes')
    .insert({
      patient_id: body.patient_id,
      doctor_id: body.doctor_id ?? ctx.userId,
      content: body.content,
      is_private: body.is_private ?? true,
    })
    .select()
    .single();
  if (error) return errorResponse(error.message, 422);
  return json(data, 201);
}));

router.put('/notes/:id', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();
  const { data, error } = await supabaseAdmin
    .from('doctor_notes')
    .update({ content: body.content, is_private: body.is_private })
    .eq('id', ctx.params.id)
    .select()
    .single();
  if (error) return errorResponse(error.message, 422);
  return json(data);
}));

router.delete('/notes/:id', requireAuth(async (ctx) => {
  const { error } = await supabaseAdmin
    .from('doctor_notes')
    .delete()
    .eq('id', ctx.params.id);
  if (error) return errorResponse(error.message, 422);
  return json({ success: true });
}));

// ─── Patient Medical History (doctor-editable fields only) ───

router.patch('/patients/:id/medical-history', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  // Only allow updating clinical fields — not personal demographics
  const allowed: Record<string, unknown> = {};
  if (body.allergies !== undefined) allowed['allergies'] = body.allergies;
  if (body.chronic_conditions !== undefined) allowed['chronic_conditions'] = body.chronic_conditions;
  if (body.emergency_contact !== undefined) allowed['emergency_contact'] = body.emergency_contact;

  if (Object.keys(allowed).length === 0) {
    return errorResponse('No editable fields provided');
  }

  const { data, error } = await supabaseAdmin
    .from('patients')
    .update(allowed)
    .eq('id', ctx.params.id)
    .select()
    .single();
  if (error) return errorResponse(error.message, 422);
  return json(data);
}));

// ─── Start service ──────────────────────────────────────────

serve(createServiceHandler(router));

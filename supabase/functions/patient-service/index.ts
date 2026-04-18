/**
 * Patient Microservice
 *
 * Handles all patient-related operations:
 * - Patient CRUD (create, read, update, search)
 * - Patient profiles and health IDs
 * - Access grants (data sharing permissions)
 *
 * Routes:
 *   GET    /patients/:id          → Get patient by ID
 *   GET    /patients/auth/:authId → Get patient by auth ID
 *   GET    /patients/health/:hid  → Get patient by health ID
 *   POST   /patients              → Create patient
 *   PUT    /patients/:id          → Update patient
 *   GET    /patients/search       → Search patients (?q=term)
 *   GET    /access-grants/:patientId       → List access grants
 *   POST   /access-grants                  → Create access grant
 *   DELETE /access-grants/:id              → Revoke access grant
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { Router } from '../_shared/router.ts';
import { createServiceHandler, requireAuth, json, errorResponse } from '../_shared/middleware.ts';
import { supabaseAdmin } from '../_shared/supabase-client.ts';

const router = new Router();

// ─── Patient CRUD ───────────────────────────────────────────

router.get('/patients/auth/:authId', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('patients')
    .select('*')
    .eq('auth_id', ctx.params.authId)
    .single();

  if (error) return errorResponse(`Patient not found: ${error.message}`, 404);
  return json(data);
}));

router.get('/patients/health/:healthId', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('patients')
    .select('*')
    .eq('health_id', ctx.params.healthId)
    .single();

  if (error) return errorResponse(`Patient not found: ${error.message}`, 404);
  return json(data);
}));

router.get('/patients/search', requireAuth(async (ctx) => {
  const query = ctx.query.get('q');
  const limit = parseInt(ctx.query.get('limit') || '20');
  const offset = parseInt(ctx.query.get('offset') || '0');

  if (!query) return errorResponse('Query parameter "q" is required');

  const { data, error, count } = await supabaseAdmin
    .from('patients')
    .select('*', { count: 'exact' })
    .or(`full_name.ilike.%${query}%,health_id.ilike.%${query}%,phone.ilike.%${query}%`)
    .range(offset, offset + limit - 1)
    .order('full_name');

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

router.get('/patients/:id', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('patients')
    .select('*')
    .eq('id', ctx.params.id)
    .single();

  if (error) return errorResponse(`Patient not found: ${error.message}`, 404);
  return json(data);
}));

router.post('/patients', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  const { data, error } = await supabaseAdmin
    .from('patients')
    .insert({
      auth_id: body.auth_id || ctx.userId,
      health_id: body.health_id,
      phone: body.phone,
      full_name: body.full_name,
      date_of_birth: body.date_of_birth,
      gender: body.gender,
      blood_group: body.blood_group,
      allergies: body.allergies,
      chronic_conditions: body.chronic_conditions,
      emergency_contact: body.emergency_contact,
    })
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);
  return json(data, 201);
}));

router.put('/patients/:id', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  const { data, error } = await supabaseAdmin
    .from('patients')
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

// ─── Access Grants ──────────────────────────────────────────

router.get('/access-grants/:patientId', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('access_grants')
    .select('*')
    .eq('patient_id', ctx.params.patientId)
    .order('created_at', { ascending: false });

  if (error) return errorResponse(error.message, 500);
  return json(data);
}));

router.post('/access-grants', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  if (!body.patient_id || !body.granted_to_id) {
    return errorResponse('patient_id and granted_to_id are required');
  }

  const { data, error } = await supabaseAdmin
    .from('access_grants')
    .insert({
      patient_id: body.patient_id,
      granted_to_id: body.granted_to_id,
      granted_to_role: body.granted_to_role || 'doctor',
      access_level: body.access_level || 'read',
      expires_at: body.expires_at,
    })
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);
  return json(data, 201);
}));

router.delete('/access-grants/:id', requireAuth(async (ctx) => {
  const { error } = await supabaseAdmin
    .from('access_grants')
    .delete()
    .eq('id', ctx.params.id);

  if (error) return errorResponse(error.message, 500);
  return json({ success: true, message: 'Access grant revoked' });
}));

// ─── Start service ──────────────────────────────────────────

serve(createServiceHandler(router));

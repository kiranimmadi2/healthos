/**
 * Family Service
 *
 * Manages family member relationships for patients.
 *
 * Routes:
 *   GET    /family/:primaryPatientId        → List family members
 *   POST   /family                          → Add family member
 *   PUT    /family/:memberId                → Update member details/permissions
 *   DELETE /family/:memberId                → Remove member
 *   PUT    /family/:memberId/link           → Link to an existing HealthOS patient
 *   POST   /family/:memberId/invite         → Send SMS invite
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { Router } from '../_shared/router.ts';
import { createServiceHandler, requireAuth, json, errorResponse } from '../_shared/middleware.ts';
import { supabaseAdmin } from '../_shared/supabase-client.ts';

const router = new Router();

// ─── List family members ─────────────────────────────────────

router.get('/family/:primaryPatientId', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('family_members')
    .select()
    .eq('primary_patient_id', ctx.params.primaryPatientId)
    .order('created_at', { ascending: true });
  if (error) return errorResponse(error.message, 500);
  return json(data);
}));

// ─── Add family member ───────────────────────────────────────

router.post('/family', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();
  if (!body.primary_patient_id || !body.relationship || !body.full_name) {
    return errorResponse('primary_patient_id, relationship, and full_name are required');
  }

  const validRelationships = ['spouse', 'child', 'parent', 'sibling', 'guardian', 'other'];
  if (!validRelationships.includes(body.relationship as string)) {
    return errorResponse(`relationship must be one of: ${validRelationships.join(', ')}`);
  }

  const { data, error } = await supabaseAdmin
    .from('family_members')
    .insert({
      primary_patient_id: body.primary_patient_id,
      relationship: body.relationship,
      full_name: body.full_name,
      date_of_birth: body.date_of_birth ?? null,
      gender: body.gender ?? null,
      phone: body.phone ?? null,
      is_dependent: body.is_dependent ?? false,
      can_view_records: body.can_view_records ?? false,
      can_manage_appointments: body.can_manage_appointments ?? false,
    })
    .select()
    .single();
  if (error) return errorResponse(error.message, 422);
  return json(data, 201);
}));

// ─── Update family member ────────────────────────────────────

router.put('/family/:memberId', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();
  const allowed: Record<string, unknown> = {};

  const updatableFields = [
    'relationship', 'full_name', 'date_of_birth', 'gender', 'phone',
    'is_dependent', 'can_view_records', 'can_manage_appointments',
  ];
  for (const field of updatableFields) {
    if (body[field] !== undefined) allowed[field] = body[field];
  }

  if (Object.keys(allowed).length === 0) return errorResponse('No fields to update');

  const { data, error } = await supabaseAdmin
    .from('family_members')
    .update(allowed)
    .eq('id', ctx.params.memberId)
    .select()
    .single();
  if (error) return errorResponse(error.message, 422);
  return json(data);
}));

// ─── Delete family member ────────────────────────────────────

router.delete('/family/:memberId', requireAuth(async (ctx) => {
  const { error } = await supabaseAdmin
    .from('family_members')
    .delete()
    .eq('id', ctx.params.memberId);
  if (error) return errorResponse(error.message, 422);
  return json({ success: true });
}));

// ─── Link to existing HealthOS patient ──────────────────────

router.put('/family/:memberId/link', requireAuth(async (ctx) => {
  const body = await ctx.body<{ patient_id: string }>();
  if (!body.patient_id) return errorResponse('patient_id is required');

  // Verify the patient exists
  const { data: patient } = await supabaseAdmin
    .from('patients')
    .select('id')
    .eq('id', body.patient_id)
    .maybeSingle();
  if (!patient) return errorResponse('Patient not found', 404);

  const { data, error } = await supabaseAdmin
    .from('family_members')
    .update({
      member_patient_id: body.patient_id,
      invite_status: 'linked',
      linked_at: new Date().toISOString(),
    })
    .eq('id', ctx.params.memberId)
    .select()
    .single();
  if (error) return errorResponse(error.message, 422);
  return json(data);
}));

// ─── Send invite notification ────────────────────────────────

router.post('/family/:memberId/invite', requireAuth(async (ctx) => {
  const { data: member, error: fetchError } = await supabaseAdmin
    .from('family_members')
    .select()
    .eq('id', ctx.params.memberId)
    .single();
  if (fetchError || !member) return errorResponse('Family member not found', 404);
  if (!member.phone) return errorResponse('Member has no phone number for invite');

  // Mark as invited
  await supabaseAdmin
    .from('family_members')
    .update({ invite_status: 'invited', invited_at: new Date().toISOString() })
    .eq('id', ctx.params.memberId);

  // Fire notification (best-effort) — actual SMS would go via a provider
  console.log(`[family-service] Invite sent to ${member.phone} for member ${member.full_name}`);

  return json({ success: true, phone: member.phone });
}));

// ─── Start service ───────────────────────────────────────────

serve(createServiceHandler(router));

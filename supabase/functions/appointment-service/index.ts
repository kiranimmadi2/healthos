/**
 * Appointment Microservice
 *
 * Handles all scheduling operations:
 * - Appointment CRUD
 * - Doctor availability / conflict checking
 * - Patient upcoming appointments
 * - Calendar views (by date range)
 *
 * Routes:
 *   GET    /appointments/patient/:patientId   → Patient's appointments
 *   GET    /appointments/doctor/:doctorId     → Doctor's appointments
 *   GET    /appointments/upcoming/:patientId  → Upcoming appointments
 *   GET    /appointments/schedule/:doctorId   → Doctor schedule (date range)
 *   GET    /appointments/:id                  → Get appointment by ID
 *   POST   /appointments                      → Book appointment
 *   PUT    /appointments/:id                  → Update appointment
 *   POST   /appointments/:id/cancel           → Cancel appointment
 *   GET    /availability/:doctorId            → Check doctor availability
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { Router } from '../_shared/router.ts';
import { createServiceHandler, requireAuth, json, errorResponse } from '../_shared/middleware.ts';
import { supabaseAdmin } from '../_shared/supabase-client.ts';
import { callService } from '../_shared/service-client.ts';

const router = new Router();

// ─── Query Appointments ─────────────────────────────────────

router.get('/appointments/patient/:patientId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '50');
  const offset = parseInt(ctx.query.get('offset') || '0');
  const status = ctx.query.get('status');

  let query = supabaseAdmin
    .from('appointments')
    .select('*', { count: 'exact' })
    .eq('patient_id', ctx.params.patientId)
    .order('scheduled_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (status) query = query.eq('status', status);

  const { data, error, count } = await query;

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

router.get('/appointments/doctor/:doctorId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '50');
  const offset = parseInt(ctx.query.get('offset') || '0');

  const { data, error, count } = await supabaseAdmin
    .from('appointments')
    .select('*', { count: 'exact' })
    .eq('doctor_id', ctx.params.doctorId)
    .order('scheduled_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

router.get('/appointments/upcoming/:patientId', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('appointments')
    .select('*')
    .eq('patient_id', ctx.params.patientId)
    .gte('scheduled_at', new Date().toISOString())
    .in('status', ['scheduled', 'confirmed'])
    .order('scheduled_at', { ascending: true })
    .limit(10);

  if (error) return errorResponse(error.message, 500);
  return json(data);
}));

router.get('/appointments/schedule/:doctorId', requireAuth(async (ctx) => {
  const from = ctx.query.get('from');
  const to = ctx.query.get('to');

  if (!from || !to) {
    return errorResponse('Query parameters "from" and "to" are required (ISO date strings)');
  }

  const { data, error } = await supabaseAdmin
    .from('appointments')
    .select('*')
    .eq('doctor_id', ctx.params.doctorId)
    .gte('scheduled_at', from)
    .lte('scheduled_at', to)
    .neq('status', 'cancelled')
    .order('scheduled_at', { ascending: true });

  if (error) return errorResponse(error.message, 500);
  return json(data);
}));

router.get('/appointments/:id', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('appointments')
    .select('*')
    .eq('id', ctx.params.id)
    .single();

  if (error) return errorResponse(`Appointment not found: ${error.message}`, 404);
  return json(data);
}));

// ─── Book Appointment (with conflict detection) ─────────────

router.post('/appointments', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  if (!body.patient_id || !body.doctor_id || !body.scheduled_at) {
    return errorResponse('patient_id, doctor_id, and scheduled_at are required');
  }

  const scheduledAt = new Date(body.scheduled_at as string);
  const durationMinutes = (body.duration_minutes as number) || 30;
  const endTime = new Date(scheduledAt.getTime() + durationMinutes * 60000);

  // Check for conflicting appointments (same doctor, overlapping time)
  const { data: conflicts } = await supabaseAdmin
    .from('appointments')
    .select('id, scheduled_at, duration_minutes')
    .eq('doctor_id', body.doctor_id)
    .neq('status', 'cancelled')
    .gte('scheduled_at', new Date(scheduledAt.getTime() - durationMinutes * 60000).toISOString())
    .lte('scheduled_at', endTime.toISOString());

  if (conflicts && conflicts.length > 0) {
    // Check for actual overlap
    const hasConflict = conflicts.some((existing: any) => {
      const existStart = new Date(existing.scheduled_at);
      const existEnd = new Date(existStart.getTime() + (existing.duration_minutes || 30) * 60000);
      return scheduledAt < existEnd && endTime > existStart;
    });

    if (hasConflict) {
      return errorResponse('Time slot conflicts with an existing appointment', 409);
    }
  }

  const { data, error } = await supabaseAdmin
    .from('appointments')
    .insert({
      patient_id: body.patient_id,
      doctor_id: body.doctor_id,
      hospital_id: body.hospital_id,
      scheduled_at: body.scheduled_at,
      duration_minutes: durationMinutes,
      reason: body.reason,
      notes: body.notes,
      status: 'scheduled',
    })
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);

  // Fire notification to doctor (async, don't block)
  try {
    await callService('notification-service', '/notifications', {
      method: 'POST',
      body: {
        doctor_id: body.doctor_id,
        title: 'New Appointment',
        body: `New appointment scheduled for ${scheduledAt.toLocaleDateString()}`,
        type: 'appointment',
        metadata: { appointment_id: data.id },
      },
      authHeader: ctx.req.headers.get('Authorization') || undefined,
    });
  } catch (e) {
    console.warn('Failed to send appointment notification:', e.message);
  }

  return json(data, 201);
}));

// ─── Update Appointment ─────────────────────────────────────

router.put('/appointments/:id', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  const { data, error } = await supabaseAdmin
    .from('appointments')
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

// ─── Cancel Appointment ─────────────────────────────────────

router.post('/appointments/:id/cancel', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  const { data, error } = await supabaseAdmin
    .from('appointments')
    .update({
      status: 'cancelled',
      notes: body.reason ? `Cancelled: ${body.reason}` : 'Cancelled',
      updated_at: new Date().toISOString(),
    })
    .eq('id', ctx.params.id)
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);

  // Notify patient about cancellation
  if (data.patient_id) {
    try {
      await callService('notification-service', '/notifications', {
        method: 'POST',
        body: {
          patient_id: data.patient_id,
          title: 'Appointment Cancelled',
          body: `Your appointment has been cancelled.`,
          type: 'appointment',
          metadata: { appointment_id: data.id },
        },
        authHeader: ctx.req.headers.get('Authorization') || undefined,
      });
    } catch (e) {
      console.warn('Failed to send cancellation notification:', e.message);
    }
  }

  return json(data);
}));

// ─── Doctor Availability ────────────────────────────────────

router.get('/availability/:doctorId', requireAuth(async (ctx) => {
  const date = ctx.query.get('date');
  if (!date) return errorResponse('Query parameter "date" is required (YYYY-MM-DD)');

  const dayStart = `${date}T00:00:00.000Z`;
  const dayEnd = `${date}T23:59:59.999Z`;

  // Get all non-cancelled appointments for that day
  const { data: booked, error } = await supabaseAdmin
    .from('appointments')
    .select('scheduled_at, duration_minutes')
    .eq('doctor_id', ctx.params.doctorId)
    .neq('status', 'cancelled')
    .gte('scheduled_at', dayStart)
    .lte('scheduled_at', dayEnd)
    .order('scheduled_at', { ascending: true });

  if (error) return errorResponse(error.message, 500);

  // Generate available slots (9 AM to 5 PM, 30-min intervals)
  const slots: { time: string; available: boolean }[] = [];
  for (let hour = 9; hour < 17; hour++) {
    for (const min of [0, 30]) {
      const slotStart = new Date(`${date}T${String(hour).padStart(2, '0')}:${String(min).padStart(2, '0')}:00.000Z`);
      const slotEnd = new Date(slotStart.getTime() + 30 * 60000);

      const isBooked = (booked || []).some((appt: any) => {
        const apptStart = new Date(appt.scheduled_at);
        const apptEnd = new Date(apptStart.getTime() + (appt.duration_minutes || 30) * 60000);
        return slotStart < apptEnd && slotEnd > apptStart;
      });

      slots.push({
        time: slotStart.toISOString(),
        available: !isBooked,
      });
    }
  }

  return json({
    doctor_id: ctx.params.doctorId,
    date,
    slots,
    booked_count: booked?.length || 0,
    available_count: slots.filter(s => s.available).length,
  });
}));

// ─── Start service ──────────────────────────────────────────

serve(createServiceHandler(router));

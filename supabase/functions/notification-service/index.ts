/**
 * Notification Microservice
 *
 * Handles all notification operations:
 * - In-app notifications (CRUD)
 * - Push notification dispatch (FCM/Expo)
 * - Notification preferences
 * - Unread counts and mark-as-read
 *
 * Routes:
 *   GET    /notifications/patient/:patientId  → Patient notifications
 *   GET    /notifications/doctor/:doctorId    → Doctor notifications
 *   GET    /notifications/unread/:userId      → Unread count
 *   POST   /notifications                     → Create & send notification
 *   PUT    /notifications/:id/read            → Mark as read
 *   PUT    /notifications/read-all/:userId    → Mark all as read
 *   POST   /notifications/bulk                → Send bulk notifications
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { Router } from '../_shared/router.ts';
import { createServiceHandler, requireAuth, json, errorResponse } from '../_shared/middleware.ts';
import { supabaseAdmin } from '../_shared/supabase-client.ts';

const router = new Router();

// ─── Query Notifications ────────────────────────────────────

router.get('/notifications/patient/:patientId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '50');
  const offset = parseInt(ctx.query.get('offset') || '0');
  const unreadOnly = ctx.query.get('unread') === 'true';

  let query = supabaseAdmin
    .from('notifications')
    .select('*', { count: 'exact' })
    .eq('patient_id', ctx.params.patientId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (unreadOnly) query = query.is('read_at', null);

  const { data, error, count } = await query;

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

router.get('/notifications/doctor/:doctorId', requireAuth(async (ctx) => {
  const limit = parseInt(ctx.query.get('limit') || '50');
  const offset = parseInt(ctx.query.get('offset') || '0');

  const { data, error, count } = await supabaseAdmin
    .from('notifications')
    .select('*', { count: 'exact' })
    .eq('doctor_id', ctx.params.doctorId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) return errorResponse(error.message, 500);
  return json({ data, total: count, limit, offset });
}));

router.get('/notifications/unread/:userId', requireAuth(async (ctx) => {
  // Check both patient_id and doctor_id columns
  const { count: patientCount } = await supabaseAdmin
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('patient_id', ctx.params.userId)
    .is('read_at', null);

  const { count: doctorCount } = await supabaseAdmin
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('doctor_id', ctx.params.userId)
    .is('read_at', null);

  return json({ unread_count: (patientCount || 0) + (doctorCount || 0) });
}));

// ─── Create & Send Notification ─────────────────────────────

router.post('/notifications', requireAuth(async (ctx) => {
  const body = await ctx.body<Record<string, unknown>>();

  if (!body.title || !body.body) {
    return errorResponse('title and body are required');
  }

  if (!body.patient_id && !body.doctor_id) {
    return errorResponse('Either patient_id or doctor_id is required');
  }

  // Store notification in database
  const { data, error } = await supabaseAdmin
    .from('notifications')
    .insert({
      patient_id: body.patient_id || null,
      doctor_id: body.doctor_id || null,
      title: body.title,
      body: body.body,
      type: body.type || 'info',
      action_route: body.action_route,
      metadata: body.metadata || {},
      created_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);

  // TODO: Dispatch push notification via FCM/Expo
  // This is where you'd integrate with:
  // - Firebase Cloud Messaging (FCM) for Android
  // - Apple Push Notification Service (APNs) via FCM
  // - Expo Push Notifications for React Native
  // - OneSignal as unified provider
  //
  // Example FCM integration:
  // const fcmToken = await getUserFcmToken(body.patient_id || body.doctor_id);
  // if (fcmToken) {
  //   await sendFcmNotification(fcmToken, body.title, body.body, body.metadata);
  // }

  console.log(`[notification-service] Sent: "${body.title}" to ${body.patient_id || body.doctor_id}`);

  return json(data, 201);
}));

// ─── Mark as Read ───────────────────────────────────────────

router.put('/notifications/:id/read', requireAuth(async (ctx) => {
  const { data, error } = await supabaseAdmin
    .from('notifications')
    .update({ read_at: new Date().toISOString() })
    .eq('id', ctx.params.id)
    .select()
    .single();

  if (error) return errorResponse(error.message, 422);
  return json(data);
}));

router.put('/notifications/read-all/:userId', requireAuth(async (ctx) => {
  const now = new Date().toISOString();

  // Mark all unread for this user (check both columns)
  await supabaseAdmin
    .from('notifications')
    .update({ read_at: now })
    .eq('patient_id', ctx.params.userId)
    .is('read_at', null);

  await supabaseAdmin
    .from('notifications')
    .update({ read_at: now })
    .eq('doctor_id', ctx.params.userId)
    .is('read_at', null);

  return json({ success: true, message: 'All notifications marked as read' });
}));

// ─── Bulk Notifications ─────────────────────────────────────

router.post('/notifications/bulk', requireAuth(async (ctx) => {
  const body = await ctx.body<{
    recipients: Array<{ patient_id?: string; doctor_id?: string }>;
    title: string;
    body: string;
    type?: string;
    metadata?: Record<string, unknown>;
  }>();

  if (!body.recipients?.length || !body.title || !body.body) {
    return errorResponse('recipients (array), title, and body are required');
  }

  const records = body.recipients.map(r => ({
    patient_id: r.patient_id || null,
    doctor_id: r.doctor_id || null,
    title: body.title,
    body: body.body,
    type: body.type || 'info',
    metadata: body.metadata || {},
    created_at: new Date().toISOString(),
  }));

  const { data, error } = await supabaseAdmin
    .from('notifications')
    .insert(records)
    .select();

  if (error) return errorResponse(error.message, 422);

  console.log(`[notification-service] Bulk sent "${body.title}" to ${records.length} recipients`);

  return json({ success: true, sent: data?.length || 0 });
}));

// ─── Start service ──────────────────────────────────────────

serve(createServiceHandler(router));

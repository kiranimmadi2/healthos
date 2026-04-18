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

async function getFcmAccessToken(): Promise<string | null> {
  const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  if (!serviceAccountJson) return null;

  let serviceAccount: { client_email: string; private_key: string; project_id: string };
  try {
    serviceAccount = JSON.parse(serviceAccountJson);
  } catch {
    console.error('[notification-service] Invalid FIREBASE_SERVICE_ACCOUNT_JSON');
    return null;
  }

  const now = Math.floor(Date.now() / 1000);
  const header = btoa(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const payload = btoa(JSON.stringify({
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  }));

  const signingInput = `${header}.${payload}`;
  const pemKey = serviceAccount.private_key.replace(/\\n/g, '\n');
  const binaryKey = pemKey
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '');
  const keyBuffer = Uint8Array.from(atob(binaryKey), c => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8', keyBuffer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false, ['sign'],
  );
  const signatureBuffer = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5', cryptoKey,
    new TextEncoder().encode(signingInput),
  );
  const signature = btoa(String.fromCharCode(...new Uint8Array(signatureBuffer)));
  const jwt = `${signingInput}.${signature}`;

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });
  if (!tokenRes.ok) return null;
  const { access_token } = await tokenRes.json();
  return access_token as string;
}

async function sendFcmPush(fcmToken: string, title: string, body: string, data?: Record<string, string>): Promise<void> {
  const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  if (!serviceAccountJson) return;

  let projectId: string;
  try {
    projectId = JSON.parse(serviceAccountJson).project_id;
  } catch {
    return;
  }

  const accessToken = await getFcmAccessToken();
  if (!accessToken) return;

  await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: {
        token: fcmToken,
        notification: { title, body },
        data: data ?? {},
      },
    }),
  });
}

async function dispatchPush(userId: string | null | undefined, title: string, body: string, metadata?: Record<string, unknown>): Promise<void> {
  if (!userId) return;

  const data = metadata ? Object.fromEntries(
    Object.entries(metadata).map(([k, v]) => [k, String(v)])
  ) : undefined;

  const { data: patient } = await supabaseAdmin
    .from('patients').select('fcm_token').eq('id', userId).maybeSingle();
  if (patient?.fcm_token) {
    await sendFcmPush(patient.fcm_token, title, body, data);
    return;
  }

  const { data: doctor } = await supabaseAdmin
    .from('doctors').select('fcm_token').eq('id', userId).maybeSingle();
  if (doctor?.fcm_token) {
    await sendFcmPush(doctor.fcm_token, title, body, data);
  }
}

const router = new Router();

// ─── Register FCM Token ─────────────────────────────────────

router.put('/notifications/fcm-token', requireAuth(async (ctx) => {
  const body = await ctx.body<{ user_id: string; role: 'patient' | 'doctor'; fcm_token: string }>();
  if (!body.user_id || !body.role || !body.fcm_token) {
    return errorResponse('user_id, role, and fcm_token are required');
  }

  const table = body.role === 'patient' ? 'patients' : 'doctors';
  const { error } = await supabaseAdmin
    .from(table)
    .update({ fcm_token: body.fcm_token })
    .eq('id', body.user_id);

  if (error) return errorResponse(error.message, 422);
  return json({ success: true });
}));

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

  const recipientId = (body.patient_id || body.doctor_id) as string | undefined;
  await dispatchPush(recipientId, body.title as string, body.body as string, body.metadata as Record<string, unknown> | undefined);

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

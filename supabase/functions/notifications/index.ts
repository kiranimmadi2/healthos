import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { corsHeaders } from '../_shared/cors.ts';
import { supabaseAdmin } from '../_shared/supabase-client.ts';

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  // Verify authentication
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response(
      JSON.stringify({ error: 'Missing authorization header' }),
      { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }

  try {
    const { user_id, title, body, data } = await req.json();

    if (!user_id || !title || !body) {
      return new Response(
        JSON.stringify({ error: 'user_id, title, and body are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Log the notification request (placeholder implementation)
    console.log('--- Push Notification Request ---');
    console.log(`User ID: ${user_id}`);
    console.log(`Title: ${title}`);
    console.log(`Body: ${body}`);
    console.log(`Data: ${JSON.stringify(data || {})}`);
    console.log('--------------------------------');

    // Optionally store the notification in the database for history
    const { error: insertError } = await supabaseAdmin
      .from('notifications')
      .insert({
        user_id,
        title,
        body,
        data: data || {},
        status: 'sent',
        created_at: new Date().toISOString(),
      });

    if (insertError) {
      console.error('Failed to save notification record:', insertError.message);
      // Don't fail the request if DB insert fails — notification was still "sent"
    }

    // TODO: Integrate with a real push notification service
    // Examples: Firebase Cloud Messaging (FCM), Expo Push Notifications, OneSignal

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Notification sent successfully',
        user_id,
        title,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    console.error('notifications error:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});

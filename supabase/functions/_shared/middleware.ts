/**
 * Middleware utilities for microservice edge functions.
 * Handles CORS, auth verification, and request wrapping.
 */

import { corsHeaders } from './cors.ts';
import { Router, type RouteHandler, type RouteContext } from './router.ts';
import { getSupabaseClient } from './supabase-client.ts';

/**
 * Wraps a Router with CORS handling and global error catching.
 * This is the main entry point for all microservice edge functions.
 */
export function createServiceHandler(router: Router) {
  return async (req: Request): Promise<Response> => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
      return new Response('ok', { headers: corsHeaders });
    }

    try {
      const response = await router.handle(req);
      // Merge CORS headers into every response
      const headers = new Headers(response.headers);
      Object.entries(corsHeaders).forEach(([k, v]) => headers.set(k, v));
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers,
      });
    } catch (error) {
      console.error('Unhandled service error:', error);
      return new Response(
        JSON.stringify({ error: error.message || 'Internal server error' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }
  };
}

/**
 * Auth middleware — verifies the JWT and attaches userId to context.
 * Wraps a route handler to require authentication.
 */
export function requireAuth(handler: RouteHandler): RouteHandler {
  return async (ctx: RouteContext) => {
    const authHeader = ctx.req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } },
      );
    }

    try {
      const supabase = getSupabaseClient(authHeader);
      const { data: { user }, error } = await supabase.auth.getUser();

      if (error || !user) {
        return new Response(
          JSON.stringify({ error: 'Invalid or expired token' }),
          { status: 401, headers: { 'Content-Type': 'application/json' } },
        );
      }

      ctx.userId = user.id;
      ctx.userRole = user.role ?? null;
    } catch {
      return new Response(
        JSON.stringify({ error: 'Authentication failed' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } },
      );
    }

    return handler(ctx);
  };
}

/**
 * JSON response helper
 */
export function json(data: unknown, status = 200): Response {
  return new Response(
    JSON.stringify(data),
    { status, headers: { 'Content-Type': 'application/json' } },
  );
}

/**
 * Error response helper
 */
export function errorResponse(message: string, status = 400): Response {
  return new Response(
    JSON.stringify({ error: message }),
    { status, headers: { 'Content-Type': 'application/json' } },
  );
}

/**
 * Inter-service communication client.
 * Allows microservices to call each other via Supabase Edge Functions.
 */

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

export interface ServiceCallOptions {
  method?: string;
  body?: unknown;
  authHeader?: string;
}

/**
 * Call another edge function microservice internally.
 * Uses the service role key for inter-service auth.
 */
export async function callService<T = unknown>(
  functionName: string,
  path: string,
  options: ServiceCallOptions = {},
): Promise<T> {
  const { method = 'GET', body, authHeader } = options;
  const url = `${SUPABASE_URL}/functions/v1/${functionName}${path}`;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    'Authorization': authHeader || `Bearer ${SERVICE_ROLE_KEY}`,
  };

  const response = await fetch(url, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Service call to ${functionName}${path} failed (${response.status}): ${errorText}`);
  }

  return response.json() as Promise<T>;
}

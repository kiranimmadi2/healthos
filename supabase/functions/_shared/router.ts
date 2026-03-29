/**
 * Lightweight router for Supabase Edge Functions microservices.
 * Supports method + path-based routing within a single edge function.
 *
 * Usage:
 *   const router = new Router();
 *   router.get('/patients/:id', handler);
 *   router.post('/patients', handler);
 *   serve((req) => router.handle(req));
 */

export type RouteParams = Record<string, string>;

export interface RouteContext {
  req: Request;
  params: RouteParams;
  query: URLSearchParams;
  body: <T = unknown>() => Promise<T>;
  userId: string | null;
  userRole: string | null;
}

export type RouteHandler = (ctx: RouteContext) => Promise<Response> | Response;

interface Route {
  method: string;
  pattern: RegExp;
  paramNames: string[];
  handler: RouteHandler;
}

export class Router {
  private routes: Route[] = [];

  get(path: string, handler: RouteHandler) {
    this.addRoute('GET', path, handler);
  }

  post(path: string, handler: RouteHandler) {
    this.addRoute('POST', path, handler);
  }

  put(path: string, handler: RouteHandler) {
    this.addRoute('PUT', path, handler);
  }

  patch(path: string, handler: RouteHandler) {
    this.addRoute('PATCH', path, handler);
  }

  delete(path: string, handler: RouteHandler) {
    this.addRoute('DELETE', path, handler);
  }

  private addRoute(method: string, path: string, handler: RouteHandler) {
    const paramNames: string[] = [];
    const pattern = path.replace(/:(\w+)/g, (_, name) => {
      paramNames.push(name);
      return '([^/]+)';
    });
    this.routes.push({
      method,
      pattern: new RegExp(`^${pattern}$`),
      paramNames,
      handler,
    });
  }

  async handle(req: Request): Promise<Response> {
    const url = new URL(req.url);
    // Extract the path after the function name segment
    // e.g., /patient-service/patients/123 → /patients/123
    const fullPath = url.pathname;
    const segments = fullPath.split('/').filter(Boolean);
    // Remove the function name prefix (first 2 segments: functions/v1/fn-name)
    const servicePath = '/' + segments.slice(segments.indexOf('v1') + 2).join('/');
    const path = servicePath === '/' ? '/' : servicePath;

    for (const route of this.routes) {
      if (route.method !== req.method) continue;
      const match = path.match(route.pattern);
      if (!match) continue;

      const params: RouteParams = {};
      route.paramNames.forEach((name, i) => {
        params[name] = match[i + 1];
      });

      let cachedBody: unknown | undefined;
      const ctx: RouteContext = {
        req,
        params,
        query: url.searchParams,
        body: async <T = unknown>() => {
          if (cachedBody === undefined) {
            cachedBody = await req.json();
          }
          return cachedBody as T;
        },
        userId: null,
        userRole: null,
      };

      return route.handler(ctx);
    }

    return new Response(
      JSON.stringify({ error: 'Not found', path, method: req.method }),
      { status: 404, headers: { 'Content-Type': 'application/json' } },
    );
  }
}

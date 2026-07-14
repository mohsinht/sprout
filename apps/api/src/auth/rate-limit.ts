import type { Context, Next } from "hono";

type Bucket = { count: number; resetAt: number };

const buckets = new Map<string, Bucket>();

function clientAddress(c: Context): string {
  const forwarded = c.req.header("x-forwarded-for")?.split(",")[0]?.trim();
  return forwarded || c.req.header("x-real-ip") || "local";
}

export function authRateLimit(options: {
  scope: string;
  limit: number;
  windowMs: number;
  key?: (c: Context) => Promise<string> | string;
}) {
  return async (c: Context, next: Next) => {
    const suffix = options.key
      ? await options.key(c)
      : clientAddress(c);
    const key = `${options.scope}:${clientAddress(c)}:${suffix}`;
    const now = Date.now();
    const current = buckets.get(key);
    const bucket = !current || current.resetAt <= now
      ? { count: 0, resetAt: now + options.windowMs }
      : current;

    if (bucket.count >= options.limit) {
      const retryAfter = Math.max(1, Math.ceil((bucket.resetAt - now) / 1000));
      c.header("Retry-After", retryAfter.toString());
      return c.json(
        { error: "Too many attempts. Please wait a little and try again." },
        429,
      );
    }

    bucket.count += 1;
    buckets.set(key, bucket);
    await next();

    // Successful authentication starts a clean window. Failed attempts stay
    // counted so repeated password guessing is slowed down.
    if (c.res.status < 400) buckets.delete(key);
  };
}

export async function emailRateLimitKey(c: Context): Promise<string> {
  const body = await c.req.raw.clone().json().catch(() => ({})) as { email?: unknown };
  return typeof body.email === "string" ? body.email.trim().toLowerCase() : "invalid-email";
}

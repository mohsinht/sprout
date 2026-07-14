import { Hono } from "hono";
import { z } from "zod";
import { eq } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import {
  hashPassword,
  verifyPassword,
  signAccessToken,
  issueRefreshToken,
  verifyRefreshToken,
  revokeRefreshToken,
} from "./crypto.js";
import { authRateLimit, emailRateLimitKey } from "./rate-limit.js";

export const authRoute = new Hono<{ Variables: { userId: string } }>();

const fifteenMinutes = 15 * 60 * 1000;

authRoute.use(
  "/register",
  authRateLimit({ scope: "register", limit: 8, windowMs: fifteenMinutes }),
);
authRoute.use(
  "/login",
  authRateLimit({
    scope: "login",
    limit: 10,
    windowMs: fifteenMinutes,
    key: emailRateLimitKey,
  }),
);
authRoute.use(
  "/refresh",
  authRateLimit({ scope: "refresh", limit: 30, windowMs: fifteenMinutes }),
);

const RegisterSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().optional(),
});

authRoute.post("/register", async (c) => {
  const body = RegisterSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }
  const { email, password, name } = body.data;

  const existing = await db
    .select()
    .from(schema.users)
    .where(eq(schema.users.email, email.toLowerCase()))
    .limit(1);
  if (existing.length > 0) {
    return c.json({ error: "Email already registered" }, 409);
  }

  const passwordHash = await hashPassword(password);
  const [user] = await db
    .insert(schema.users)
    .values({ email: email.toLowerCase(), passwordHash })
    .returning();

  await db.insert(schema.profiles).values({
    userId: user.id,
    name: name?.trim() || "friend",
  });

  const accessToken = signAccessToken(user.id);
  const refreshToken = await issueRefreshToken(user.id);

  return c.json({ accessToken, refreshToken, userId: user.id }, 201);
});

const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string(),
});

authRoute.post("/login", async (c) => {
  const body = LoginSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input" }, 400);
  }
  const { email, password } = body.data;

  const rows = await db
    .select()
    .from(schema.users)
    .where(eq(schema.users.email, email.toLowerCase()))
    .limit(1);
  const user = rows[0];
  if (!user) {
    return c.json({ error: "Invalid email or password" }, 401);
  }

  const valid = await verifyPassword(password, user.passwordHash);
  if (!valid) {
    return c.json({ error: "Invalid email or password" }, 401);
  }

  const accessToken = signAccessToken(user.id);
  const refreshToken = await issueRefreshToken(user.id);

  return c.json({ accessToken, refreshToken, userId: user.id });
});

const RefreshSchema = z.object({
  refreshToken: z.string(),
});

authRoute.post("/refresh", async (c) => {
  const body = RefreshSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input" }, 400);
  }

  const result = await verifyRefreshToken(body.data.refreshToken);
  if (!result) {
    return c.json({ error: "Invalid or expired refresh token" }, 401);
  }

  await revokeRefreshToken(result.tokenId);
  const accessToken = signAccessToken(result.userId);
  const refreshToken = await issueRefreshToken(result.userId);

  return c.json({ accessToken, refreshToken });
});

authRoute.post("/logout", async (c) => {
  const body = RefreshSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input" }, 400);
  }
  const result = await verifyRefreshToken(body.data.refreshToken);
  if (result) {
    await revokeRefreshToken(result.tokenId);
  }
  return c.json({ ok: true });
});

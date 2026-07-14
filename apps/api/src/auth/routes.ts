import { Hono } from "hono";
import { z } from "zod";
import { and, eq, isNull } from "drizzle-orm";
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
import { authMiddleware } from "./middleware.js";
import { auditEvent } from "../lib/audit.js";

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

const DeviceSchema = z.object({
  deviceId: z.string().min(16).max(128),
  deviceName: z.string().min(1).max(120).optional(),
});

const RegisterSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().optional(),
}).and(DeviceSchema);

authRoute.post("/register", async (c) => {
  const body = RegisterSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input", details: body.error.flatten() }, 400);
  }
  const { email, password, name, deviceId, deviceName } = body.data;

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
  const refreshToken = await issueRefreshToken(user.id, { id: deviceId, name: deviceName });
  auditEvent("account_registered", user.id, { deviceId, deviceName: deviceName ?? null });

  return c.json({ accessToken, refreshToken, userId: user.id, onboardingComplete: false }, 201);
});

const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string(),
}).and(DeviceSchema);

authRoute.post("/login", async (c) => {
  const body = LoginSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input" }, 400);
  }
  const { email, password, deviceId, deviceName } = body.data;

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
  const refreshToken = await issueRefreshToken(user.id, { id: deviceId, name: deviceName });
  auditEvent("session_created", user.id, { deviceId, deviceName: deviceName ?? null });

  const [profile] = await db.select({ onboardingComplete: schema.profiles.onboardingComplete })
    .from(schema.profiles).where(eq(schema.profiles.userId, user.id)).limit(1);
  return c.json({ accessToken, refreshToken, userId: user.id, onboardingComplete: profile?.onboardingComplete ?? false });
});

const RefreshSchema = z.object({
  refreshToken: z.string(),
}).and(DeviceSchema.pick({ deviceId: true }));

authRoute.post("/refresh", async (c) => {
  const body = RefreshSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input" }, 400);
  }

  const result = await verifyRefreshToken(body.data.refreshToken, body.data.deviceId);
  if (!result) {
    return c.json({ error: "Invalid or expired refresh token" }, 401);
  }

  await revokeRefreshToken(result.tokenId);
  const accessToken = signAccessToken(result.userId);
  const refreshToken = await issueRefreshToken(result.userId, { id: body.data.deviceId });

  const [profile] = await db.select({ onboardingComplete: schema.profiles.onboardingComplete })
    .from(schema.profiles).where(eq(schema.profiles.userId, result.userId)).limit(1);
  return c.json({ accessToken, refreshToken, onboardingComplete: profile?.onboardingComplete ?? false });
});

authRoute.post("/logout", async (c) => {
  const body = RefreshSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: "Invalid input" }, 400);
  }
  const result = await verifyRefreshToken(body.data.refreshToken, body.data.deviceId);
  if (result) {
    await revokeRefreshToken(result.tokenId);
  }
  return c.json({ ok: true });
});

authRoute.get("/sessions", authMiddleware, async (c) => {
  const userId = c.get("userId");
  const rows = await db
    .select({
      id: schema.refreshTokens.id,
      deviceId: schema.refreshTokens.deviceId,
      deviceName: schema.refreshTokens.deviceName,
      createdAt: schema.refreshTokens.createdAt,
      lastUsedAt: schema.refreshTokens.lastUsedAt,
      expiresAt: schema.refreshTokens.expiresAt,
    })
    .from(schema.refreshTokens)
    .where(and(
      eq(schema.refreshTokens.userId, userId),
      isNull(schema.refreshTokens.revokedAt),
    ));
  return c.json({
    sessions: rows.filter((row) => row.expiresAt > new Date()).map((row) => ({
      ...row,
      active: true,
    })),
  });
});

authRoute.delete("/sessions/:id", authMiddleware, async (c) => {
  const userId = c.get("userId");
  const sessionId = z.string().uuid().safeParse(c.req.param("id"));
  if (!sessionId.success) return c.json({ error: "Invalid session id" }, 400);
  const [revoked] = await db
    .update(schema.refreshTokens)
    .set({ revokedAt: new Date() })
    .where(and(
      eq(schema.refreshTokens.id, sessionId.data),
      eq(schema.refreshTokens.userId, userId),
    ))
    .returning({ id: schema.refreshTokens.id, owner: schema.refreshTokens.userId });
  if (!revoked || revoked.owner !== userId) return c.json({ error: "Session not found" }, 404);
  auditEvent("session_revoked", userId, { sessionId: sessionId.data });
  return c.json({ ok: true });
});

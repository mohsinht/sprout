import type { Context, Next } from "hono";
import { getUserIdFromAuthHeader } from "./crypto.js";

type AuthVars = { Variables: { userId: string } };

export async function authMiddleware(c: Context<AuthVars>, next: Next) {
  const userId = getUserIdFromAuthHeader(c.req.header("Authorization"));
  if (!userId) {
    return c.json({ error: "Unauthorized" }, 401);
  }
  c.set("userId", userId);
  await next();
}

export async function optionalAuth(c: Context, next: Next) {
  const userId = getUserIdFromAuthHeader(c.req.header("Authorization"));
  if (userId) c.set("userId", userId);
  await next();
}
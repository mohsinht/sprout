import { createHash, randomBytes } from "node:crypto";
import argon2 from "argon2";
import jwt from "jsonwebtoken";
import { eq } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { config } from "../config.js";

export async function hashPassword(plain: string): Promise<string> {
  return argon2.hash(plain, { type: argon2.argon2id });
}

export async function verifyPassword(
  plain: string,
  hash: string
): Promise<boolean> {
  return argon2.verify(hash, plain);
}

export function signAccessToken(userId: string): string {
  return jwt.sign({ sub: userId }, config.jwtSecret, {
    expiresIn: config.jwtExpiresIn as unknown as number,
  });
}

function hashToken(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

export async function issueRefreshToken(
  userId: string,
  device: { id: string; name?: string },
): Promise<string> {
  const raw = randomBytes(48).toString("hex");
  const tokenHash = hashToken(`${device.id}:${raw}`);
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + config.refreshTokenExpiresInDays);

  await db.insert(schema.refreshTokens).values({
    userId,
    tokenHash,
    deviceId: device.id,
    deviceName: device.name,
    lastUsedAt: new Date(),
    expiresAt,
  });

  return raw;
}

export async function verifyRefreshToken(
  raw: string,
  deviceId: string,
): Promise<{ userId: string; tokenId: string } | null> {
  const tokenHash = hashToken(`${deviceId}:${raw}`);
  const rows = await db
    .select()
    .from(schema.refreshTokens)
    .where(eq(schema.refreshTokens.tokenHash, tokenHash))
    .limit(1);

  const row = rows[0];
  if (!row) return null;
  if (row.revokedAt) return null;
  if (row.expiresAt < new Date()) return null;
  if (row.deviceId && row.deviceId !== deviceId) return null;

  await db
    .update(schema.refreshTokens)
    .set({ lastUsedAt: new Date() })
    .where(eq(schema.refreshTokens.id, row.id));

  return { userId: row.userId, tokenId: row.id };
}

export async function revokeRefreshToken(tokenId: string): Promise<void> {
  await db
    .update(schema.refreshTokens)
    .set({ revokedAt: new Date() })
    .where(eq(schema.refreshTokens.id, tokenId));
}

export async function revokeAllUserTokens(userId: string): Promise<void> {
  await db
    .update(schema.refreshTokens)
    .set({ revokedAt: new Date() })
    .where(eq(schema.refreshTokens.userId, userId));
}

/** Extract and verify the Bearer access token from a request. Returns userId or null. */
export function getUserIdFromAuthHeader(
  authHeader: string | undefined
): string | null {
  if (!authHeader?.startsWith("Bearer ")) return null;
  const token = authHeader.slice(7);
  try {
    const payload = jwt.verify(token, config.jwtSecret) as { sub: string };
    return payload.sub ?? null;
  } catch {
    return null;
  }
}

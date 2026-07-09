import { createHash } from "node:crypto";

/** Build a dedupe fingerprint from transaction fields per capture_reliability.md. */
export function dedupeFingerprint(params: {
  amount: number;
  occurredAt: Date;
  merchant?: string;
  accountRef?: string;
}): string {
  // Normalize timestamp to a 1-day window
  const dayWindow = params.occurredAt.toISOString().slice(0, 10);
  const merchant = (params.merchant ?? "unknown").toLowerCase().trim();
  const accountRef = (params.accountRef ?? "unknown").toLowerCase().trim();
  const raw = `${params.amount}|${dayWindow}|${merchant}|${accountRef}`;
  return createHash("sha256").update(raw).digest("hex");
}
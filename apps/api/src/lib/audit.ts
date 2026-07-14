export function auditEvent(
  event: string,
  userId: string,
  metadata: Record<string, string | number | boolean | null> = {},
): void {
  console.info(
    JSON.stringify({
      kind: "audit",
      event,
      userId,
      occurredAt: new Date().toISOString(),
      ...metadata,
    }),
  );
}

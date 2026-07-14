import { and, eq } from "drizzle-orm";
import { db, schema } from "../db/client.js";
import { localDateAt, monthlyOccurrenceDate, occurrenceStatus } from "../lib/recurring.js";

export async function generateRecurringOccurrences(userId: string, instant = new Date()) {
  const [profile] = await db.select({ timezone: schema.profiles.timezone }).from(schema.profiles).where(eq(schema.profiles.userId, userId)).limit(1);
  const defaultZone = profile?.timezone ?? "Asia/Karachi";
  const series = await db.select().from(schema.recurringSeries).where(and(eq(schema.recurringSeries.userId, userId), eq(schema.recurringSeries.active, true)));
  for (const item of series.filter((row) => row.frequency === "monthly")) {
    const zone = item.timezone || defaultZone;
    const today = localDateAt(instant, zone);
    const [year, month] = today.split("-").map(Number);
    const due = monthlyOccurrenceDate(year, month, item.anchorDay!);
    await db.insert(schema.recurringOccurrences).values({
      seriesId: item.id, userId, localDate: due, status: occurrenceStatus(due, today, false),
    }).onConflictDoNothing();
    if (due < today) {
      await db.update(schema.recurringOccurrences).set({ status: "ask_pending", updatedAt: new Date() }).where(and(
        eq(schema.recurringOccurrences.seriesId, item.id), eq(schema.recurringOccurrences.localDate, due),
        eq(schema.recurringOccurrences.status, "upcoming"),
      ));
    }
  }
}

export async function materializeSalaryDayOccurrences(userId: string, occurredAt: Date) {
  const series = await db.select().from(schema.recurringSeries).where(and(
    eq(schema.recurringSeries.userId, userId), eq(schema.recurringSeries.active, true), eq(schema.recurringSeries.frequency, "on_salary_day"),
  ));
  for (const item of series) {
    const localDate = localDateAt(occurredAt, item.timezone);
    await db.insert(schema.recurringOccurrences).values({ seriesId: item.id, userId, localDate, status: "upcoming" })
      .onConflictDoNothing();
  }
}

export function localDateAt(instant: Date, timeZone: string): string {
  const parts = new Intl.DateTimeFormat("en-CA", { timeZone, year: "numeric", month: "2-digit", day: "2-digit" }).formatToParts(instant);
  const value = (type: string) => parts.find((part) => part.type === type)!.value;
  return `${value("year")}-${value("month")}-${value("day")}`;
}

export function monthlyOccurrenceDate(year: number, month: number, anchorDay: number): string {
  const lastDay = new Date(Date.UTC(year, month, 0)).getUTCDate();
  return `${year}-${String(month).padStart(2, "0")}-${String(Math.min(anchorDay, lastDay)).padStart(2, "0")}`;
}

export function occurrenceStatus(dueLocalDate: string, todayLocalDate: string, matched: boolean) {
  if (matched) return "confirmed" as const;
  return dueLocalDate < todayLocalDate ? "ask_pending" as const : "upcoming" as const;
}

export type ParsedMoneyEvent = {
  source: "email" | "sms" | "csv";
  label: string;
  amount: number;
  needsConfirmation: boolean;
};

export function parseMockMeezanSms(message: string): ParsedMoneyEvent | null {
  const amountMatch = message.match(/PKR\s?([\d,]+)/i);
  if (!amountMatch) return null;

  return {
    source: "sms",
    label: message.includes("IBFT") ? "IBFT transfer" : "Meezan alert",
    amount: Number(amountMatch[1].replaceAll(",", "")),
    needsConfirmation: true
  };
}

export function parseMockFinanceEmail(subject: string): ParsedMoneyEvent | null {
  if (!/(receipt|payment|statement|wise|meezan)/i.test(subject)) return null;

  return {
    source: "email",
    label: subject,
    amount: 0,
    needsConfirmation: true
  };
}

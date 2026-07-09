/**
 * Email source interface — the riskiest piece, deferred per build instructions.
 * Real implementation uses Gmail API with OAuth, narrowest scope, finance sender
 * allowlist, and discards raw email after parsing. For now: mock only.
 *
 * DO NOT build real Gmail OAuth until shipping to strangers (CASA assessment).
 * For personal/beta: unverified OAuth with test-user allowlist works and is free.
 */

export interface ParsedEmailEvent {
  date: string;
  amount: number;
  currency: string;
  merchant?: string;
  category?: string;
  provider: string;
  parserVersion: string;
  confidence: number; // 0-1
  needsReview: boolean;
}

export interface EmailSource {
  readonly name: string;
  /** Fetch recent finance-related messages. Returns empty array on failure. */
  fetchFinanceMessages(): Promise<ParsedEmailEvent[]>;
}

/** Mock email source — returns sample parsed events. Labelled as mock. */
export class MockEmailSource implements EmailSource {
  readonly name = "Mock Email (not real data)";

  async fetchFinanceMessages(): Promise<ParsedEmailEvent[]> {
    return [];
  }
}

export function createEmailSource(): EmailSource {
  return new MockEmailSource();
}
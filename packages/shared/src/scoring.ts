export const SCORE_FACTOR_WEIGHTS = {
  goalPace: 25,
  cashBuffer: 20,
  contributionConsistency: 15,
  diversification: 10,
  trendStability: 10,
  billCoverage: 10,
  debtCommitments: 5,
  dataConfidence: 5,
} as const;

export type ScoreFactorId = keyof typeof SCORE_FACTOR_WEIGHTS;
export type ScoreBand = "strong" | "healthy" | "watch" | "urgent";
export type MascotMood = "thriving" | "content" | "watchful" | "concerned";
export type FactorPresence = { available: true; value: number } | { available: false; reason: string };
export type FactorPresenceInputs = Record<ScoreFactorId, FactorPresence>;

export type FactorScore = {
  id: ScoreFactorId;
  available: boolean;
  reason?: string;
  normalized?: number;
  originalWeight: number;
  redistributedWeight?: number;
  points?: number;
};

export type PresenceScoreResult =
  | { scoreState: "insufficient_data"; score: null; availableCount: number; explanation: string; factors: FactorScore[]; band: null; mascotMood: "content" }
  | { scoreState: "available"; score: number; availableCount: number; explanation: string; factors: FactorScore[]; band: ScoreBand; mascotMood: MascotMood };

const clamp = (value: number, min = 0, max = 1) => Math.min(max, Math.max(min, value));

export function calculatePresenceScore(inputs: FactorPresenceInputs): PresenceScoreResult {
  const available = (Object.keys(SCORE_FACTOR_WEIGHTS) as ScoreFactorId[]).filter((id) => inputs[id].available);
  const availableWeight = available.reduce((sum, id) => sum + SCORE_FACTOR_WEIGHTS[id], 0);
  const factors: FactorScore[] = (Object.keys(SCORE_FACTOR_WEIGHTS) as ScoreFactorId[]).map((id) => {
    const input = inputs[id];
    if (!input.available) return { id, available: false, reason: input.reason, originalWeight: SCORE_FACTOR_WEIGHTS[id] };
    const redistributedWeight = SCORE_FACTOR_WEIGHTS[id] * 100 / availableWeight;
    const normalized = clamp(input.value);
    return { id, available: true, normalized, originalWeight: SCORE_FACTOR_WEIGHTS[id], redistributedWeight, points: normalized * redistributedWeight };
  });
  const missing = factors.filter((factor) => !factor.available);
  if (available.length < 3) {
    return {
      scoreState: "insufficient_data", score: null, availableCount: available.length,
      explanation: `Sprout is still getting to know your money. ${available.length} of 8 factors are available.`,
      factors, band: null, mascotMood: "content",
    };
  }
  const score = Math.round(factors.reduce((sum, factor) => sum + (factor.points ?? 0), 0));
  const band: ScoreBand = score >= 85 ? "strong" : score >= 70 ? "healthy" : score >= 50 ? "watch" : "urgent";
  const mascotMood: MascotMood = band === "strong" ? "thriving" : band === "healthy" ? "content" : band === "watch" ? "watchful" : "concerned";
  const missingText = missing.length ? ` Missing: ${missing.map((factor) => `${factor.id} (${factor.reason})`).join(", ")}.` : "";
  return { scoreState: "available", score, availableCount: available.length, explanation: `Score based on ${available.length} of 8 factors.${missingText}`, factors, band, mascotMood };
}

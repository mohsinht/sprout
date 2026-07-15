import OpenAI from "openai";
import { z } from "zod";
import { config } from "../config.js";

const AiBriefingOutputSchema = z.object({
  greeting: z.string().min(1).max(120),
  summary: z.string().min(1).max(320),
  interpretation: z.array(z.string().min(1).max(240)).min(2).max(3),
});

const bannedAiCopy =
  /you failed|bad spending|you should have|guaranteed|buy now|you will earn|connect your bank to continue|transfer now|pay this bill in sprout|top up .* here/i;

export function validateAiBriefingOutput(value: unknown): AiBriefingOutput {
  const output = AiBriefingOutputSchema.parse(value);
  if (
    bannedAiCopy.test(
      [output.greeting, output.summary, ...output.interpretation].join(" "),
    )
  ) {
    throw new Error("AI copy failed Sprout guardrails");
  }
  return output;
}

export interface AiBriefingInput {
  greeting: string;
  summary: string;
  wealthSnapshot: {
    totalPkr: number;
    changeVsYesterday: number;
    changeMtd: number;
    mainReason: string;
    interpretation: string[];
    provenanceSummary: string;
  };
  wealthEvents: {
    id: string;
    plainWhy: string;
    magnitudePkr: number;
    direction: string;
    severity: string;
  }[];
  recommendedAction: {
    id: string;
    label: string;
    severity: string;
    effect: string;
    goalRelativeNote?: string;
  };
  mascotMood: string;
  score: number | null;
  band: string | null;
}

export interface AiBriefingOutput {
  greeting: string;
  summary: string;
  interpretation: string[];
}

export interface AiService {
  readonly name: string;
  generateBriefingCopy(
    input: AiBriefingInput,
  ): Promise<{ output: AiBriefingOutput; costCents: number }>;
}

/** Mock AI — returns the deterministic copy. Zero cost. */
export class MockAiService implements AiService {
  readonly name = "mock-ai";

  async generateBriefingCopy(
    input: AiBriefingInput,
  ): Promise<{ output: AiBriefingOutput; costCents: number }> {
    return {
      output: {
        greeting: input.greeting,
        summary: input.summary,
        interpretation: input.wealthSnapshot.interpretation,
      },
      costCents: 0,
    };
  }
}

/** OpenAI service — writes only copy; code owns every financial decision. */
export class OpenAiService implements AiService {
  readonly name = config.openaiModel;
  private client: OpenAI | null = null;

  private getClient(): OpenAI {
    if (!this.client) {
      if (!config.openaiApiKey) throw new Error("OPENAI_API_KEY not set");
      this.client = new OpenAI({ apiKey: config.openaiApiKey });
    }
    return this.client;
  }

  async generateBriefingCopy(
    input: AiBriefingInput,
  ): Promise<{ output: AiBriefingOutput; costCents: number }> {
    try {
      const client = this.getClient();

      const systemPrompt = `You are Sprout's calm financial copy editor for Pakistani earners.

Use only the supplied facts. Never recalculate money, scores, dates, sources,
severity, or actions. Never invent a fact, prediction, source, or certainty.

Write concise, plain English for one daily wealth briefing. Be warm and calm:
celebrate gently, describe losses without alarm, and never use shame, urgency,
FOMO, guaranteed outcomes, buy/sell instructions, or payment instructions.

If data is stale or unavailable, state that uncertainty plainly. The user can
always use manual entry; never imply a connection is required.

Return JSON only with greeting, summary, and interpretation. Do not include
mascot mood, health score, action choice, or any field not requested.`;

      const userPrompt = `Given this pre-computed wealth data, write the briefing copy.
The numbers are FINAL — do not recompute, invent, or change any number.

Data:
${JSON.stringify(input, null, 2)}

Return JSON with exactly these fields:
{
  "greeting": string,
  "summary": string,
  "interpretation": string[]
}`;

      const response = await client.responses.create({
        model: config.openaiModel,
        reasoning: {
          effort: config.openaiReasoningEffort as "low" | "medium" | "high",
        },
        store: false,
        input: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ],
        text: {
          format: {
            type: "json_schema",
            name: "sprout_briefing_copy",
            strict: true,
            schema: {
              type: "object",
              additionalProperties: false,
              properties: {
                greeting: { type: "string" },
                summary: { type: "string" },
                interpretation: {
                  type: "array",
                  items: { type: "string" },
                  minItems: 2,
                  maxItems: 3,
                },
              },
              required: ["greeting", "summary", "interpretation"],
            },
          },
        },
      });

      const content = response.output_text || "{}";
      const parsed = AiBriefingOutputSchema.parse(JSON.parse(content));

      // Estimate cost (gpt-4o-mini: ~$0.15/1M input, ~$0.60/1M output)
      const inputTokens = response.usage?.input_tokens ?? 0;
      const outputTokens = response.usage?.output_tokens ?? 0;
      const costCents = Math.ceil(
        (inputTokens * 0.00000015 + outputTokens * 0.0000006) * 100,
      );

      return { output: parsed, costCents };
    } catch (error) {
      // The budget/rewrite policy owns deterministic fallback and telemetry.
      // Re-throw so a provider or schema failure cannot be reported as an
      // actual AI rewrite to the UI.
      throw error;
    }
  }
}

/** Factory: returns OpenAI if API key is set, else mock. */
export function createAiService(): AiService {
  if (config.openaiApiKey) {
    return new OpenAiService();
  }
  return new MockAiService();
}

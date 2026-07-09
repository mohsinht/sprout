import OpenAI from "openai";
import { config } from "../config.js";

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
  score: number;
  band: string;
}

export interface AiBriefingOutput {
  greeting: string;
  summary: string;
  interpretation: string[];
  mascotMood: string;
}

export interface AiService {
  readonly name: string;
  generateBriefingCopy(input: AiBriefingInput): Promise<{ output: AiBriefingOutput; costCents: number }>;
}

/** Mock AI — returns the deterministic copy. Zero cost. */
export class MockAiService implements AiService {
  readonly name = "mock-ai";

  async generateBriefingCopy(input: AiBriefingInput): Promise<{ output: AiBriefingOutput; costCents: number }> {
    return {
      output: {
        greeting: input.greeting,
        summary: input.summary,
        interpretation: input.wealthSnapshot.interpretation,
        mascotMood: input.mascotMood,
      },
      costCents: 0,
    };
  }
}

/** OpenAI service — uses a cheap model (gpt-4o-mini) for light copywriting. */
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

  async generateBriefingCopy(input: AiBriefingInput): Promise<{ output: AiBriefingOutput; costCents: number }> {
    try {
      const client = this.getClient();

      const systemPrompt = `You are Sprout, a calm, practical financial companion for Pakistani earners.
Write warm, short, honest copy. Rules:
- No shame, guilt, panic, or FOMO.
- No guaranteed returns or investment advice.
- State today's change and MTD change together.
- Every movement has a "why."
- End on calm. Never hype a gain or alarm a dip.
- Use PKR naturally.
- Keep sentences short.
- Return ONLY valid JSON matching the requested shape.`;

      const userPrompt = `Given this pre-computed wealth data, write the briefing copy.
The numbers are FINAL — do not recompute, invent, or change any number.

Data:
${JSON.stringify(input, null, 2)}

Return JSON with exactly these fields:
{
  "greeting": string,
  "summary": string (movement + reason + reassurance, today and MTD together),
  "interpretation": string[] (2-3 lines in Sprout's voice),
  "mascotMood": "thriving" | "content" | "watchful" | "concerned"
}`;

      const response = await client.chat.completions.create({
        model: config.openaiModel,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ],
        max_tokens: 500,
        temperature: 0.7,
        response_format: { type: "json_object" },
      });

      const content = response.choices[0]?.message?.content ?? "{}";
      const parsed = JSON.parse(content) as AiBriefingOutput;

      // Estimate cost (gpt-4o-mini: ~$0.15/1M input, ~$0.60/1M output)
      const inputTokens = response.usage?.prompt_tokens ?? 0;
      const outputTokens = response.usage?.completion_tokens ?? 0;
      const costCents = Math.ceil(
        (inputTokens * 0.00000015 + outputTokens * 0.0000006) * 100
      );

      return { output: parsed, costCents };
    } catch (error) {
      // On any AI failure, fall back to deterministic copy
      return {
        output: {
          greeting: input.greeting,
          summary: input.summary,
          interpretation: input.wealthSnapshot.interpretation,
          mascotMood: input.mascotMood,
        },
        costCents: 0,
      };
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
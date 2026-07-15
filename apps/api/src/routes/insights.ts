import { Hono } from "hono";
import { authMiddleware } from "../auth/middleware.js";
import { generatePersonalInsights } from "../insights/insight-service.js";

export const insightsRoute = new Hono<{ Variables: { userId: string } }>();
insightsRoute.use("*", authMiddleware);

async function insightPayload(userId: string) {
  const insights = await generatePersonalInsights(userId);
  return {
    state: insights.length === 0 ? "quiet" : "populated",
    insights,
  };
}

insightsRoute.get("/", async (c) => {
  return c.json(await insightPayload(c.get("userId")));
});

insightsRoute.post("/refresh", async (c) => {
  const insights = await generatePersonalInsights(c.get("userId"));
  return c.json({
    state: insights.length === 0 ? "quiet" : "populated",
    insights,
    message:
      insights.length === 0
        ? "Insights checked. Nothing new needs your attention."
        : "Insights refreshed from your latest dated sources.",
    refresh: {
      status: "refreshed",
      copyMode: insights.some(
        (insight) => insight.presentationMode === "ai_rewrite",
      )
        ? "ai_rewrite"
        : "deterministic",
      aiUsed: false,
    },
  });
});

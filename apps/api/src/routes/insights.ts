import { Hono } from "hono";
import { authMiddleware } from "../auth/middleware.js";
import { generatePersonalInsights } from "../insights/insight-service.js";

export const insightsRoute = new Hono<{ Variables: { userId: string } }>();
insightsRoute.use("*", authMiddleware);
insightsRoute.get("/", async (c) => {
  const insights = await generatePersonalInsights(c.get("userId"));
  return c.json({
    state: insights.length === 0 ? "quiet" : "populated",
    insights,
  });
});

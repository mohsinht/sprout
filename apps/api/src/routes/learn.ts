import { Hono } from "hono";
import { LearnResponseSchema, mockLearnResponse } from "@sprout/shared";

export const learnRoute = new Hono();

learnRoute.get("/", (c) => {
  const response = LearnResponseSchema.parse(mockLearnResponse);
  return c.json(response);
});

import { Hono } from "hono";
import { GrowResponseSchema, mockGrowResponse } from "@sprout/shared";

export const growRoute = new Hono();

growRoute.get("/", (c) => {
  const response = GrowResponseSchema.parse(mockGrowResponse);
  return c.json(response);
});

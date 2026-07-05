import { Hono } from "hono";
import { mockProfileResponse, ProfileResponseSchema } from "@sprout/shared";

export const profileRoute = new Hono();

profileRoute.get("/", (c) => {
  const response = ProfileResponseSchema.parse(mockProfileResponse);

  return c.json(response);
});

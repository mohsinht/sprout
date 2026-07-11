import { loadEnvFile } from "node:process";
import { defineConfig } from "drizzle-kit";

try {
  loadEnvFile(".env");
} catch {
  // CI and production inject DATABASE_URL directly.
}

export default defineConfig({
  schema: "./src/db/schema.ts",
  outDir: "./drizzle",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL ?? "postgresql://sprout:sprout@localhost:5432/sprout",
  },
});

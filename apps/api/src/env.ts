import { loadEnvFile } from "node:process";

// Node 20+ provides this without adding another dotenv dependency. Production
// environments should inject secrets directly; local development may use the
// repo-local .env file.
for (const url of [
  new URL("../../../.env", import.meta.url),
  new URL("../.env", import.meta.url),
]) {
  try {
    loadEnvFile(url);
  } catch {
    // Missing env files are expected in containers and CI.
  }
}

import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";
import "../env.js";
import * as schema from "./schema.js";

const connectionString =
  process.env.DATABASE_URL ??
  "postgresql://sprout:sprout@localhost:5432/sprout";

export const pool = new Pool({ connectionString, max: 5 });

export const db = drizzle(pool, { schema });
export { schema };
export type Db = typeof db;

export async function closeDb(): Promise<void> {
  await pool.end();
}

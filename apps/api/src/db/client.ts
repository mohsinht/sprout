import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";
import * as schema from "./schema.js";

const connectionString =
  process.env.DATABASE_URL ??
  "postgresql://sprout:sprout@localhost:5432/sprout";

const pool = new Pool({ connectionString, max: 5 });

export const db = drizzle(pool, { schema });
export { schema };
export type Db = typeof db;
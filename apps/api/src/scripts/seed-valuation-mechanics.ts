import { pool } from "../db/client.js";
import { generateBriefing, storeBriefing } from "../services/briefing-pipeline.js";
import { MockAiService } from "../services/ai-service.js";

const userId = "00000000-0000-4000-8000-0000000000d6";
await pool.query(`insert into users(id,email,password_hash) values($1,'valuation-mechanics@audit.invalid','disabled') on conflict(id) do nothing`, [userId]);
await pool.query(`insert into profiles(user_id,name,onboarding_complete) values($1,'Valuation mechanics',true) on conflict do nothing`, [userId]);
await pool.query(`insert into holdings(user_id,kind,institution,label,fund_code,currency,units,value_pkr,freshness)
  select $1,'mutual_fund','Audit Al Meezan','Audit Fund','AMMF','PKR',100,0,'unavailable'
  where not exists(select 1 from holdings where user_id=$1 and fund_code='AMMF')`, [userId]);
await pool.query(`insert into holdings(user_id,kind,institution,label,currency,value_native,value_pkr,freshness)
  select $1,'cash','Audit Wise','Audit USD','USD',100,0,'unavailable'
  where not exists(select 1 from holdings where user_id=$1 and label='Audit USD')`, [userId]);

const today = new Date();
for (let offset = 2; offset >= 0; offset--) {
  const date = new Date(today.getTime() - offset * 86400000).toISOString().slice(0, 10);
  const navSource = { name: "Audit Al Meezan", async fetchNav() { return { value: 54.2 + offset / 100, asOf: date, source: "Audit Al Meezan", currency: "PKR" }; } };
  const validationNavSource = { name: "Audit MUFAP", async fetchNav() { return { value: (54.2 + offset / 100) * 1.002, asOf: date, source: "Audit MUFAP", currency: "PKR" }; } };
  const fxSource = { name: "Audit FX", async fetchRate(pair: string) { return { pair, value: 278 + offset, asOf: date, source: "Audit FX" }; } };
  const result = await generateBriefing({ userId, date, aiService: new MockAiService(), navSource, validationNavSource, fxSource });
  await storeBriefing(result.briefing, 0, "audit-deterministic");
  await pool.query(`insert into job_runs(user_id,type,status,started_at,finished_at,idempotency_key)
    values($1,'daily','succeeded',$2,$2,$3) on conflict(idempotency_key) do update set status='succeeded',finished_at=$2`,
    [userId, `${date}T12:00:00Z`, `daily:${userId}:${date}`]);
}
await pool.end();
console.log("audit_d6_three_day_pipeline_seed: 3 simulated days completed");

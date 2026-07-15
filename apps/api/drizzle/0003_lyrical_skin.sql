CREATE TYPE "public"."goal_contribution_source" AS ENUM('opening_balance', 'manual', 'quick_add', 'occurrence_yes');--> statement-breakpoint
CREATE TABLE "goal_contributions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"goal_id" uuid NOT NULL,
	"amount_pkr" integer NOT NULL,
	"contribution_date" date NOT NULL,
	"source" "goal_contribution_source" NOT NULL,
	"idempotency_key" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "goal_contributions" ADD CONSTRAINT "goal_contributions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "goal_contributions" ADD CONSTRAINT "goal_contributions_goal_id_goals_id_fk" FOREIGN KEY ("goal_id") REFERENCES "public"."goals"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "goal_contributions_user_date_idx" ON "goal_contributions" USING btree ("user_id","contribution_date");--> statement-breakpoint
CREATE UNIQUE INDEX "goal_contributions_user_idempotency_idx" ON "goal_contributions" USING btree ("user_id","idempotency_key");--> statement-breakpoint
CREATE UNIQUE INDEX "goal_contributions_one_opening_balance_idx" ON "goal_contributions" USING btree ("goal_id") WHERE "source" = 'opening_balance';--> statement-breakpoint
ALTER TABLE "goal_contributions" ADD CONSTRAINT "goal_contributions_positive_amount" CHECK ("amount_pkr" > 0);--> statement-breakpoint
INSERT INTO "goal_contributions" ("user_id", "goal_id", "amount_pkr", "contribution_date", "source", "idempotency_key")
SELECT "user_id", "id", "current_amount", "created_at"::date, 'opening_balance', 'opening-balance:' || "id"::text
FROM "goals"
WHERE "current_amount" > 0;

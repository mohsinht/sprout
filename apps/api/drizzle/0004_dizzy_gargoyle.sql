CREATE TYPE "public"."insight_presentation_mode" AS ENUM('deterministic', 'ai_rewrite');--> statement-breakpoint
CREATE TYPE "public"."insight_severity" AS ENUM('all_good', 'heads_up', 'worth_doing', 'needs_attention');--> statement-breakpoint
CREATE TYPE "public"."world_fact_kind" AS ENUM('policy_rate', 'cpi', 'fx_move', 'nav_move', 'goal_cost_context');--> statement-breakpoint
CREATE TABLE "personal_insights" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"world_fact_id" uuid,
	"wealth_event_id" uuid,
	"matched_holding_id" uuid,
	"matched_goal_id" uuid,
	"matched_currency" varchar(3),
	"headline" text NOT NULL,
	"personal_meaning" text NOT NULL,
	"detail" text NOT NULL,
	"deterministic_headline" text NOT NULL,
	"deterministic_personal_meaning" text NOT NULL,
	"deterministic_detail" text NOT NULL,
	"severity" "insight_severity" NOT NULL,
	"source_label" text NOT NULL,
	"source_url" text,
	"as_of" date NOT NULL,
	"freshness" text NOT NULL,
	"template_id" text NOT NULL,
	"template_version" text NOT NULL,
	"presentation_mode" "insight_presentation_mode" DEFAULT 'deterministic' NOT NULL,
	"rewrite_input_hash" text,
	"generated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "world_facts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"stable_key" text NOT NULL,
	"kind" "world_fact_kind" NOT NULL,
	"observed_on" date NOT NULL,
	"valid_from" date,
	"magnitude" numeric(20, 8),
	"unit" text,
	"direction" text NOT NULL,
	"source_id" text NOT NULL,
	"source_label" text NOT NULL,
	"source_url" text,
	"source_published_at" timestamp with time zone,
	"freshness" text NOT NULL,
	"plain_summary" text NOT NULL,
	"affects_asset_classes_json" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"affects_currencies_json" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"affects_goal_types_json" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"normalizer" text DEFAULT 'deterministic' NOT NULL,
	"normalizer_version" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "world_facts_stable_key_unique" UNIQUE("stable_key")
);
--> statement-breakpoint
ALTER TABLE "personal_insights" ADD CONSTRAINT "personal_insights_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "personal_insights" ADD CONSTRAINT "personal_insights_world_fact_id_world_facts_id_fk" FOREIGN KEY ("world_fact_id") REFERENCES "public"."world_facts"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "personal_insights" ADD CONSTRAINT "personal_insights_wealth_event_id_wealth_events_id_fk" FOREIGN KEY ("wealth_event_id") REFERENCES "public"."wealth_events"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "personal_insights" ADD CONSTRAINT "personal_insights_matched_holding_id_holdings_id_fk" FOREIGN KEY ("matched_holding_id") REFERENCES "public"."holdings"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "personal_insights" ADD CONSTRAINT "personal_insights_matched_goal_id_goals_id_fk" FOREIGN KEY ("matched_goal_id") REFERENCES "public"."goals"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "personal_insights_user_fact_template_idx" ON "personal_insights" USING btree ("user_id","world_fact_id","wealth_event_id","template_version");--> statement-breakpoint
CREATE INDEX "personal_insights_user_as_of_idx" ON "personal_insights" USING btree ("user_id","as_of");--> statement-breakpoint
CREATE INDEX "world_facts_observed_kind_idx" ON "world_facts" USING btree ("observed_on","kind");--> statement-breakpoint
ALTER TABLE "personal_insights" ADD CONSTRAINT "personal_insights_exactly_one_origin" CHECK (num_nonnulls("world_fact_id", "wealth_event_id") = 1);

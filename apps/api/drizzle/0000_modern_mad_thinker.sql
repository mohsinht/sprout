CREATE TYPE "public"."account_type" AS ENUM('cash', 'bank', 'wallet', 'wise', 'investment', 'foreign_balance', 'other');--> statement-breakpoint
CREATE TYPE "public"."baseline_source_kind" AS ENUM('al_meezan_statement', 'wise_screenshot', 'manual');--> statement-breakpoint
CREATE TYPE "public"."briefing_freshness" AS ENUM('fresh', 'stale', 'local_fallback', 'unavailable');--> statement-breakpoint
CREATE TYPE "public"."data_source_kind" AS ENUM('email', 'fx', 'nav', 'wise', 'statement', 'sms');--> statement-breakpoint
CREATE TYPE "public"."data_source_status" AS ENUM('connected', 'needs_review', 'not_connected', 'error');--> statement-breakpoint
CREATE TYPE "public"."goal_status" AS ENUM('active', 'complete', 'paused');--> statement-breakpoint
CREATE TYPE "public"."goal_type" AS ENUM('emergency', 'car', 'home', 'education', 'eidi', 'zakat', 'travel', 'custom');--> statement-breakpoint
CREATE TYPE "public"."holding_freshness" AS ENUM('fresh', 'stale', 'manual', 'unavailable', 'estimated');--> statement-breakpoint
CREATE TYPE "public"."holding_kind" AS ENUM('mutual_fund', 'cash', 'equity', 'other');--> statement-breakpoint
CREATE TYPE "public"."income_type" AS ENUM('salaried', 'freelance', 'business', 'student', 'other');--> statement-breakpoint
CREATE TYPE "public"."job_status" AS ENUM('running', 'succeeded', 'failed');--> statement-breakpoint
CREATE TYPE "public"."job_type" AS ENUM('daily', 'on_demand');--> statement-breakpoint
CREATE TYPE "public"."mascot_mood" AS ENUM('thriving', 'content', 'watchful', 'concerned');--> statement-breakpoint
CREATE TYPE "public"."pending_status" AS ENUM('pending', 'unitized');--> statement-breakpoint
CREATE TYPE "public"."projected_income_source" AS ENUM('user_told_me', 'inferred');--> statement-breakpoint
CREATE TYPE "public"."transaction_source" AS ENUM('manual', 'sms', 'email', 'statement', 'wise', 'al_meezan');--> statement-breakpoint
CREATE TYPE "public"."transaction_type" AS ENUM('expense', 'income', 'transfer');--> statement-breakpoint
CREATE TYPE "public"."valuation_kind" AS ENUM('confirmed', 'estimated');--> statement-breakpoint
CREATE TABLE "accounts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"provider" text DEFAULT 'Manual' NOT NULL,
	"label" text NOT NULL,
	"masked_ref" text,
	"type" "account_type" DEFAULT 'cash' NOT NULL,
	"opening_balance" integer DEFAULT 0 NOT NULL,
	"currency" varchar(3) DEFAULT 'PKR' NOT NULL,
	"is_manual" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "baselines" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"source_kind" "baseline_source_kind" NOT NULL,
	"captured_as_of" date NOT NULL,
	"printed_on" date,
	"confirmed_value_pkr" integer NOT NULL,
	"raw_extract_json" jsonb,
	"uploaded_file_id" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "daily_briefings" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"briefing_date" date NOT NULL,
	"generated_at" timestamp with time zone NOT NULL,
	"freshness" "briefing_freshness" DEFAULT 'fresh' NOT NULL,
	"mascot_mood" "mascot_mood" DEFAULT 'content' NOT NULL,
	"greeting" text NOT NULL,
	"summary" text NOT NULL,
	"health_score" integer NOT NULL,
	"health_status" varchar(20) NOT NULL,
	"wealth_snapshot_json" jsonb NOT NULL,
	"wealth_events_json" jsonb NOT NULL,
	"learn_threads_json" jsonb,
	"recommended_action_json" jsonb NOT NULL,
	"goals_json" jsonb NOT NULL,
	"holdings_json" jsonb NOT NULL,
	"streak" integer DEFAULT 0 NOT NULL,
	"xp" integer DEFAULT 0 NOT NULL,
	"level" integer DEFAULT 1 NOT NULL,
	"ai_model" text,
	"ai_cost_cents" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "data_sources" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"kind" "data_source_kind" NOT NULL,
	"status" "data_source_status" DEFAULT 'not_connected' NOT NULL,
	"last_synced_at" timestamp with time zone,
	"encrypted_credentials" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "fx_rates" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"pair" varchar(20) NOT NULL,
	"rate" numeric(20, 6) NOT NULL,
	"as_of" date NOT NULL,
	"source" text NOT NULL,
	"source_url" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "goals" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"name" text NOT NULL,
	"type" "goal_type" NOT NULL,
	"target_amount" integer NOT NULL,
	"current_amount" integer DEFAULT 0 NOT NULL,
	"deadline" date,
	"status" "goal_status" DEFAULT 'active' NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"is_primary" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "holdings" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"kind" "holding_kind" NOT NULL,
	"institution" text NOT NULL,
	"label" text NOT NULL,
	"fund_code" varchar(50),
	"currency" varchar(3) DEFAULT 'PKR' NOT NULL,
	"units" numeric(20, 4),
	"units_confirmed_as_of" date,
	"value_native" numeric(20, 2),
	"value_pkr" integer DEFAULT 0 NOT NULL,
	"price_as_of" date,
	"price_source" text,
	"freshness" "holding_freshness" DEFAULT 'manual' NOT NULL,
	"valuation_kind" "valuation_kind" DEFAULT 'confirmed' NOT NULL,
	"baseline_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "job_runs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"type" "job_type" NOT NULL,
	"status" "job_status" DEFAULT 'running' NOT NULL,
	"started_at" timestamp with time zone NOT NULL,
	"finished_at" timestamp with time zone,
	"error" text,
	"idempotency_key" varchar(255) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "pending_investments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"amount_pkr" integer NOT NULL,
	"destination" text NOT NULL,
	"initiated_on" date NOT NULL,
	"status" "pending_status" DEFAULT 'pending' NOT NULL,
	"resolved_by_baseline_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "price_quotes" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"instrument" varchar(100) NOT NULL,
	"value" numeric(20, 8) NOT NULL,
	"as_of" date NOT NULL,
	"source" text NOT NULL,
	"source_url" text,
	"currency" varchar(3) DEFAULT 'PKR' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "profiles" (
	"user_id" uuid NOT NULL,
	"name" text DEFAULT 'friend' NOT NULL,
	"income_type" "income_type",
	"salary_date" integer,
	"locale" varchar(10) DEFAULT 'en' NOT NULL,
	"reduce_motion" boolean DEFAULT false NOT NULL,
	"hide_balances" boolean DEFAULT false NOT NULL,
	"sound_effects" boolean DEFAULT true NOT NULL,
	"haptics" boolean DEFAULT true NOT NULL,
	"display_currency" varchar(3) DEFAULT 'PKR' NOT NULL,
	"notification_preferences_json" jsonb DEFAULT '{"dailyCheckIn":true,"billReminders":true,"salaryIncomeReminders":true,"weeklySummary":true,"streakProtection":true,"hideSensitiveAmounts":true}'::jsonb NOT NULL,
	"onboarding_complete" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "projected_income" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"amount" numeric(20, 2) NOT NULL,
	"currency" varchar(3) DEFAULT 'USD' NOT NULL,
	"expected_on" date NOT NULL,
	"converted_pkr_estimate" integer,
	"source" "projected_income_source" DEFAULT 'user_told_me' NOT NULL,
	"note" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "refresh_tokens" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"token_hash" text NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"revoked_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "refresh_tokens_token_hash_unique" UNIQUE("token_hash")
);
--> statement-breakpoint
CREATE TABLE "transactions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"account_id" uuid,
	"amount" integer NOT NULL,
	"currency" varchar(3) DEFAULT 'PKR' NOT NULL,
	"type" "transaction_type" NOT NULL,
	"category" text NOT NULL,
	"merchant" text,
	"note" text,
	"occurred_at" timestamp with time zone NOT NULL,
	"source" "transaction_source" DEFAULT 'manual' NOT NULL,
	"provider" text,
	"parser_version" text,
	"dedupe_fingerprint" text NOT NULL,
	"confidence" numeric(3, 2) DEFAULT '1.00' NOT NULL,
	"needs_review" boolean DEFAULT false NOT NULL,
	"review_reason" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"email" varchar(255) NOT NULL,
	"password_hash" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "wealth_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"date" date NOT NULL,
	"holding_id" uuid,
	"kind" varchar(50) NOT NULL,
	"magnitude_pkr" integer DEFAULT 0 NOT NULL,
	"direction" varchar(10) NOT NULL,
	"plain_why" text NOT NULL,
	"learn_more_id" text,
	"severity" varchar(20) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "wealth_snapshots" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"date" date NOT NULL,
	"total_pkr" integer NOT NULL,
	"per_holding_json" jsonb NOT NULL,
	"change_vs_yesterday" integer DEFAULT 0 NOT NULL,
	"change_mtd" integer DEFAULT 0 NOT NULL,
	"main_reason" text,
	"interpretation_json" jsonb,
	"freshness" "holding_freshness" DEFAULT 'fresh' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "accounts" ADD CONSTRAINT "accounts_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "baselines" ADD CONSTRAINT "baselines_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "daily_briefings" ADD CONSTRAINT "daily_briefings_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "data_sources" ADD CONSTRAINT "data_sources_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "goals" ADD CONSTRAINT "goals_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "holdings" ADD CONSTRAINT "holdings_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "job_runs" ADD CONSTRAINT "job_runs_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pending_investments" ADD CONSTRAINT "pending_investments_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "profiles" ADD CONSTRAINT "profiles_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "projected_income" ADD CONSTRAINT "projected_income_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_account_id_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "wealth_events" ADD CONSTRAINT "wealth_events_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "wealth_snapshots" ADD CONSTRAINT "wealth_snapshots_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "fx_rates_source_pair_date_idx" ON "fx_rates" USING btree ("pair","as_of","source");--> statement-breakpoint
CREATE UNIQUE INDEX "job_runs_idempotency_idx" ON "job_runs" USING btree ("idempotency_key");--> statement-breakpoint
CREATE UNIQUE INDEX "price_quotes_source_instrument_date_idx" ON "price_quotes" USING btree ("instrument","as_of","source");--> statement-breakpoint
CREATE INDEX "refresh_tokens_user_idx" ON "refresh_tokens" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "transactions_user_fingerprint_idx" ON "transactions" USING btree ("user_id","dedupe_fingerprint");--> statement-breakpoint
CREATE UNIQUE INDEX "wealth_snapshots_user_date_idx" ON "wealth_snapshots" USING btree ("user_id","date");
CREATE TYPE "public"."occurrence_status" AS ENUM('upcoming', 'ask_pending', 'confirmed', 'skipped', 'stopped');--> statement-breakpoint
CREATE TYPE "public"."recurring_frequency" AS ENUM('monthly', 'on_salary_day');--> statement-breakpoint
CREATE TYPE "public"."recurring_kind" AS ENUM('liability', 'expected_income');--> statement-breakpoint
CREATE TABLE "nav_cross_validations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"instrument" varchar(100) NOT NULL,
	"as_of" date NOT NULL,
	"primary_source" text NOT NULL,
	"validation_source" text NOT NULL,
	"primary_value" numeric(20, 8) NOT NULL,
	"validation_value" numeric(20, 8) NOT NULL,
	"difference_ratio" numeric(12, 8) NOT NULL,
	"matched" boolean NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "recurring_occurrences" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"series_id" uuid NOT NULL,
	"user_id" uuid NOT NULL,
	"local_date" date NOT NULL,
	"status" "occurrence_status" DEFAULT 'upcoming' NOT NULL,
	"ask_emitted_at" timestamp with time zone,
	"confirmed_transaction_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "recurring_series" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"kind" "recurring_kind" NOT NULL,
	"frequency" "recurring_frequency" NOT NULL,
	"amount" integer NOT NULL,
	"label" text NOT NULL,
	"timezone" varchar(100) NOT NULL,
	"anchor_day" integer,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
DELETE FROM "wealth_snapshots" newer USING "wealth_snapshots" older
WHERE newer.user_id = older.user_id AND newer.date = older.date
  AND newer.created_at < older.created_at;
--> statement-breakpoint
ALTER TABLE "daily_briefings" ALTER COLUMN "health_score" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "daily_briefings" ALTER COLUMN "health_status" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "daily_briefings" ADD COLUMN "score_state" varchar(30) DEFAULT 'available' NOT NULL;--> statement-breakpoint
ALTER TABLE "daily_briefings" ADD COLUMN "score_explanation" text DEFAULT '' NOT NULL;--> statement-breakpoint
ALTER TABLE "daily_briefings" ADD COLUMN "score_factors_json" jsonb DEFAULT '[]'::jsonb NOT NULL;--> statement-breakpoint
ALTER TABLE "profiles" ADD COLUMN "timezone" varchar(100) DEFAULT 'Asia/Karachi' NOT NULL;--> statement-breakpoint
ALTER TABLE "recurring_occurrences" ADD CONSTRAINT "recurring_occurrences_series_id_recurring_series_id_fk" FOREIGN KEY ("series_id") REFERENCES "public"."recurring_series"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "recurring_occurrences" ADD CONSTRAINT "recurring_occurrences_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "recurring_occurrences" ADD CONSTRAINT "recurring_occurrences_confirmed_transaction_id_transactions_id_fk" FOREIGN KEY ("confirmed_transaction_id") REFERENCES "public"."transactions"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "recurring_series" ADD CONSTRAINT "recurring_series_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "nav_cross_validation_instrument_date_idx" ON "nav_cross_validations" USING btree ("instrument","as_of","primary_source","validation_source");--> statement-breakpoint
CREATE UNIQUE INDEX "recurring_occurrence_series_date_idx" ON "recurring_occurrences" USING btree ("series_id","local_date");

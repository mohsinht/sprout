CREATE TABLE "ai_daily_usage" (
	"usage_date" date PRIMARY KEY NOT NULL,
	"cost_cents" integer DEFAULT 0 NOT NULL,
	"call_count" integer DEFAULT 0 NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "ai_rewrite_cache" (
	"input_hash" varchar(64) PRIMARY KEY NOT NULL,
	"output_json" jsonb NOT NULL,
	"model" text NOT NULL,
	"original_cost_cents" integer NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);

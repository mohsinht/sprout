ALTER TABLE "refresh_tokens" ADD COLUMN "device_id" varchar(128);--> statement-breakpoint
ALTER TABLE "refresh_tokens" ADD COLUMN "device_name" varchar(120);--> statement-breakpoint
ALTER TABLE "refresh_tokens" ADD COLUMN "last_used_at" timestamp with time zone;
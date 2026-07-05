import { z } from "zod";

import { CurrencySchema } from "./models.js";

export const ProfileLevelSchema = z.object({
  level: z.number().int().positive(),
  title: z.string(),
  currentXp: z.number().int().nonnegative(),
  nextLevelXp: z.number().int().positive(),
  totalXp: z.number().int().nonnegative()
});

export const ProfileUserSchema = z.object({
  id: z.string(),
  name: z.string(),
  firstName: z.string(),
  level: ProfileLevelSchema
});

export const StreakDaySchema = z.object({
  date: z.string(),
  status: z.enum(["completed", "missed", "rest", "today"]),
  xp: z.number().int().nonnegative()
});

export const ProfileStreakSchema = z.object({
  current: z.number().int().nonnegative(),
  longest: z.number().int().nonnegative(),
  history: z.array(StreakDaySchema)
});

export const AchievementSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  icon: z.enum(["savings", "streak", "review", "learner", "zakat", "committee"]),
  earned: z.boolean(),
  earnedOn: z.string().nullable(),
  progress: z.number().min(0).max(1),
  rewardXp: z.number().int().nonnegative()
});

export const ReviewItemSchema = z.object({
  id: z.string(),
  label: z.string(),
  amount: z.number().nonnegative(),
  currency: CurrencySchema,
  reason: z.string(),
  suggestedCategory: z.string()
});

export const DataSourceSchema = z.object({
  id: z.string(),
  name: z.string(),
  type: z.enum(["gmail", "bank", "wise", "investment"]),
  status: z.enum(["connected", "needs_review", "not_connected"]),
  confidence: z.enum(["high", "medium", "low"]),
  confidenceScore: z.number().int().min(0).max(100),
  needsReviewCount: z.number().int().nonnegative(),
  lastSyncedLabel: z.string(),
  reads: z.array(z.string()),
  reviewItems: z.array(ReviewItemSchema)
});

export const ProfileSettingsSchema = z.object({
  theme: z.enum(["system", "light", "dark"]),
  language: z.enum(["en", "ur"]),
  hideBalancesDefault: z.boolean(),
  notificationsEnabled: z.boolean(),
  reduceMotionNote: z.string()
});

export const ProfileTrustSchema = z.object({
  summary: z.string(),
  oauthOnly: z.boolean(),
  storesBankPasswords: z.boolean(),
  statementsDiscardedAfterParsingDefault: z.boolean()
});

export const ProfileResponseSchema = z.object({
  user: ProfileUserSchema,
  streak: ProfileStreakSchema,
  achievements: z.array(AchievementSchema),
  dataSources: z.array(DataSourceSchema),
  settings: ProfileSettingsSchema,
  trust: ProfileTrustSchema
});

export type ProfileLevel = z.infer<typeof ProfileLevelSchema>;
export type ProfileUser = z.infer<typeof ProfileUserSchema>;
export type StreakDay = z.infer<typeof StreakDaySchema>;
export type ProfileStreak = z.infer<typeof ProfileStreakSchema>;
export type Achievement = z.infer<typeof AchievementSchema>;
export type ReviewItem = z.infer<typeof ReviewItemSchema>;
export type DataSource = z.infer<typeof DataSourceSchema>;
export type ProfileSettings = z.infer<typeof ProfileSettingsSchema>;
export type ProfileTrust = z.infer<typeof ProfileTrustSchema>;
export type ProfileResponse = z.infer<typeof ProfileResponseSchema>;

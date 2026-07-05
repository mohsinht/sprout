import { z } from "zod";

/** English and Urdu-ready display copy for every learnable text field. */
export const LocalizedTextSchema = z.object({
  en: z.string(),
  ur: z.string().optional()
});

/** A single node in the ordered Learn lesson path. */
export const LessonNodeSchema = z.object({
  id: z.string(),
  title: LocalizedTextSchema,
  status: z.enum(["locked", "available", "done"]),
  xp: z.number().int().positive()
});

/** A short lesson card designed for a 30-60 second learning session. */
export const LessonCardSchema = z.object({
  title: LocalizedTextSchema,
  body: LocalizedTextSchema
});

/** One gentle comprehension check at the end of each micro-lesson. */
export const CheckQuestionSchema = z.object({
  prompt: LocalizedTextSchema,
  options: z.array(LocalizedTextSchema).min(2),
  correctIndex: z.number().int().nonnegative(),
  explanation: LocalizedTextSchema
});

/** Full playable lesson content for a Learn path node. */
export const LessonSchema = z.object({
  id: z.string(),
  cards: z.array(LessonCardSchema).min(1).max(3),
  checkQuestion: CheckQuestionSchema
});

/** Ordered Learn path plus the lesson bodies needed by the mobile player. */
export const LessonPathSchema = z.object({
  id: z.string(),
  title: LocalizedTextSchema,
  levelLabel: z.string(),
  nodes: z.array(LessonNodeSchema),
  lessons: z.array(LessonSchema)
});

export const LearnResponseSchema = z.object({
  user: z.object({
    level: z.number().int().positive(),
    xp: z.number().int().nonnegative(),
    dayStreak: z.number().int().nonnegative()
  }),
  path: LessonPathSchema
});

export type LocalizedText = z.infer<typeof LocalizedTextSchema>;
export type LessonNode = z.infer<typeof LessonNodeSchema>;
export type LessonCard = z.infer<typeof LessonCardSchema>;
export type CheckQuestion = z.infer<typeof CheckQuestionSchema>;
export type Lesson = z.infer<typeof LessonSchema>;
export type LessonPath = z.infer<typeof LessonPathSchema>;
export type LearnResponse = z.infer<typeof LearnResponseSchema>;

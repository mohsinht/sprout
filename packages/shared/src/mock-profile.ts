import type { ProfileResponse } from "./profile.js";

export const mockProfileResponse: ProfileResponse = {
  user: {
    id: "user-mohsin",
    name: "Mohsin Hayat",
    firstName: "Mohsin",
    level: {
      level: 6,
      title: "Money Gardener",
      currentXp: 1840,
      nextLevelXp: 2200,
      totalXp: 1840
    }
  },
  streak: {
    current: 12,
    longest: 21,
    history: [
      { date: "2026-06-08", status: "completed", xp: 15 },
      { date: "2026-06-09", status: "completed", xp: 20 },
      { date: "2026-06-10", status: "missed", xp: 0 },
      { date: "2026-06-11", status: "completed", xp: 15 },
      { date: "2026-06-12", status: "completed", xp: 20 },
      { date: "2026-06-13", status: "rest", xp: 0 },
      { date: "2026-06-14", status: "completed", xp: 15 },
      { date: "2026-06-15", status: "completed", xp: 20 },
      { date: "2026-06-16", status: "completed", xp: 15 },
      { date: "2026-06-17", status: "completed", xp: 20 },
      { date: "2026-06-18", status: "completed", xp: 15 },
      { date: "2026-06-19", status: "completed", xp: 20 },
      { date: "2026-06-20", status: "rest", xp: 0 },
      { date: "2026-06-21", status: "completed", xp: 15 },
      { date: "2026-06-22", status: "completed", xp: 20 },
      { date: "2026-06-23", status: "completed", xp: 15 },
      { date: "2026-06-24", status: "completed", xp: 20 },
      { date: "2026-06-25", status: "completed", xp: 15 },
      { date: "2026-06-26", status: "completed", xp: 20 },
      { date: "2026-06-27", status: "completed", xp: 15 },
      { date: "2026-06-28", status: "completed", xp: 20 },
      { date: "2026-06-29", status: "completed", xp: 15 },
      { date: "2026-06-30", status: "completed", xp: 20 },
      { date: "2026-07-01", status: "completed", xp: 15 },
      { date: "2026-07-02", status: "completed", xp: 20 },
      { date: "2026-07-03", status: "completed", xp: 15 },
      { date: "2026-07-04", status: "completed", xp: 20 },
      { date: "2026-07-05", status: "today", xp: 0 }
    ]
  },
  achievements: [
    {
      id: "badge-buffer",
      title: "Emergency Buffer",
      description: "Saved one month of expenses.",
      icon: "savings",
      earned: true,
      earnedOn: "2026-06-21",
      progress: 1,
      rewardXp: 80
    },
    {
      id: "badge-streak",
      title: "12-Day Streak",
      description: "Checked money for twelve days.",
      icon: "streak",
      earned: true,
      earnedOn: "2026-07-04",
      progress: 1,
      rewardXp: 60
    },
    {
      id: "badge-review",
      title: "Careful Reviewer",
      description: "Confirm 25 uncertain items.",
      icon: "review",
      earned: false,
      earnedOn: null,
      progress: 0.68,
      rewardXp: 50
    },
    {
      id: "badge-learner",
      title: "Tax Learner",
      description: "Finish the salary tax path.",
      icon: "learner",
      earned: false,
      earnedOn: null,
      progress: 0.35,
      rewardXp: 70
    },
    {
      id: "badge-zakat",
      title: "Zakat Planner",
      description: "Plan Zakat before Ramadan.",
      icon: "zakat",
      earned: true,
      earnedOn: "2026-06-10",
      progress: 1,
      rewardXp: 40
    },
    {
      id: "badge-committee",
      title: "Committee Captain",
      description: "Track three committee deposits.",
      icon: "committee",
      earned: false,
      earnedOn: null,
      progress: 0.45,
      rewardXp: 45
    }
  ],
  dataSources: [
    {
      id: "gmail",
      name: "Gmail",
      type: "gmail",
      status: "connected",
      confidence: "high",
      confidenceScore: 94,
      needsReviewCount: 0,
      lastSyncedLabel: "Finance senders checked today",
      reads: ["Receipts", "bank alerts", "utility bills", "Wise emails"],
      reviewItems: []
    },
    {
      id: "meezan",
      name: "Meezan Bank",
      type: "bank",
      status: "needs_review",
      confidence: "medium",
      confidenceScore: 76,
      needsReviewCount: 2,
      lastSyncedLabel: "SMS alerts imported today",
      reads: ["Masked SMS alerts", "transaction amount", "merchant text"],
      reviewItems: [
        {
          id: "review-fuel",
          label: "PSO Clifton",
          amount: 8500,
          currency: "PKR",
          reason: "Fuel or car maintenance both match this alert.",
          suggestedCategory: "Fuel"
        },
        {
          id: "review-grocery",
          label: "Imtiaz Super Market",
          amount: 12500,
          currency: "PKR",
          reason: "Receipt total is clear; category needs your tap.",
          suggestedCategory: "Groceries"
        }
      ]
    },
    {
      id: "wise",
      name: "Wise",
      type: "wise",
      status: "connected",
      confidence: "high",
      confidenceScore: 91,
      needsReviewCount: 0,
      lastSyncedLabel: "USD and EUR balances imported",
      reads: ["Balance emails", "transfer status", "currency labels"],
      reviewItems: []
    },
    {
      id: "al-meezan",
      name: "Al Meezan",
      type: "investment",
      status: "needs_review",
      confidence: "low",
      confidenceScore: 58,
      needsReviewCount: 1,
      lastSyncedLabel: "NAV updated yesterday",
      reads: ["Folio label", "fund name", "NAV value", "unit count"],
      reviewItems: [
        {
          id: "review-nav",
          label: "Al Meezan Cash Fund",
          amount: 325000,
          currency: "PKR",
          reason: "NAV matched, but the folio label was partially masked.",
          suggestedCategory: "Investments"
        }
      ]
    }
  ],
  settings: {
    theme: "system",
    language: "en",
    hideBalancesDefault: true,
    notificationsEnabled: true,
    reduceMotionNote: "Sprout follows your device reduce-motion setting."
  },
  trust: {
    summary:
      "OAuth-only connections. Sprout never asks for stored bank passwords and discards statements after parsing by default.",
    oauthOnly: true,
    storesBankPasswords: false,
    statementsDiscardedAfterParsingDefault: true
  }
};

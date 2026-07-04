import type { TodayResponse } from "./models.js";

export const mockTodayResponse: TodayResponse = {
  user: {
    firstName: "Mohsin",
    level: 6,
    xp: 1840,
    dayStreak: 12
  },
  currency: "PKR",
  salary: {
    nextPayday: "2026-07-06",
    daysUntilSalary: 3
  },
  health: {
    score: 78,
    status: "healthy",
    summary: "You are on track, but today's spending is slightly fast.",
    positiveFactors: [
      "Emergency buffer is strong",
      "Salary lands in 3 days",
      "Al Meezan NAV updated yesterday"
    ],
    attentionFactors: [
      "Spending pace is slightly high",
      "3 transactions need confirmation"
    ],
    recommendedAction: {
      title: "Move PKR 10,000 to Emergency Fund",
      xp: 20,
      impact: "+3 health score"
    }
  },
  accounts: [
    {
      id: "meezan-current",
      provider: "Meezan Bank",
      label: "Salary Account",
      maskedRef: "•••• 4821",
      type: "bank",
      balance: 168500,
      currency: "PKR",
      updatedLabel: "SMS alert today"
    },
    {
      id: "wise-usd",
      provider: "Wise",
      label: "USD Balance",
      maskedRef: "USD",
      type: "foreign_balance",
      balance: 94200,
      currency: "PKR",
      updatedLabel: "Imported today"
    },
    {
      id: "al-meezan",
      provider: "Al Meezan",
      label: "Mutual Funds",
      maskedRef: "Folio ••91",
      type: "investment",
      balance: 325000,
      currency: "PKR",
      updatedLabel: "NAV updated yesterday"
    }
  ],
  transactions: [
    {
      id: "txn-chai",
      label: "Chai and snacks",
      category: "Eating Out",
      amount: 420,
      currency: "PKR",
      capturedFrom: "manual",
      needsConfirmation: false
    },
    {
      id: "txn-fuel",
      label: "Fuel",
      category: "Fuel",
      amount: 8500,
      currency: "PKR",
      capturedFrom: "sms",
      needsConfirmation: true
    },
    {
      id: "txn-grocery",
      label: "Grocery run",
      category: "Groceries",
      amount: 12500,
      currency: "PKR",
      capturedFrom: "gmail",
      needsConfirmation: true
    }
  ],
  autoCapture: [
    {
      id: "gmail",
      label: "Gmail",
      status: "connected",
      detail: "Finance senders only"
    },
    {
      id: "meezan-alerts",
      label: "Meezan alerts",
      status: "detected",
      detail: "2 alerts today"
    },
    {
      id: "wise",
      label: "Wise balance",
      status: "imported",
      detail: "USD and EUR balances"
    },
    {
      id: "al-meezan-nav",
      label: "Al Meezan NAV",
      status: "updated",
      detail: "Updated yesterday"
    },
    {
      id: "review",
      label: "Review needed",
      status: "needs_review",
      detail: "3 transactions"
    }
  ],
  snapshot: {
    availableCash: 168500,
    monthSpent: 216400,
    budgetRemaining: 83500,
    upcomingBills: 42000,
    unconfirmedTransactions: 3
  },
  quickActions: [
    "Chai",
    "Fuel",
    "Groceries",
    "IBFT",
    "Utility Bill",
    "JazzCash",
    "Easypaisa",
    "Al Meezan Top-up",
    "Wise Transfer"
  ]
};

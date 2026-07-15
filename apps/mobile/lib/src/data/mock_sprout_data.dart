import '../domain/sprout_models.dart';

/// Centralized mock data for the Add / Money / Learn / Settings screens.
///
/// Today is finalised separately and keeps its own mock repository.
/// Everything here is hand-maintained (the "manual-only user" path),
/// so the app is fully useful with zero connected accounts.

// ── Accounts ──────────────────────────────────────────────────────────────

const mockAccounts = <SproutAccount>[
  SproutAccount(
    id: 'cash',
    name: 'Cash',
    type: AccountType.cash,
    balance: 18500,
    currency: 'PKR',
    lastUpdatedLabel: 'Edited just now',
    isManual: true,
  ),
  SproutAccount(
    id: 'meezan-current',
    name: 'Meezan Current',
    type: AccountType.bank,
    balance: 168500,
    currency: 'PKR',
    lastUpdatedLabel: 'Updated today',
    isManual: true,
  ),
  SproutAccount(
    id: 'easypaisa',
    name: 'Easypaisa',
    type: AccountType.wallet,
    balance: 4200,
    currency: 'PKR',
    lastUpdatedLabel: 'Updated yesterday',
    isManual: true,
  ),
  SproutAccount(
    id: 'wise',
    name: 'Wise',
    type: AccountType.wise,
    balance: 94200,
    currency: 'PKR',
    lastUpdatedLabel: 'Imported today',
    isManual: true,
  ),
  SproutAccount(
    id: 'al-meezan',
    name: 'Al Meezan Funds',
    type: AccountType.investment,
    balance: 325000,
    currency: 'PKR',
    lastUpdatedLabel: 'NAV updated yesterday',
    isManual: true,
  ),
];

// ── Budget ────────────────────────────────────────────────────────────────

const mockBudget = SproutBudget(
  monthlyIncome: 285000,
  safeToSpend: 95000,
  spent: 40100,
  remaining: 54900,
  month: 'July 2026',
);

// ── Goals ─────────────────────────────────────────────────────────────────

final mockGoals = <SproutGoal>[
  const SproutGoal(
    id: 'emergency',
    name: 'Emergency Fund',
    targetAmount: 450000,
    currentAmount: 225000,
    currency: 'PKR',
    deadline: null,
    status: GoalStatus.active,
    nextStep: 'Add PKR 5,000 this week',
  ),
  const SproutGoal(
    id: 'car',
    name: 'Car Fund',
    targetAmount: 2400000,
    currentAmount: 1152000,
    currency: 'PKR',
    deadline: null,
    status: GoalStatus.active,
    nextStep: 'Add PKR 15,000 this month',
  ),
  const SproutGoal(
    id: 'travel',
    name: 'Travel Fund',
    targetAmount: 120000,
    currentAmount: 57600,
    currency: 'PKR',
    deadline: null,
    status: GoalStatus.active,
    nextStep: 'Add PKR 4,000 this month',
  ),
];

// ── Transactions ──────────────────────────────────────────────────────────

final mockTransactions = <SproutTransaction>[
  SproutTransaction(
    id: 'txn-chai',
    amount: 420,
    currency: 'PKR',
    type: TransactionType.expense,
    category: 'Chai',
    merchant: 'Chai and snacks',
    note: 'Office break',
    date: _mockToday,
    source: TransactionSource.manual,
    needsReview: false,
    confidence: 1.0,
    accountId: 'cash',
  ),
  SproutTransaction(
    id: 'txn-fuel',
    amount: 8500,
    currency: 'PKR',
    type: TransactionType.expense,
    category: 'Fuel',
    merchant: 'Shell',
    note: 'Full tank',
    date: _mockToday,
    source: TransactionSource.sms,
    needsReview: true,
    confidence: 0.8,
    accountId: 'meezan-current',
  ),
  SproutTransaction(
    id: 'txn-grocery',
    amount: 12500,
    currency: 'PKR',
    type: TransactionType.expense,
    category: 'Groceries',
    merchant: 'Carrefour',
    note: 'Weekly run',
    date: _mockToday,
    source: TransactionSource.email,
    needsReview: true,
    confidence: 0.72,
    accountId: 'meezan-current',
  ),
  SproutTransaction(
    id: 'txn-salary',
    amount: 285000,
    currency: 'PKR',
    type: TransactionType.income,
    category: 'Salary',
    merchant: 'Employer',
    note: 'July salary',
    date: _mockSalaryDate,
    source: TransactionSource.statement,
    needsReview: false,
    confidence: 0.95,
    accountId: 'meezan-current',
  ),
];

/// Fixed reference dates for mock rows. The app never uses real wall-clock
/// time for mock data so screens stay deterministic.
final _mockToday = DateTime(2026, 7, 5);
final _mockSalaryDate = DateTime(2026, 7, 1);

// ── Investments snapshot ───────────────────────────────────────────────────

const mockInvestments = <SproutAccount>[
  SproutAccount(
    id: 'al-meezan',
    name: 'Mutual Funds (Al Meezan)',
    type: AccountType.investment,
    balance: 325000,
    currency: 'PKR',
    lastUpdatedLabel: 'NAV updated yesterday',
    isManual: true,
  ),
  SproutAccount(
    id: 'cash-buffer',
    name: 'Cash Buffer',
    type: AccountType.cash,
    balance: 225000,
    currency: 'PKR',
    lastUpdatedLabel: 'Manual',
    isManual: true,
  ),
  SproutAccount(
    id: 'wise-usd',
    name: 'Foreign Currency (Wise)',
    type: AccountType.wise,
    balance: 94200,
    currency: 'PKR',
    lastUpdatedLabel: 'Imported today',
    isManual: true,
  ),
];

// ── Lessons ────────────────────────────────────────────────────────────────

const mockLessons = <SproutLesson>[
  SproutLesson(
    id: 'cash-buffer',
    title: 'What is a cash buffer?',
    benefit: 'Sleep better before salary day.',
    durationSeconds: 30,
    xp: 20,
    completed: true,
    concept: 'A cash buffer is money you keep aside for the days just before '
        'salary. It stops you from borrowing or skipping bills.',
    example: 'Keeping PKR 10,000 aside means a surprise bill on the 28th does '
        'not scare you.',
    tinyAction: 'Move PKR 2,000 to your cash buffer today.',
  ),
  SproutLesson(
    id: 'inflation',
    title: 'Why inflation matters',
    benefit: 'Stop your savings quietly shrinking.',
    durationSeconds: 30,
    xp: 20,
    completed: true,
    concept: 'If prices rise 10 percent and your money earns 0 percent, your '
        'buying power quietly shrinks.',
    example: 'PKR 100,000 saved for a year at 0 percent buys about PKR 90,000 '
        'worth of things after 10 percent inflation.',
    tinyAction: 'Keep some savings in places that can grow.',
  ),
  SproutLesson(
    id: 'salary-tax',
    title: 'Salary tax basics',
    benefit: 'Understand your payslip without jargon.',
    durationSeconds: 30,
    xp: 25,
    completed: false,
    concept: 'Employers in Pakistan deduct tax from your salary and send it to '
        'FBR. Your take-home is what remains after this.',
    example: 'A PKR 200,000 salary may show PKR 170,000 in your account.',
    tinyAction: 'Check your latest payslip and note the tax line.',
  ),
  SproutLesson(
    id: 'mutual-fund',
    title: 'What is a mutual fund?',
    benefit: 'A simple way to start growing small savings.',
    durationSeconds: 30,
    xp: 20,
    completed: false,
    concept: 'A mutual fund pools money from many people and invests it. You '
        'own small units of the whole pool.',
    example: 'Al Meezan and NBP funds let you start with a few thousand.',
    tinyAction: 'Look up one mutual fund name you have heard of.',
  ),
  SproutLesson(
    id: 'raast-ibft',
    title: 'Raast vs IBFT',
    benefit: 'Pick the cheaper way to move money.',
    durationSeconds: 30,
    xp: 20,
    completed: false,
    concept: 'Raast is Pakistan\'s instant payment system, often free. IBFT '
        'moves money between banks and may have a small fee.',
    example: 'Sending to a friend on Raast can be instant and free.',
    tinyAction: 'Check if your bank app offers Raast transfers.',
  ),
  SproutLesson(
    id: 'debit-credit',
    title: 'Debit card vs credit card',
    benefit: 'Know which one spends your own money.',
    durationSeconds: 30,
    xp: 20,
    completed: false,
    concept: 'A debit card spends money already in your account. A credit card '
        'borrows money you must pay back.',
    example: 'Debit = your money now. Credit = borrowed, repay later.',
    tinyAction: 'Use debit for daily spend to stay in control.',
  ),
  SproutLesson(
    id: 'zakat-savings',
    title: 'Zakat and savings',
    benefit: 'Know when zakat applies to your savings.',
    durationSeconds: 30,
    xp: 25,
    completed: false,
    concept: 'Zakat is 2.5 percent of savings you have held for a lunar year '
        'above a threshold (nisab).',
    example: 'On PKR 500,000 of qualifying savings, zakat is PKR 12,500.',
    tinyAction: 'Note roughly how much savings you have held for a year.',
  ),
  SproutLesson(
    id: 'emergency-fund',
    title: 'Emergency fund basics',
    benefit: 'A cushion for the surprises life throws.',
    durationSeconds: 30,
    xp: 25,
    completed: false,
    concept: 'An emergency fund is 1 to 3 months of expenses kept aside for '
        'real surprises, not treats.',
    example: 'If you spend PKR 80,000 a month, aim for PKR 80,000+ first.',
    tinyAction: 'Pick one amount to start your emergency fund this month.',
  ),
];

// ── Profile & settings ─────────────────────────────────────────────────────

const mockProfile = SproutProfile(
  name: 'Mohsin',
  monthlyIncome: 285000,
  salaryDate: '1st of every month',
  hasFreelanceIncome: true,
);

const mockDataSources = <SproutDataSource>[
  SproutDataSource(
    id: 'manual',
    label: 'Manual entries',
    detail: 'Always on',
    connected: true,
  ),
  SproutDataSource(
    id: 'email',
    label: 'Email connection',
    detail: 'Not connected',
    connected: false,
  ),
  SproutDataSource(
    id: 'statement',
    label: 'Statement imports',
    detail: '2 imported this month',
    connected: true,
  ),
  SproutDataSource(
    id: 'sms',
    label: 'SMS detection',
    detail: 'Android only — coming soon',
    connected: false,
    comingSoon: true,
  ),
];

// ── Settings-side models ────────────────────────────────────────────────────

class SproutProfile {
  const SproutProfile({
    required this.name,
    required this.monthlyIncome,
    required this.salaryDate,
    required this.hasFreelanceIncome,
  });

  final String name;
  final int monthlyIncome;
  final String salaryDate;
  final bool hasFreelanceIncome;
}

class SproutDataSource {
  const SproutDataSource({
    required this.id,
    required this.label,
    required this.detail,
    required this.connected,
    this.comingSoon = false,
    this.remoteId,
  });

  final String id;
  final String label;
  final String detail;
  final bool connected;
  final String? remoteId;

  /// When true, the source is not yet available — rendered as "Soon" and
  /// not tappable for connect/disconnect.
  final bool comingSoon;
}

/// Privacy trust statements shown on Settings → Privacy.
const mockPrivacyStatements = <String>[
  'We never ask for bank passwords.',
  'You control connected sources.',
  'You can delete imported data.',
  'Uncertain transactions require confirmation.',
];

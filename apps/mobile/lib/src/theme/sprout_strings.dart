import 'package:intl/intl.dart';

/// Centralized user-facing strings for Sprout.
///
/// This is a lightweight scaffold ahead of full `flutter gen-l10n` ARB-based
/// localization. Keeping every label here means the eventual migration to
/// generated `AppLocalizations` is a mechanical swap.
///
/// To add Urdu (ur-PK): copy this class, translate the values, and select
/// based on `Platform.localeName` / a user setting.
class SproutStrings {
  const SproutStrings._();

  // App
  static const appName = 'Sprout';

  // Today
  static const todayTitle = 'Today';
  static String greeting(String firstName) => 'Salaam, $firstName 👋';
  static const moneyGardenCalm = 'Your money garden is calm today.';
  static String paydayIn(int days) => 'Payday in $days days 🎁';
  static const paydayAlmostThere = 'Almost there. Keep it chill.';
  static const paydayPlan = 'Payday plan';
  static const expectedSalaryDate = 'Expected salary date';
  static const limitTillSalary = 'Spend limit till salary';
  static const safeSpendToday = 'Safe spend today';
  static const financialHealthScore = 'Financial Health Score';
  static const healthScore = 'Health score';
  static const lookingGood = 'Looking good 🌱';
  static const safeTodayReview = 'Safe today. 3 tiny things to review.';
  static const questPlanted = 'Quest planted! 🌱';
  static const scoreClimbed = 'Your score climbed. Keep the streak alive.';
  static const needsAttention = 'Worth a look';
  static const okay = 'Okay';
  static const healthy = 'Healthy';
  static const todaysSnapshot = "Today's snapshot";
  static const viewAll = 'View all';
  static const nextStep = 'NEXT STEP';
  static const plantPkr10k = 'Plant PKR 10K 🌱';
  static const savePkr10k = 'Save PKR 10K';
  static const moneyRadar = 'Money radar';
  static String needReview(int count) => '$count need review';
  static const viewDetails = 'View details';
  static const quickActions = 'Quick actions';

  // Learn
  static const learnTitle = 'Learn';
  static const learnSubtitle = 'Tiny money lessons. One minute max.';
  static const loadingLearn = 'Opening your lesson path…';
  static const couldNotLoadLearn = 'Sprout could not load Learn.';
  static const learningStreak = 'Learning streak';
  static String days(int days) => '$days days';
  static String todayLesson(String title) => 'Today: $title';
  static const pathComplete = 'Path complete. You planted every lesson.';
  static const yourPath = 'Your path';
  static const done = 'Done';
  static const available = 'Ready';
  static const locked = 'Locked';
  static const lessonQuest = 'LESSON QUEST';
  static const allLessonsPlanted = 'All lessons planted';
  static const lesson = 'Lesson';
  static String finishLesson(String title) => 'Finish $title';
  static String startLesson(String title) => 'Start lesson: $title';
  static const close = 'Close';
  static const takeCheck = 'Take the check';
  static const next = 'Next';
  static const oneMinuteTakeaway = 'One-minute takeaway';
  static const learnTinyHabit = 'Learn one tiny habit, then use it today.';
  static const worksOffline = 'Works even with no bank connected.';
  static const quickCheck = 'Quick check';
  static const lessonComplete = 'Lesson complete';
  static const tryAgainCalm = 'Almost. No XP lost.';
  static const nextLessonUnlocked = 'Next lesson unlocked';
  static String xpAdded(int xp) => '+$xp XP added. Nice progress.';
  static const reReadTinyCard = 'Review the tiny card once more.';
  static const noLostXp = 'Almost. No XP lost — this is just practice.';
  static const backToPath = 'Back to path';
  static const reviewAgain = 'Review again';

  // Budget
  static const budgetTitle = 'Budget';
  static String budgetSubtitle(String month) => '$month pace check';
  static const budgetMonth = 'Budget month';
  static const currentMonth = 'Current month';
  static const monthProgress = 'Month progress';
  static String daysIntoMonth(int elapsed, int total) =>
      '$elapsed of $total days complete';
  static const remainingBudget = 'Remaining budget';
  static String budgetPaceStatus(String status) =>
      '$status pace for this month';
  static const categoryHealth = 'Category health';
  static const spendByCategory = 'Spend by category';
  static const upcomingBills = 'Upcoming bills';
  static const spent = 'Spent';
  static const budgeted = 'Budgeted';
  static String spentOfBudget(String spent, String budgeted) =>
      '$spent of $budgeted';
  static String billDue(String amount, String date) => '$amount due $date';
  static const budgetWatch = 'Watch';
  static const budgetOver = 'Over';
  static const lowRisk = 'Low';
  static const mediumRisk = 'Medium';
  static const highRisk = 'Watch this month';
  static const budgetQuest = 'BUDGET QUEST';
  static const reward = 'Reward';
  static const impact = 'Impact';
  static String xpReward(int xp) => '+$xp XP';
  static const budgetEmptyTitle = 'Start logging to see your budget bloom';
  static const budgetEmptySubtitle =
      'Add one chai, fuel, or grocery spend and Sprout will build a calm monthly pace check.';
  static const logFirstSpend = 'Log first spend';

  // Grow
  static const growTitle = 'Grow';
  static const growSubtitle = 'Goals, buffer, and calm NAV snapshots.';
  static const growLoading = 'Growing your garden…';
  static const moneyGarden = 'Money garden';
  static const emergencyFund = 'Emergency fund';
  static const investmentSnapshot = 'Investment snapshot';
  static const createGoal = 'Create a goal';
  static const todayChangeSuffix = 'today';
  static const emergencyBufferWhy =
      'A larger buffer protects rent, bills, and family commitments before extra risk.';
  static const manualFirst = 'Manual first';
  static const manualFirstGoal =
      'Name the goal, pick a target, and Sprout will track progress without connections.';
  static const starterIdea = 'Starter idea';
  static const starterIdeaGoal =
      'Try PKR 50,000 for a small emergency cushion.';

  // Money status tiles
  static const readyToUse = 'Ready to use';
  static const readyToUseHint = 'In bank, safe to spend';
  static const savedAway = 'Saved away';
  static const savedAwayHint = 'Emergency + investments';
  static const mainGoal = 'Main goal';
  static const mainGoalHint = 'Car fund progress';
  static const showBalances = 'Show balances';
  static const hideBalances = 'Hide balances';
  static const hiddenBalance = '••••••';

  // Daily quest
  static const dailyQuest = 'DAILY QUEST';
  static const questComplete = 'Quest complete';
  static const whyThisQuest = 'Why this quest?';
  static const recommendation = 'Recommendation';
  static const why = 'Why';
  static const confidence = 'Confidence';

  // Score chip
  static const scoreLabel = 'score';

  // Generic
  static const couldNotLoadToday = 'Sprout could not load today.';
  static const couldNotLoadBudget = 'Sprout could not load budget.';
  static const couldNotLoadGrow = 'Sprout could not load Grow.';
  static const retry = 'Retry';
  static const sprouting = 'Sprouting…';
}

/// Currency and date formatting helpers for the Pakistan market.
class SproutFormat {
  SproutFormat._();

  static final _currency = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'PKR ',
    decimalDigits: 0,
  );

  static final _date = DateFormat('MMM d, yyyy');

  /// Pakistan-natural compact form with whole-rupee zero handling.
  ///
  /// Unit fractions such as `2.5 lakh` describe a magnitude; raw rupee
  /// amounts never render a `.0` suffix.
  static String compactCurrency(num value) {
    final rounded = value.round();
    final absolute = rounded.abs();
    final sign = rounded < 0 ? '−' : '';
    if (absolute < 100000) return _currency.format(rounded);
    if (absolute < 10000000) {
      return 'PKR $sign${_compactUnit(absolute / 100000)} lakh';
    }
    return 'PKR $sign${_compactUnit(absolute / 10000000)} crore';
  }

  static String _compactUnit(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  }

  /// Full form, e.g. "PKR 168,000".
  static String currency(num value) => _currency.format(value);

  /// Date form, e.g. "Jul 5, 2026".
  static String date(DateTime value) => _date.format(value);
}

import 'package:flutter/material.dart';

import '../domain/sprout_models.dart';
import '../theme/sprout_tokens.dart';

/// UI mapping helpers for accounts and transaction sources so every screen
/// badges them the same way. Brand accent colors are constant across light
/// and dark themes; surfaces should come from [SproutColorScheme].
///
/// Money formatting lives in [SproutFormat] (theme/sprout_strings.dart) — use
/// `SproutFormat.currency` / `SproutFormat.compactCurrency` instead of local
/// formatters.

IconData accountIcon(AccountType type) {
  switch (type) {
    case AccountType.cash:
      return Icons.payments_rounded;
    case AccountType.bank:
      return Icons.account_balance_rounded;
    case AccountType.wallet:
      return Icons.account_balance_wallet_rounded;
    case AccountType.wise:
      return Icons.public_rounded;
    case AccountType.investment:
      return Icons.trending_up_rounded;
    case AccountType.other:
      return Icons.more_horiz_rounded;
  }
}

Color accountColor(AccountType type) {
  switch (type) {
    case AccountType.cash:
      return SproutColors.seed;
    case AccountType.bank:
      return SproutColors.sky;
    case AccountType.wallet:
      return SproutColors.lilac;
    case AccountType.wise:
      return SproutColors.gold;
    case AccountType.investment:
      return SproutColors.leaf;
    case AccountType.other:
      return SproutColors.muted;
  }
}

String sourceLabel(TransactionSource source) {
  switch (source) {
    case TransactionSource.manual:
      return 'manual';
    case TransactionSource.email:
      return 'email';
    case TransactionSource.statement:
      return 'statement';
    case TransactionSource.sms:
      return 'sms';
  }
}

Color sourceColor(TransactionSource source) {
  switch (source) {
    case TransactionSource.manual:
      return SproutColors.muted;
    case TransactionSource.email:
      return SproutColors.sky;
    case TransactionSource.statement:
      return SproutColors.lilac;
    case TransactionSource.sms:
      return SproutColors.gold;
  }
}

IconData sourceIcon(TransactionSource source) {
  switch (source) {
    case TransactionSource.manual:
      return Icons.touch_app_rounded;
    case TransactionSource.email:
      return Icons.alternate_email_rounded;
    case TransactionSource.statement:
      return Icons.description_outlined;
    case TransactionSource.sms:
      return Icons.sms_rounded;
  }
}
/// Small deterministic guardrails for rendered state copy.
class SproutCopyGuard {
  const SproutCopyGuard._();

  static const _unsupportedReassurance = <String>[
    'looking comfortable',
    'nice pace',
    'on track',
    'budget health',
  ];

  /// Empty financial states may explain what is missing, but may not infer a
  /// healthy pace or position from absent data.
  static bool isHonestForEmptyFinancialState(String copy) {
    final normalized = copy.toLowerCase();
    return !_unsupportedReassurance.any(normalized.contains);
  }
}

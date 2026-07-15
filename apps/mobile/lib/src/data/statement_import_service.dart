import 'package:csv/csv.dart';

import '../domain/sprout_models.dart';

class StatementImportException implements Exception {
  const StatementImportException(this.message);
  final String message;
}

class StatementImportService {
  const StatementImportService();

  List<SproutTransaction> parseCsv(String contents) {
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(contents.trim());
    if (rows.length < 2) {
      throw const StatementImportException(
        'This file has no transaction rows yet.',
      );
    }
    final headers = rows.first
        .map((value) => '$value'.trim().toLowerCase().replaceAll(' ', '_'))
        .toList();
    final amountIndex = headers.indexOf('amount');
    final dateIndex = headers.indexOf('date');
    final categoryIndex = headers.indexOf('category');
    if (amountIndex < 0 || dateIndex < 0 || categoryIndex < 0) {
      throw const StatementImportException(
        'Use columns named date, amount, and category. Type, merchant, and note are optional.',
      );
    }
    final typeIndex = headers.indexOf('type');
    final merchantIndex = headers.indexOf('merchant');
    final noteIndex = headers.indexOf('note');
    final parsed = <SproutTransaction>[];
    for (var index = 1; index < rows.length; index++) {
      final row = rows[index];
      if (row.every((value) => '$value'.trim().isEmpty)) continue;
      String cell(int column) =>
          column < 0 || column >= row.length ? '' : '${row[column]}'.trim();
      final rawAmount = cell(amountIndex).replaceAll(RegExp(r'[^0-9.-]'), '');
      final numeric = double.tryParse(rawAmount);
      final date = _parseDate(cell(dateIndex));
      final category = cell(categoryIndex);
      if (numeric == null || numeric == 0 || date == null || category.isEmpty) {
        throw StatementImportException(
          'Row ${index + 1} needs a valid date, amount, and category.',
        );
      }
      final rawType = cell(typeIndex).toLowerCase();
      final type = switch (rawType) {
        'income' || 'credit' => TransactionType.income,
        'expense' || 'debit' => TransactionType.expense,
        'transfer' => TransactionType.transfer,
        _ => numeric < 0 ? TransactionType.expense : TransactionType.income,
      };
      final merchant = cell(merchantIndex);
      parsed.add(SproutTransaction(
        id: 'statement-${DateTime.now().microsecondsSinceEpoch}-$index',
        amount: numeric.abs().round(),
        currency: 'PKR',
        type: type,
        category: category,
        merchant: merchant.isEmpty ? category : merchant,
        note: cell(noteIndex),
        date: date,
        source: TransactionSource.statement,
        needsReview: false,
        confidence: 1,
      ));
    }
    if (parsed.isEmpty) {
      throw const StatementImportException(
        'This file has no transaction rows yet.',
      );
    }
    return parsed;
  }

  DateTime? _parseDate(String value) {
    final direct = DateTime.tryParse(value);
    if (direct != null) return direct;
    final parts = value.split(RegExp(r'[/.-]'));
    if (parts.length != 3) return null;
    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    final third = int.tryParse(parts[2]);
    if (first == null || second == null || third == null) return null;
    try {
      return third > 1900
          ? DateTime(third, second, first)
          : DateTime(first, second, third);
    } catch (_) {
      return null;
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_mobile/src/data/statement_import_service.dart';
import 'package:sprout_mobile/src/domain/sprout_models.dart';

void main() {
  test('FUNC-IMPORT-01 parses reviewed CSV rows as whole PKR', () {
    const csv = '''date,amount,type,category,merchant,note
2026-07-14,-450,expense,Food,Chai spot,Tea
15/07/2026,120000,income,Salary,Employer,July salary
''';
    final rows = const StatementImportService().parseCsv(csv);

    expect(rows, hasLength(2));
    expect(rows.first.amount, 450);
    expect(rows.first.type, TransactionType.expense);
    expect(rows.first.source, TransactionSource.statement);
    expect(rows.last.type, TransactionType.income);
    expect(rows.last.amount, 120000);
  });

  test('FUNC-IMPORT-02 rejects files without the plain required columns', () {
    expect(
      () => const StatementImportService().parseCsv('value,when\n10,today'),
      throwsA(isA<StatementImportException>()),
    );
  });
}

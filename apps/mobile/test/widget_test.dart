import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout_mobile/src/app/sprout_app.dart';

void main() {
  testWidgets('Sprout opens on the Today screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SproutApp()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Salaam, Mohsin! 👋'), findsOneWidget);
    expect(find.text('Great job! 🌱'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_mobile/src/presentation/mascot_lab/mascot_lab_screen.dart';
import 'package:sprout_mobile/src/theme/sprout_theme.dart';
import 'package:sprout_mobile/src/widgets/sprout_mascot_state.dart';

void main() {
  testWidgets('mascot lab renders every still state without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(const MascotLabScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Mascot Lab'), findsOneWidget);
    expect(find.byKey(const ValueKey('mascot-lab-hero-fit')), findsOneWidget);
    for (final state in SproutMascotState.values) {
      expect(find.text(state.name), findsOneWidget);
      expect(
          find.byKey(ValueKey('mascot-state-${state.name}')), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('mascot lab can trigger one-shot animation safely',
      (tester) async {
    await tester.pumpWidget(_host(const MascotLabScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('mascot-lab-play')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('mascot-lab-hero-fit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildSproutTheme(brightness: Brightness.light),
    home: child,
  );
}

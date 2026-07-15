import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprout_mobile/src/data/api/sprout_api_client.dart';
import 'package:sprout_mobile/src/data/auth_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FUNC-AUTH-01 local-only session survives restart', () async {
    SharedPreferences.setMockInitialValues({});
    final first = AuthSessionStore(SproutApiClient(baseUrl: 'unused'));
    final session = await first.startGuest();
    expect(session.isGuest, isTrue);
    expect(session.onboardingComplete, isFalse);

    final second = AuthSessionStore(SproutApiClient(baseUrl: 'unused'));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(second.state?.isGuest, isTrue);
    expect(second.state?.userId, 'local-guest');
  });
}

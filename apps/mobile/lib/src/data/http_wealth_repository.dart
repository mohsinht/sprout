import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/wealth_models.dart';
import 'api/sprout_api_client.dart';
import 'mock_wealth_repository.dart';

/// Whether to use mock data or the real API.
///
/// Set via --dart-define=USE_MOCK=false to use the real backend.
/// Default is true (mock) so the app works offline without a backend.
const _useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

/// Provider for the wealth briefing repository.
///
/// Returns the HTTP implementation when USE_MOCK=false, otherwise the mock.
/// This is the single swap point — screens consume this provider, never the
/// concrete implementation.
final wealthBriefingRepositoryProvider =
    Provider<WealthBriefingRepository>((ref) {
  if (_useMock) {
    return MockWealthBriefingRepository();
  }
  return HttpWealthBriefingRepository(ref.read(apiClientProvider));
});

abstract interface class WealthBriefingRepository {
  Future<WealthBriefing> fetchWealthBriefing();
}

/// HTTP implementation — calls GET /v1/briefing on the real backend.
///
/// If the API is unreachable, throws an exception so Today can render its
/// explicit unavailable state. Never silently returns mock data as if it were
/// real — that would give the user a fabricated wealth number.
class HttpWealthBriefingRepository implements WealthBriefingRepository {
  HttpWealthBriefingRepository(this._client);

  final SproutApiClient _client;

  @override
  Future<WealthBriefing> fetchWealthBriefing() async {
    final json = await _client.get('/v1/briefing');
    return wealthBriefingFromApiJson(json);
  }
}

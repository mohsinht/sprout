import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/today_models.dart';
import '../domain/wealth_models.dart';
import 'api/sprout_api_client.dart';
import 'mock_today_repository.dart';

/// Provider for the today repository.
///
/// Returns the HTTP implementation when USE_MOCK=false, otherwise the mock.
/// The HTTP implementation fetches a WealthBriefing from the API and maps
/// it to TodayData via the bridge mapper.
final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  if (_useMock) {
    return MockTodayRepository();
  }
  return HttpTodayRepository(ref.read(apiClientProvider));
});

const _useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

abstract interface class TodayRepository {
  Future<TodayData> fetchToday();
}

/// HTTP implementation — calls GET /v1/briefing and maps to TodayData.
///
/// If the API is unreachable, throws an exception so Today can render its
/// explicit unavailable state. Never silently returns mock data as if it were
/// real.
class HttpTodayRepository implements TodayRepository {
  HttpTodayRepository(this._client);

  final SproutApiClient _client;

  @override
  Future<TodayData> fetchToday() async {
    final json = await _client.get('/v1/briefing');
    final briefing = wealthBriefingFromApiJson(json);
    return todayDataFromWealthBriefing(briefing);
  }
}

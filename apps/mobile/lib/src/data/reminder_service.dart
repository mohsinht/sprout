import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService._();

  static final instance = ReminderService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _ids = {
    'dailyCheckIn': 100,
    'billReminders': 101,
    'salaryIncomeReminders': 102,
    'weeklySummary': 103,
    'streakProtection': 104,
  };

  Future<void> initialize({required ValueChanged<String> onOpen}) async {
    if (_initialized || kIsWeb) return;
    tz_data.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      // The device timezone is preferred. PKT is the safe launch-market
      // fallback when a platform cannot report an IANA identifier.
      tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('/')) onOpen(payload);
      },
    );
    _initialized = true;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp == true &&
        payload != null &&
        payload.startsWith('/')) {
      onOpen(payload);
    }
  }

  Future<bool> setEnabled(
    String preference,
    bool enabled, {
    int? salaryDay,
  }) async {
    if (kIsWeb) return true;
    await initialize(onOpen: (_) {});
    final id = _ids[preference];
    if (id == null) return false;
    if (!enabled) {
      await _plugin.cancel(id: id);
      return true;
    }
    if (!await _requestPermission()) return false;

    switch (preference) {
      case 'dailyCheckIn':
        await _schedule(
          id: id,
          when: _nextTime(9),
          title: 'Sprout',
          body: "Sprout has today's money check-in ready.",
          payload: '/today',
          match: DateTimeComponents.time,
        );
        return true;
      case 'weeklySummary':
        await _schedule(
          id: id,
          when: _nextWeekday(DateTime.sunday, 18),
          title: 'Sprout',
          body: 'Your weekly money garden summary is ready.',
          payload: '/money',
          match: DateTimeComponents.dayOfWeekAndTime,
        );
        return true;
      case 'salaryIncomeReminders':
        if (salaryDay == null) {
          await _plugin.cancel(id: id);
          return true;
        }
        await _schedule(
          id: id,
          when: _nextDayOfMonth(salaryDay, 9),
          title: 'Sprout',
          body: 'Salary day is close. Sprout can help plan the first move.',
          payload: '/today',
          match: DateTimeComponents.dayOfMonthAndTime,
        );
        return true;
      case 'streakProtection':
        await _schedule(
          id: id,
          when: _nextTime(19),
          title: 'Sprout',
          body: 'No money move required today. Just check in.',
          payload: '/today',
          match: DateTimeComponents.time,
        );
        return true;
      case 'billReminders':
        // Bills are scheduled only when a confirmed unpaid bill falls within
        // the three-day contract. There is no V1 bill model to schedule from.
        await _plugin.cancel(id: id);
        return true;
      default:
        return false;
    }
  }

  Future<bool> _requestPermission() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case TargetPlatform.macOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    MacOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      default:
        return false;
    }
  }

  Future<void> _schedule({
    required int id,
    required tz.TZDateTime when,
    required String title,
    required String body,
    required String payload,
    required DateTimeComponents match,
  }) =>
      _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'sprout_reminders',
            'Sprout reminders',
            channelDescription: 'Private check-in and planning reminders',
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: match,
      );

  tz.TZDateTime _nextTime(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }

  tz.TZDateTime _nextWeekday(int weekday, int hour) {
    var next = _nextTime(hour);
    while (next.weekday != weekday) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  tz.TZDateTime _nextDayOfMonth(int day, int hour) {
    final now = tz.TZDateTime.now(tz.local);
    final safeDay = day.clamp(1, 28);
    var next = tz.TZDateTime(tz.local, now.year, now.month, safeDay, hour);
    if (!next.isAfter(now)) {
      next = tz.TZDateTime(tz.local, now.year, now.month + 1, safeDay, hour);
    }
    return next;
  }
}

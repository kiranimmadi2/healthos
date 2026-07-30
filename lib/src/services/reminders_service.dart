import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemindersService {
  RemindersService() {
    _initTimezones();
  }

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  void _initTimezones() {
    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Error initializing timezones: $e');
    }
  }

  Future<bool> init() async {
    if (_initialized) return true;

    if (kIsWeb) {
      _initialized = true;
      return true;
    }

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final success = await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
        await androidImpl.requestExactAlarmsPermission();
      }

      _initialized = success ?? true;
    } catch (e) {
      debugPrint('Local notifications init skipped: $e');
      _initialized = true;
    }
    return _initialized;
  }

  Future<void> scheduleMedicationReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (kIsWeb) return;
    if (!_initialized) {
      await init();
    }

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Notifications for scheduled medication doses',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))
            ? tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5))
            : tzScheduledTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      debugPrint('Scheduled medication reminder #$id at $tzScheduledTime');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllReminders() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}

final remindersServiceProvider = Provider<RemindersService>((ref) {
  return RemindersService();
});

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_model.dart';
import 'notification_service.dart';

class AlarmService {
  static final AndroidAlarmManager _alarmManager = AndroidAlarmManager.instance;

  static Future<void> initialize() async {
    await _alarmManager.initialize();
  }

  static Future<void> scheduleAlarm(Reminder reminder) async {
    final scheduledTime = tz.TZDateTime.from(reminder.remindAt, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledTime.isBefore(now)) {
      return;
    }

    final delay = scheduledTime.millisecondsSinceEpoch - now.millisecondsSinceEpoch;

    await _alarmManager.oneShotAt(
      scheduledTime.millisecondsSinceEpoch,
      reminder.id.hashCode,
      _alarmCallback,
      exact: true,
      wakeup: true,
      alarmClock: true,
      params: {
        'id': reminder.id,
        'title': reminder.title,
      },
    );
  }

  @pragma('vm:entry-point')
  static void _alarmCallback() {
    NotificationService.showInstantNotification(
      title: 'মনে রাখো - Reminder',
      body: 'Time for your reminder!',
    );
  }

  static Future<void> cancelAlarm(String reminderId) async {
    await _alarmManager.cancel(reminderId.hashCode);
  }

  static Future<void> cancelAllAlarms() async {
    await _alarmManager.cancelAll();
  }
}
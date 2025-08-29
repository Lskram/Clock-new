import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import 'dart:io';

import '../models/notification_session.dart';
import '../models/user_settings.dart';
import '../utils/constants.dart';
import 'database_service.dart';
import 'random_service.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final RandomService _randomService = Get.find<RandomService>();
  final Uuid _uuid = const Uuid();

  // Initialize method for GetxService
  Future<NotificationService> init() async {
    await _initializeNotifications();
    return this;
  }

  Future<void> _initializeNotifications() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: null,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // Exercise reminders channel
      const AndroidNotificationChannel exerciseChannel =
          AndroidNotificationChannel(
        NotificationChannels.EXERCISE_REMINDERS,
        NotificationChannels.EXERCISE_REMINDERS_NAME,
        description: NotificationChannels.EXERCISE_REMINDERS_DESC,
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        playSound: true,
      );

      // Persistent reminders channel  
      const AndroidNotificationChannel persistentChannel =
          AndroidNotificationChannel(
        NotificationChannels.PERSISTENT_REMINDERS,
        NotificationChannels.PERSISTENT_REMINDERS_NAME,
        description: NotificationChannels.PERSISTENT_REMINDERS_DESC,
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        playSound: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(exerciseChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(persistentChannel);
    }
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      
      // Navigate to Todo page with session data
      Get.toNamed('/todo', parameters: {'sessionId': payload});
    }
  }

  // Schedule next notification based on user settings
  Future<void> scheduleNextNotification() async {
    try {
      final settings = await _databaseService.getUserSettings();
      if (settings == null || !settings.isNotificationEnabled) {
        print('Notifications disabled or no settings found');
        return;
      }

      final nextTime = _calculateNextNotificationTime(settings);
      if (nextTime == null) {
        print('No valid time found for next notification');
        return;
      }

      // Create notification session
      final session = await _createNotificationSession(settings, nextTime);
      await _databaseService.saveNotificationSession(session);

      // Schedule the notification
      await _scheduleNotificationAtTime(nextTime, session);
      
      // Update settings with next notification time
      final updatedSettings = settings.copyWith(
        nextNotificationTime: nextTime,
        lastNotificationTime: DateTime.now(),
      );
      await _databaseService.saveUserSettings(updatedSettings);

      print('Next notification scheduled for: $nextTime');
    } catch (e) {
      print('Error scheduling next notification: $e');
    }
  }

  DateTime? _calculateNextNotificationTime(UserSettings settings) {
    final now = DateTime.now();
    var nextTime = now.add(Duration(minutes: settings.intervalMinutes));

    // Check if it's within working hours and working day
    for (int i = 0; i < 7; i++) { // Check next 7 days
      if (settings.isWorkDay(nextTime) && settings.isInWorkTime(nextTime)) {
        // Check if it's not in break time
        if (!settings.isInBreakTime(nextTime)) {
          return nextTime;
        }
      }
      
      // Move to next interval
      nextTime = nextTime.add(Duration(minutes: settings.intervalMinutes));
    }

    return null; // No valid time found in next 7 days
  }

  Future<NotificationSession> _createNotificationSession(
    UserSettings settings,
    DateTime scheduledTime,
  ) async {
    // Randomly select pain point and treatments
    final selectedData = await _randomService.selectRandomTreatments(
      settings.selectedPainPointIds,
    );

    return NotificationSession(
      id: _uuid.v4(),
      scheduledTime: scheduledTime,
      selectedPainPointId: selectedData['painPointId']!,
      selectedTreatmentIds: selectedData['treatmentIds']!.cast<String>(),
      status: NotificationStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _scheduleNotificationAtTime(
    DateTime scheduledTime,
    NotificationSession session,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      NotificationChannels.EXERCISE_REMINDERS,
      NotificationChannels.EXERCISE_REMINDERS_NAME,
      channelDescription: NotificationChannels.EXERCISE_REMINDERS_DESC,
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      ongoing: true, // Make it persistent
      autoCancel: false,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Get pain point name for notification title
    final painPointName = await _randomService.getPainPointName(
      session.selectedPainPointId,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      AppConstants.EXERCISE_REMINDER_ID,
      '⏰ ถึงเวลาดูแล: $painPointName',
      'มาออกกำลังกายกันเถอะ! แตะเพื่อเริ่มต้น',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      payload: session.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Snooze current notification
  Future<void> snoozeNotification(String sessionId, int minutesToSnooze) async {
    try {
      final session = await _databaseService.getNotificationSession(sessionId);
      if (session == null || !session.canSnooze) {
        print('Cannot snooze this notification');
        return;
      }

      final snoozeTime = DateTime.now().add(Duration(minutes: minutesToSnooze));
      
      // Update session status
      final updatedSession = session.copyWith(
        status: NotificationStatus.snoozed,
        snoozeCount: session.snoozeCount + 1,
        lastSnoozedAt: DateTime.now(),
        scheduledTime: snoozeTime,
      );

      await _databaseService.saveNotificationSession(updatedSession);

      // Cancel current notification
      await cancelNotification();

      // Schedule snoozed notification
      await _scheduleNotificationAtTime(snoozeTime, updatedSession);

      print('Notification snoozed for $minutesToSnooze minutes');
    } catch (e) {
      print('Error snoozing notification: $e');
    }
  }

  // Complete notification session
  Future<void> completeNotificationSession(String sessionId) async {
    try {
      final session = await _databaseService.getNotificationSession(sessionId);
      if (session == null) return;

      final completedSession = session.copyWith(
        status: NotificationStatus.completed,
        completedAt: DateTime.now(),
      );

      await _databaseService.saveNotificationSession(completedSession);
      await cancelNotification();

      // Schedule next notification
      await scheduleNextNotification();

      print('Notification session completed');
    } catch (e) {
      print('Error completing notification session: $e');
    }
  }

  // Skip notification session
  Future<void> skipNotificationSession(String sessionId) async {
    try {
      final session = await _databaseService.getNotificationSession(sessionId);
      if (session == null) return;

      final skippedSession = session.copyWith(
        status: NotificationStatus.skipped,
        skippedAt: DateTime.now(),
      );

      await _databaseService.saveNotificationSession(skippedSession);
      await cancelNotification();

      // Schedule next notification
      await scheduleNextNotification();

      print('Notification session skipped');
    } catch (e) {
      print('Error skipping notification session: $e');
    }
  }

  // Cancel current notification
  Future<void> cancelNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(
      AppConstants.EXERCISE_REMINDER_ID,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Check if notification permissions are granted
  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await iosImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  // Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.requestNotificationsPermission() ??
          false;
    } else if (Platform.isIOS) {
      final iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await iosImplementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Debug: Show immediate test notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test channel for debugging',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      999,
      'Test Notification',
      'This is a test notification for Office Syndrome Helper',
      notificationDetails,
      payload: 'test',
    );
  }
}
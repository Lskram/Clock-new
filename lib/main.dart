import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'app.dart';
import 'models/pain_point.dart';
import 'models/treatment.dart';
import 'models/user_settings.dart';
import 'models/notification_session.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';
import 'controllers/app_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/statistics_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize Hive
  await _initializeHive();

  // Initialize services
  await _initializeServices();

  // Initialize controllers
  _initializeControllers();

  runApp(const OfficesyndromeHelperApp());
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(PainPointAdapter());
  Hive.registerAdapter(TreatmentAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(NotificationSessionAdapter());
  Hive.registerAdapter(NotificationStatusAdapter());
  Hive.registerAdapter(BreakTimeAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
}

Future<void> _initializeServices() async {
  // Initialize database service first
  await Get.putAsync(() => DatabaseService().init());

  // Initialize other services
  await Get.putAsync(() => NotificationService().init());
  await Get.putAsync(() => PermissionService().init());

  // Initialize Android Alarm Manager (Android only)
  if (GetPlatform.isAndroid) {
    try {
      await AndroidAlarmManager.initialize();
    } catch (e) {
      print('Failed to initialize Android Alarm Manager: $e');
    }
  }
}

void _initializeControllers() {
  // Initialize controllers with dependencies
  Get.put(AppController());
  Get.put(NotificationController());
  Get.put(SettingsController());
  Get.put(StatisticsController());
}

// Callback function สำหรับ alarm manager
@pragma('vm:entry-point')
void backgroundAlarmCallback() {
  print('Background alarm triggered!');
  // จะเรียก NotificationService เพื่อแสดง notification
}

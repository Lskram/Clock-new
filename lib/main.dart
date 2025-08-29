import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// Import models and their generated adapters
import 'models/pain_point.dart';
import 'models/treatment.dart';
import 'models/user_settings.dart';
import 'models/notification_session.dart';
import 'models/break_time.dart';

// Import services
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/random_service.dart';
import 'services/permission_service.dart';

// Import controllers
import 'controllers/app_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/statistics_controller.dart';

// Import app
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive
    await Hive.initFlutter();

    // Register Hive adapters - แก้ไขปัญหา undefined function
    Hive.registerAdapter(PainPointAdapter()); // Type ID: 0
    Hive.registerAdapter(TreatmentAdapter()); // Type ID: 1
    Hive.registerAdapter(UserSettingsAdapter()); // Type ID: 2
    Hive.registerAdapter(NotificationSessionAdapter()); // Type ID: 3
    Hive.registerAdapter(NotificationStatusAdapter()); // Type ID: 4
    Hive.registerAdapter(BreakTimeAdapter()); // Type ID: 5
    Hive.registerAdapter(TimeOfDayAdapter()); // Type ID: 6

    print('Hive adapters registered successfully');

    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize Android Alarm Manager (Android only)
    await AndroidAlarmManager.initialize();

    print('All services initialized');
  } catch (e) {
    print('Error during initialization: $e');
  }

  // Initialize services and controllers
  await _initializeServices();

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  // Initialize database service first
  final databaseService = DatabaseService();
  await databaseService.initialize();
  Get.put(databaseService, permanent: true);

  // Initialize other services
  Get.put(NotificationService(), permanent: true);
  Get.put(RandomService(), permanent: true);
  Get.put(PermissionService(), permanent: true);

  // Initialize controllers
  Get.put(AppController(), permanent: true);
  Get.put(NotificationController(), permanent: true);
  Get.put(SettingsController(), permanent: true); // แก้ไขปัญหา undefined
  Get.put(StatisticsController(), permanent: true);

  print('All services and controllers initialized');
}

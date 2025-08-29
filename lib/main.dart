import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Models and Adapters
import 'models/hive_adapters.dart';

// Services
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';

// Controllers
import 'controllers/app_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/statistics_controller.dart';
import 'controllers/settings_controller.dart';

// App
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive
    await Hive.initFlutter();

    // Register all Hive Adapters using the centralized helper
    HiveAdapters.registerAll();

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize services
    await _initializeServices();

    // Set system UI
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    print('App initialization completed successfully');
  } catch (e) {
    debugPrint('Error during app initialization: $e');
  }

  runApp(MyApp());

  print('App started');
}

Future<void> _initializeServices() async {
  try {
    // Initialize and register services
    final settingsController = SettingsController();
    Get.put<SettingsController>(settingsController, permanent: true);

    final databaseService = DatabaseService();
    await databaseService.initialize();
    Get.put<DatabaseService>(databaseService, permanent: true);

    final permissionService = PermissionService();
    Get.put<PermissionService>(permissionService, permanent: true);

    final notificationService = NotificationService();
    await notificationService.initialize();
    Get.put<NotificationService>(notificationService, permanent: true);

    // Initialize controllers
    Get.put<AppController>(AppController(), permanent: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
    Get.put<StatisticsController>(StatisticsController(), permanent: true);
  } catch (e) {
    debugPrint('Error initializing services: $e');
    rethrow;
  }
}

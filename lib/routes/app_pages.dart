import 'package:get/get.dart';
import 'package:office_syndrome_helper/controllers/settings_page.dart';

import 'app_routes.dart';
import '../pages/splash_page.dart';
import '../pages/questionnaire_page.dart';
import '../pages/home_page.dart';
import '../pages/todo_page.dart';
import '../controllers/app_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/statistics_controller.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    // Splash Page
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AppController>(() => AppController());
      }),
    ),

    // Questionnaire Page (First time setup)
    GetPage(
      name: AppRoutes.QUESTIONNAIRE,
      page: () => const QuestionnairePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),

    // Home Page
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AppController>(() => AppController());
        Get.lazyPut<NotificationController>(() => NotificationController());
        Get.lazyPut<SettingsController>(() => SettingsController());
        Get.lazyPut<StatisticsController>(() => StatisticsController());
      }),
    ),

    // Todo Page (Exercise session)
    GetPage(
      name: AppRoutes.TODO,
      page: () => const TodoPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificationController>(() => NotificationController());
      }),
    ),

    // Settings Page
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),

    // Statistics Page
    GetPage(
      name: AppRoutes.STATISTICS,
      page: () => const StatisticsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StatisticsController>(() => StatisticsController());
      }),
    ),
  ];
}

// Custom transition animations
class AppTransitions {
  static Transition fadeIn = Transition.fadeIn;
  static Transition slideUp = Transition.downToUp;
  static Transition slideRight = Transition.rightToLeft;
  static Transition slideLeft = Transition.leftToRight;

  static Duration duration = const Duration(milliseconds: 300);
}

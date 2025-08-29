import 'package:get/get.dart';
import '../pages/splash_page.dart';
import '../pages/questionnaire_page.dart';
import '../pages/home_page.dart';
import '../pages/todo_page.dart';
import '../pages/settings_page.dart';
// import '../pages/statistics_page.dart'; // จะสร้างในภายหลัง
import '../controllers/settings_controller.dart';
import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.splash;

  static final routes = [
    // Splash Page
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),

    // Questionnaire Page
    GetPage(
      name: AppRoutes.questionnaire,
      page: () => const QuestionnairePage(),
    ),

    // Home Page
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),

    // Todo/Exercise Page
    GetPage(
      name: AppRoutes.todo,
      page: () => const TodoPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),

    // Settings Page
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),

    // Statistics Page - สร้าง placeholder สำหรับตอนนี้
    GetPage(
      name: AppRoutes.statistics,
      page: () => const StatisticsPlaceholderPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
    ),

    // Settings Sub-pages
    GetPage(
      name: AppRoutes.settingsNotification,
      page: () => const NotificationSettingsPage(),
    ),

    GetPage(
      name: AppRoutes.settingsPainPoints,
      page: () => const PainPointsSettingsPage(),
    ),

    GetPage(
      name: AppRoutes.settingsTreatments,
      page: () => const TreatmentsSettingsPage(),
    ),

    GetPage(
      name: AppRoutes.settingsBreakTimes,
      page: () => const BreakTimesSettingsPage(),
    ),

    // Treatment Pages - สร้าง placeholder
    GetPage(
      name: AppRoutes.treatmentDetail,
      page: () => const TreatmentDetailPlaceholderPage(),
    ),

    GetPage(
      name: AppRoutes.treatmentAdd,
      page: () => const TreatmentAddPlaceholderPage(),
    ),

    GetPage(
      name: AppRoutes.treatmentEdit,
      page: () => const TreatmentEditPlaceholderPage(),
    ),

    // Statistics Sub-pages - สร้าง placeholder
    GetPage(
      name: AppRoutes.statisticsDaily,
      page: () => const DailyStatisticsPlaceholderPage(),
    ),

    GetPage(
      name: AppRoutes.statisticsWeekly,
      page: () => const WeeklyStatisticsPlaceholderPage(),
    ),

    GetPage(
      name: AppRoutes.statisticsMonthly,
      page: () => const MonthlyStatisticsPlaceholderPage(),
    ),
  ];
}

// Placeholder Pages - จะสร้างเพิ่มเติมในภายหลัง

class StatisticsPlaceholderPage extends StatelessWidget {
  const StatisticsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สถิติ'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'หน้าสถิติกำลังพัฒนา',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การตั้งค่าการแจ้งเตือน'),
      ),
      body: const Center(
        child: Text('การตั้งค่าการแจ้งเตือน'),
      ),
    );
  }
}

class PainPointsSettingsPage extends StatelessWidget {
  const PainPointsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จุดปวดเมื่อย'),
      ),
      body: const Center(
        child: Text('การตั้งค่าจุดปวดเมื่อย'),
      ),
    );
  }
}

class TreatmentsSettingsPage extends StatelessWidget {
  const TreatmentsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ท่าการออกกำลัง'),
      ),
      body: const Center(
        child: Text('การตั้งค่าท่าการออกกำลัง'),
      ),
    );
  }
}

class BreakTimesSettingsPage extends StatelessWidget {
  const BreakTimesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เวลาพัก'),
      ),
      body: const Center(
        child: Text('การตั้งค่าเวลาพัก'),
      ),
    );
  }
}

class TreatmentDetailPlaceholderPage extends StatelessWidget {
  const TreatmentDetailPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดท่า'),
      ),
      body: const Center(
        child: Text('รายละเอียดท่าการออกกำลัง'),
      ),
    );
  }
}

class TreatmentAddPlaceholderPage extends StatelessWidget {
  const TreatmentAddPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มท่าใหม่'),
      ),
      body: const Center(
        child: Text('เพิ่มท่าการออกกำลัง'),
      ),
    );
  }
}

class TreatmentEditPlaceholderPage extends StatelessWidget {
  const TreatmentEditPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขท่า'),
      ),
      body: const Center(
        child: Text('แก้ไขท่าการออกกำลัง'),
      ),
    );
  }
}

class DailyStatisticsPlaceholderPage extends StatelessWidget {
  const DailyStatisticsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สถิติรายวัน'),
      ),
      body: const Center(
        child: Text('สถิติรายวัน'),
      ),
    );
  }
}

class WeeklyStatisticsPlaceholderPage extends StatelessWidget {
  const WeeklyStatisticsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สถิติรายสัปดาห์'),
      ),
      body: const Center(
        child: Text('สถิติรายสัปดาห์'),
      ),
    );
  }
}

class MonthlyStatisticsPlaceholderPage extends StatelessWidget {
  const MonthlyStatisticsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สถิติรายเดือน'),
      ),
      body: const Center(
        child: Text('สถิติรายเดือน'),
      ),
    );
  }
}

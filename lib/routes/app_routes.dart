abstract class AppRoutes {
  // Main Routes
  static const String SPLASH = '/splash';
  static const String QUESTIONNAIRE = '/questionnaire';
  static const String HOME = '/home';
  static const String TODO = '/todo';
  static const String SETTINGS = '/settings';
  static const String STATISTICS = '/statistics';

  // Settings Sub-routes
  static const String SETTINGS_NOTIFICATION = '/settings/notification';
  static const String SETTINGS_PAIN_POINTS = '/settings/pain-points';
  static const String SETTINGS_TREATMENTS = '/settings/treatments';
  static const String SETTINGS_BREAK_TIMES = '/settings/break-times';

  // Treatment Routes
  static const String TREATMENT_DETAIL = '/treatment/detail';
  static const String TREATMENT_ADD = '/treatment/add';
  static const String TREATMENT_EDIT = '/treatment/edit';

  // Statistics Sub-routes
  static const String STATISTICS_DAILY = '/statistics/daily';
  static const String STATISTICS_WEEKLY = '/statistics/weekly';
  static const String STATISTICS_MONTHLY = '/statistics/monthly';
}

class AppRouteNames {
  static const Map<String, String> names = {
    AppRoutes.SPLASH: 'Splash',
    AppRoutes.QUESTIONNAIRE: 'Questionnaire',
    AppRoutes.HOME: 'Home',
    AppRoutes.TODO: 'Todo',
    AppRoutes.SETTINGS: 'Settings',
    AppRoutes.STATISTICS: 'Statistics',
    AppRoutes.SETTINGS_NOTIFICATION: 'Notification Settings',
    AppRoutes.SETTINGS_PAIN_POINTS: 'Pain Points Settings',
    AppRoutes.SETTINGS_TREATMENTS: 'Treatments Settings',
    AppRoutes.SETTINGS_BREAK_TIMES: 'Break Times Settings',
    AppRoutes.TREATMENT_DETAIL: 'Treatment Detail',
    AppRoutes.TREATMENT_ADD: 'Add Treatment',
    AppRoutes.TREATMENT_EDIT: 'Edit Treatment',
    AppRoutes.STATISTICS_DAILY: 'Daily Statistics',
    AppRoutes.STATISTICS_WEEKLY: 'Weekly Statistics',
    AppRoutes.STATISTICS_MONTHLY: 'Monthly Statistics',
  };

  static String getName(String route) {
    return names[route] ?? 'Unknown';
  }
}

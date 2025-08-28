class AppConstants {
  // App Information
  static const String APP_NAME = 'Office Syndrome Helper';
  static const String APP_VERSION = '1.0.0';

  // Pain Points Configuration
  static const int MAX_SELECTED_PAIN_POINTS = 3;
  static const int MIN_SELECTED_PAIN_POINTS = 1;

  // Notification Configuration
  static const int DEFAULT_INTERVAL_MINUTES = 60;
  static const int MIN_INTERVAL_MINUTES = 15;
  static const int MAX_INTERVAL_MINUTES = 240;

  // Snooze Configuration
  static const int DEFAULT_MAX_SNOOZE_COUNT = 3;
  static const List<int> DEFAULT_SNOOZE_INTERVALS = [5, 15, 30]; // minutes

  // Working Time Configuration
  static const int DEFAULT_WORK_START_HOUR = 9;
  static const int DEFAULT_WORK_START_MINUTE = 0;
  static const int DEFAULT_WORK_END_HOUR = 18;
  static const int DEFAULT_WORK_END_MINUTE = 0;
  static const List<int> DEFAULT_WORK_DAYS = [1, 2, 3, 4, 5]; // Mon-Fri

  // Treatment Configuration
  static const int DEFAULT_TREATMENTS_PER_SESSION = 2;
  static const int MIN_TREATMENT_DURATION = 10; // seconds
  static const int MAX_TREATMENT_DURATION = 180; // seconds

  // Statistics Configuration
  static const int STATISTICS_KEEP_DAYS = 90;
  static const int CLEANUP_OLD_SESSIONS_DAYS = 30;

  // UI Configuration
  static const double DEFAULT_BORDER_RADIUS = 12.0;
  static const double DEFAULT_PADDING = 16.0;
  static const double DEFAULT_MARGIN = 8.0;

  // Animation Durations
  static const int SPLASH_ANIMATION_DURATION = 2000; // milliseconds
  static const int PAGE_TRANSITION_DURATION = 300; // milliseconds
  static const int CARD_ANIMATION_DURATION = 200; // milliseconds

  // Notification IDs
  static const int EXERCISE_REMINDER_ID = 1000;
  static const int PERSISTENT_NOTIFICATION_ID = 1001;

  // File Paths
  static const String ASSETS_IMAGES = 'assets/images/';
  static const String ASSETS_ICONS = 'assets/icons/';
  static const String ASSETS_SOUNDS = 'assets/sounds/';
}

class HiveBoxes {
  static const String SETTINGS = 'settings';
  static const String TREATMENTS = 'treatments';
  static const String SESSIONS = 'sessions';
}

class HiveKeys {
  static const String USER_SETTINGS = 'user_settings';
}

class NotificationChannels {
  // Android Notification Channels
  static const String EXERCISE_REMINDERS = 'exercise_reminders';
  static const String PERSISTENT_REMINDERS = 'persistent_reminders';

  static const String EXERCISE_REMINDERS_NAME = 'การแจ้งเตือนออกกำลังกาย';
  static const String EXERCISE_REMINDERS_DESC =
      'แจ้งเตือนเมื่อถึงเวลาออกกำลังกาย';

  static const String PERSISTENT_REMINDERS_NAME = 'การแจ้งเตือนต่อเนื่อง';
  static const String PERSISTENT_REMINDERS_DESC =
      'การแจ้งเตือนที่จะแสดงต่อเนื่องจนกว่าจะทำเสร็จ';
}

class DateFormats {
  static const String DISPLAY_DATE = 'dd/MM/yyyy';
  static const String DISPLAY_TIME = 'HH:mm';
  static const String DISPLAY_DATETIME = 'dd/MM/yyyy HH:mm';
  static const String API_DATETIME = 'yyyy-MM-ddTHH:mm:ss.SSSZ';
}

class ValidationRules {
  static const int MIN_TREATMENT_NAME_LENGTH = 3;
  static const int MAX_TREATMENT_NAME_LENGTH = 50;
  static const int MIN_TREATMENT_DESCRIPTION_LENGTH = 10;
  static const int MAX_TREATMENT_DESCRIPTION_LENGTH = 200;
}

class DefaultBreakTimes {
  // ช่วงเวลาพักมาตรฐาน
  static const Map<String, Map<String, int>> LUNCH_BREAK = {
    'name': {'th': 'พักกลางวัน'},
    'start': {'hour': 12, 'minute': 0},
    'end': {'hour': 13, 'minute': 30},
  };

  static const Map<String, Map<String, int>> AFTERNOON_BREAK = {
    'name': {'th': 'พักบ่าย'},
    'start': {'hour': 15, 'minute': 0},
    'end': {'hour': 15, 'minute': 15},
  };
}

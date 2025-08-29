// App Constants
const String appName = 'Office Syndrome Helper';
const String appVersion = '1.0.0';

// Pain Point Settings
const int maxSelectedPainPoints = 5;
const int minSelectedPainPoints = 1;

// Notification Settings
const int defaultIntervalMinutes = 60;
const int minIntervalMinutes = 15;
const int maxIntervalMinutes = 240;

// Snooze Settings
const int defaultMaxSnoozeCount = 3;
const List<int> defaultSnoozeIntervals = [5, 10, 15];

// Work Time Defaults
const int defaultWorkStartHour = 9;
const int defaultWorkStartMinute = 0;
const int defaultWorkEndHour = 17;
const int defaultWorkEndMinute = 0;
const List<int> defaultWorkDays = [1, 2, 3, 4, 5]; // Monday to Friday

// Session Settings
const int defaultTreatmentsPerSession = 3;
const int minTreatmentDuration = 15; // seconds
const int maxTreatmentDuration = 300; // seconds

// Database Settings
const int statisticsKeepDays = 90;
const int cleanupOldSessionsDays = 30;

// UI Constants
const double defaultBorderRadius = 8.0;
const double defaultPadding = 16.0;
const double defaultMargin = 8.0;

// Animation Durations
const int splashAnimationDuration = 2000; // milliseconds
const int pageTransitionDuration = 300;
const int cardAnimationDuration = 200;

// Notification IDs
const int exerciseReminderId = 1000;
const int persistentNotificationId = 1001;

// Asset Paths
const String assetsImages = 'assets/images/';
const String assetsIcons = 'assets/icons/';
const String assetsSounds = 'assets/sounds/';

// Hive Box Names
const String settingsBox = 'settings';
const String treatmentsBox = 'treatments';
const String sessionsBox = 'sessions';

// Notification Channels
const String userSettingsChannel = 'user_settings';

// Notification Channel Details
const String exerciseRemindersChannel = 'exercise_reminders';
const String persistentRemindersChannel = 'persistent_reminders';

const String exerciseRemindersName = 'Exercise Reminders';
const String exerciseRemindersDesc = 'Notifications for exercise breaks';

const String persistentRemindersName = 'Persistent Reminders';
const String persistentRemindersDesc = 'Always visible exercise reminders';

// Date Time Formats
const String displayDateFormat = 'dd/MM/yyyy';
const String displayTimeFormat = 'HH:mm';
const String displayDatetimeFormat = 'dd/MM/yyyy HH:mm';
const String apiDatetimeFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

// Validation Constants
const int minTreatmentNameLength = 2;
const int maxTreatmentNameLength = 50;
const int minTreatmentDescriptionLength = 10;
const int maxTreatmentDescriptionLength = 200;

// Default Break Times (Key-Value pairs with proper types)
const Map<String, Map<String, int>> defaultBreakTimes = {
  'lunchBreak': {
    'startHour': 12,
    'startMinute': 0,
    'endHour': 13,
    'endMinute': 0,
  },
  'afternoonBreak': {
    'startHour': 15,
    'startMinute': 0,
    'endHour': 15,
    'endMinute': 15,
  },
};

// Day Names (Thai)
const List<String> dayNamesShort = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
const List<String> dayNamesLong = [
  'วันจันทร์',
  'วันอังคาร',
  'วันพุธ',
  'วันพฤหัสบดี',
  'วันศุกร์',
  'วันเสาร์',
  'วันอาทิตย์',
];

// Categories
const List<String> painPointCategories = [
  'คอและไหล่',
  'หลัง',
  'ตา',
  'แขนและมือ',
  'ขาและเท้า',
  'อื่นๆ',
];

const List<String> treatmentCategories = [
  'การยืด',
  'การออกกำลัง',
  'การนวด',
  'การผ่อนคลาย',
  'การหายใจ',
];

// Error Messages
const String errorNetworkConnection = 'ไม่สามารถเชื่อมต่อเครือข่ายได้';
const String errorDataNotFound = 'ไม่พบข้อมูล';
const String errorPermissionDenied = 'ไม่ได้รับอนุญาต';
const String errorInvalidInput = 'ข้อมูลไม่ถูกต้อง';

// Success Messages
const String successDataSaved = 'บันทึกข้อมูลสำเร็จ';
const String successDataUpdated = 'อัปเดตข้อมูลสำเร็จ';
const String successDataDeleted = 'ลบข้อมูลสำเร็จ';

// Theme Colors (Material Design)
const int primaryColorValue = 0xFF2E7D32; // Green 800
const int secondaryColorValue = 0xFF4CAF50; // Green 500
const int accentColorValue = 0xFF8BC34A; // Light Green 500

import 'package:flutter/material.dart';

// App Information
const String appName = 'Office Syndrome Helper';
const String appVersion = '1.0.0';

// Pain Points Configuration
const int maxSelectedPainPoints = 3;
const int minSelectedPainPoints = 1;

// Notification Settings
const int defaultIntervalMinutes = 60;
const int minIntervalMinutes = 30;
const int maxIntervalMinutes = 240;

// Session Settings
const int defaultMaxSnoozeCount = 3;
const List<int> defaultSnoozeIntervals = [5, 10, 15];

// Work Hours Default
const int defaultWorkStartHour = 9;
const int defaultWorkStartMinute = 0;
const int defaultWorkEndHour = 17;
const int defaultWorkEndMinute = 0;
const List<int> defaultWorkDays = [1, 2, 3, 4, 5]; // Monday to Friday

// Treatment Configuration
const int defaultTreatmentsPerSession = 3;
const int minTreatmentDuration = 30; // seconds
const int maxTreatmentDuration = 300; // seconds

// Database Configuration
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
const String assetsImages = 'assets/images';
const String assetsIcons = 'assets/icons';
const String assetsSounds = 'assets/sounds';

// Hive Box Names
const String settings = 'settings';
const String treatments = 'treatments';
const String sessions = 'sessions';

// Notification Channel IDs
const String userSettings = 'user_settings';

// Notification Channels
const String exerciseReminders = 'exercise_reminders';
const String persistentReminders = 'persistent_reminders';

const String exerciseRemindersName = 'การแจ้งเตือนออกกำลัง';
const String exerciseRemindersDesc = 'แจ้งเตือนให้ออกกำลังกายตามเวลาที่กำหนด';

const String persistentRemindersName = 'การแจ้งเตือนถาวร';
const String persistentRemindersDesc = 'การแจ้งเตือนที่แสดงอยู่เสมอ';

// Date Format Patterns
const String displayDate = 'dd/MM/yyyy';
const String displayTime = 'HH:mm';
const String displayDateTime = 'dd/MM/yyyy HH:mm';
const String apiDateTime = 'yyyy-MM-ddTHH:mm:ssZ';

// Validation Constants
const int minTreatmentNameLength = 3;
const int maxTreatmentNameLength = 100;
const int minTreatmentDescriptionLength = 10;
const int maxTreatmentDescriptionLength = 500;

// Break Times Configuration - แก้ไข type error
const Map<String, int> lunchBreak = {
  'name': 'พักกลางวัน', // แก้จาก String เป็น int สำหรับ key 'name'
  'startHour': 12,
  'startMinute': 0,
  'endHour': 13,
  'endMinute': 0,
};

const Map<String, int> afternoonBreak = {
  'name': 'พักบ่าย',
  'startHour': 15,
  'startMinute': 0,
  'endHour': 15,
  'endMinute': 15,
};

// Default Break Times (แก้ไขให้ใช้ Map ที่ถูกต้อง)
const List<Map<String, dynamic>> defaultBreakTimes = [
  {
    'id': 'lunch',
    'name': 'พักกลางวัน',
    'startHour': 12,
    'startMinute': 0,
    'endHour': 13,
    'endMinute': 0,
    'isEnabled': true,
  },
  {
    'id': 'afternoon',
    'name': 'พักบ่าย',
    'startHour': 15,
    'startMinute': 0,
    'endHour': 15,
    'endMinute': 15,
    'isEnabled': true,
  },
];

// Error Messages
const String errorNoInternetConnection = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';
const String errorServerConnection = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
const String errorDatabaseConnection = 'ไม่สามารถเชื่อมต่อฐานข้อมูลได้';
const String errorPermissionDenied = 'ไม่ได้รับอนุญาติ';
const String errorInvalidData = 'ข้อมูลไม่ถูกต้อง';

// Success Messages
const String successDataSaved = 'บันทึกข้อมูลสำเร็จ';
const String successSettingsUpdated = 'อัพเดตการตั้งค่าสำเร็จ';
const String successNotificationScheduled = 'ตั้งเวลาการแจ้งเตือนสำเร็จ';

// Default Pain Points
const List<Map<String, dynamic>> defaultPainPoints = [
  {
    'id': 'neck',
    'name': 'คอ',
    'description': 'ปวดคอ เมื่อยคอ จากการนั่งทำงานนาน',
    'iconData': Icons.accessibility_new,
    'color': Colors.red,
  },
  {
    'id': 'shoulder',
    'name': 'ไหล่',
    'description': 'ปวดไหล่ เมื่อยไหล่ จากท่าทางการทำงาน',
    'iconData': Icons.accessibility,
    'color': Colors.orange,
  },
  {
    'id': 'back',
    'name': 'หลัง',
    'description': 'ปวดหลัง เมื่อยหลัง จากการนั่งงานเป็นเวลานาน',
    'iconData': Icons.airline_seat_recline_normal,
    'color': Colors.blue,
  },
  {
    'id': 'wrist',
    'name': 'ข้อมือ',
    'description': 'ปวดข้อมือ เมื่อยข้อมือ จากการใช้เมาส์และแป้นพิมพ์',
    'iconData': Icons.pan_tool,
    'color': Colors.green,
  },
  {
    'id': 'eyes',
    'name': 'ดวงตา',
    'description': 'เมื่อยตา แห้งตา จากการมองหน้าจอคอมพิวเตอร์',
    'iconData': Icons.visibility,
    'color': Colors.purple,
  },
  {
    'id': 'legs',
    'name': 'ขา',
    'description': 'เมื่อยขา ขาบวม จากการนั่งติดต่อกัน',
    'iconData': Icons.directions_walk,
    'color': Colors.teal,
  },
];

// Default Treatments
const List<Map<String, dynamic>> defaultTreatments = [
  {
    'id': 'neck_stretch',
    'name': 'ยืดกล้ามเนื้อคอ',
    'description': 'หันหน้าไปซ้าย-ขวา และเอียงคอซ้าย-ขวา เบา ๆ',
    'duration': 60,
    'difficulty': 1,
    'targetPainPoints': ['neck'],
    'steps': [
      'นั่งหรือยืนตัวตรง',
      'หันหน้าไปทางซ้าย ค้างไว้ 10 วินาที',
      'หันหน้าไปทางขวา ค้างไว้ 10 วินาที',
      'เอียงคอไปทางซ้าย ค้างไว้ 10 วินาที',
      'เอียงคอไปทางขวา ค้างไว้ 10 วินาที',
    ],
    'imageUrl': null,
  },
  {
    'id': 'shoulder_roll',
    'name': 'หมุนไหล่',
    'description': 'หมุนไหล่เป็นวงกลม เพื่อคลายความเมื่อยล้า',
    'duration': 45,
    'difficulty': 1,
    'targetPainPoints': ['shoulder', 'neck'],
    'steps': [
      'ยืดแขนทั้งสองข้างออกจากลำตัว',
      'หมุนไหล่ไปข้างหน้า 10 รอบ',
      'หมุนไหล่ไปข้างหลัง 10 รอบ',
      'ยกไหล่ขึ้น ค้างไว้ 5 วินาที แล้วปล่อย',
    ],
    'imageUrl': null,
  },
  {
    'id': 'back_stretch',
    'name': 'ยืดหลัง',
    'description': 'ยืดกล้ามเนื้อหลังเพื่อบรรเทาอาการปวดหลัง',
    'duration': 90,
    'difficulty': 2,
    'targetPainPoints': ['back'],
    'steps': [
      'นั่งตัวตรง แล้วยกแขนทั้งสองข้างขึ้น',
      'โน้มตัวไปข้างซ้าย ค้างไว้ 15 วินาที',
      'โน้มตัวไปข้างขวา ค้างไว้ 15 วินาที',
      'หมุนลำตัวไปทางซ้าย ค้างไว้ 10 วินาที',
      'หมุนลำตัวไปทางขวา ค้างไว้ 10 วินาที',
    ],
    'imageUrl': null,
  },
  {
    'id': 'wrist_stretch',
    'name': 'ยืดข้อมือ',
    'description': 'ยืดกล้ามเนื้อข้อมือและนิ้วมือ',
    'duration': 60,
    'difficulty': 1,
    'targetPainPoints': ['wrist'],
    'steps': [
      'เหยียดแขนข้างหนึ่งไปข้างหน้า',
      'ใช้มืออีกข้างกดฝ่ามือลง ค้างไว้ 15 วินาที',
      'กดหลังมือขึ้น ค้างไว้ 15 วินาที',
      'หมุนข้อมือ 10 รอบ',
      'ทำซ้ำกับมืออีกข้าง',
    ],
    'imageUrl': null,
  },
  {
    'id': 'eye_exercise',
    'name': 'ออกกำลังดวงตา',
    'description': 'ผ่อนคลายดวงตาจากการมองหน้าจอ',
    'duration': 45,
    'difficulty': 1,
    'targetPainPoints': ['eyes'],
    'steps': [
      'ปิดตาแน่น 5 วินาที แล้วลืมตา',
      'มองขึ้น-ลง 10 ครั้ง',
      'มองซ้าย-ขวา 10 ครั้ง',
      'หมุนลูกตา 5 รอบ',
      'กะพริบตาเร็ว ๆ 20 ครั้ง',
    ],
    'imageUrl': null,
  },
  {
    'id': 'leg_stretch',
    'name': 'ยืดขา',
    'description': 'ยืดกล้ามเนื้อขาเพื่ออคพาหความเมื่อยล้า',
    'duration': 75,
    'difficulty': 2,
    'targetPainPoints': ['legs'],
    'steps': [
      'ยืนขึ้นจากเก้าอี้',
      'ยกเข่าซ้ายขึ้น ค้างไว้ 10 วินาที',
      'ยกเข่าขวาขึ้น ค้างไว้ 10 วินาที',
      'เหยียดขาข้างหนึ่งไปข้างหลัง ค้างไว้ 15 วินาที',
      'เปลี่ยนข้างและทำซ้ำ',
    ],
    'imageUrl': null,
  },
];

// App Colors
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);

  static const Color accent = Color(0xFF4CAF50);
  static const Color accentLight = Color(0xFFC8E6C9);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
}

// App Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );
}

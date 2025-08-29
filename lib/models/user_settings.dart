import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class UserSettings extends HiveObject {
  @HiveField(0)
  bool notificationsEnabled;
  
  @HiveField(1)
  int notificationIntervalMinutes;
  
  @HiveField(2)
  TimeOfDay workStartTime;
  
  @HiveField(3)
  TimeOfDay workEndTime;
  
  @HiveField(4)
  List<int> workDays; // 1=Monday, 7=Sunday
  
  @HiveField(5)
  List<String> selectedPainPoints;
  
  @HiveField(6)
  int treatmentsPerSession;
  
  @HiveField(7)
  int maxSnoozeCount;
  
  @HiveField(8)
  List<int> snoozeIntervals; // in minutes
  
  @HiveField(9)
  ThemeMode themeMode;
  
  @HiveField(10)
  String language;
  
  @HiveField(11)
  bool soundEnabled;
  
  @HiveField(12)
  bool vibrationEnabled;
  
  @HiveField(13)
  double volume;

  UserSettings({
    this.notificationsEnabled = true,
    this.notificationIntervalMinutes = 60,
    required this.workStartTime,
    required this.workEndTime,
    required this.workDays,
    this.selectedPainPoints = const [],
    this.treatmentsPerSession = 3,
    this.maxSnoozeCount = 3,
    this.snoozeIntervals = const [5, 10, 15],
    this.themeMode = ThemeMode.system,
    this.language = 'th',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.volume = 0.8,
  });

  factory UserSettings.defaultSettings() {
    return UserSettings(
      workStartTime: const TimeOfDay(hour: 9, minute: 0),
      workEndTime: const TimeOfDay(hour: 17, minute: 0),
      workDays: [1, 2, 3, 4, 5], // Monday to Friday
    );
  }

  UserSettings copyWith({
    bool? notificationsEnabled,
    int? notificationIntervalMinutes,
    TimeOfDay? workStartTime,
    TimeOfDay? workEndTime,
    List<int>? workDays,
    List<String>? selectedPainPoints,
    int? treatmentsPerSession,
    int? maxSnoozeCount,
    List<int>? snoozeIntervals,
    ThemeMode? themeMode,
    String? language,
    bool? soundEnabled,
    bool? vibrationEnabled,
    double? volume,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationIntervalMinutes: notificationIntervalMinutes ?? this.notificationIntervalMinutes,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      workDays: workDays ?? List.from(this.workDays),
      selectedPainPoints: selectedPainPoints ?? List.from(this.selectedPainPoints),
      treatmentsPerSession: treatmentsPerSession ?? this.treatmentsPerSession,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      snoozeIntervals: snoozeIntervals ?? List.from(this.snoozeIntervals),
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'notificationIntervalMinutes': notificationIntervalMinutes,
      'workStartTime': {
        'hour': workStartTime.hour,
        'minute': workStartTime.minute,
      },
      'workEndTime': {
        'hour': workEndTime.hour,
        'minute': workEndTime.minute,
      },
      'workDays': workDays,
      'selectedPainPoints': selectedPainPoints,
      'treatmentsPerSession': treatmentsPerSession,
      'maxSnoozeCount': maxSnoozeCount,
      'snoozeIntervals': snoozeIntervals,
      'themeMode': themeMode.index,
      'language': language,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'volume': volume,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      notificationIntervalMinutes: json['notificationIntervalMinutes'] ?? 60,
      workStartTime: TimeOfDay(
        hour: json['workStartTime']['hour'] ?? 9,
        minute: json['workStartTime']['minute'] ?? 0,
      ),
      workEndTime: TimeOfDay(
        hour: json['workEndTime']['hour'] ?? 17,
        minute: json['workEndTime']['minute'] ?? 0,
      ),
      workDays: List<int>.from(json['workDays'] ?? [1, 2, 3, 4, 5]),
      selectedPainPoints: List<String>.from(json['selectedPainPoints'] ?? []),
      treatmentsPerSession: json['treatmentsPerSession'] ?? 3,
      maxSnoozeCount: json['maxSnoozeCount'] ?? 3,
      snoozeIntervals: List<int>.from(json['snoozeIntervals'] ?? [5, 10, 15]),
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      language: json['language'] ?? 'th',
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      volume: json['volume']?.toDouble() ?? 0.8,
    );
  }

  bool get hasSelectedPainPoints => selectedPainPoints.isNotEmpty;

  bool isWorkDay(DateTime date) {
    return workDays.contains(date.weekday);
  }

  bool isWorkTime(TimeOfDay time) {
    final timeInMinutes = time.hour * 60 + time.minute;
    final startInMinutes = workStartTime.hour * 60 + workStartTime.minute;
    final endInMinutes = workEndTime.hour * 60 + workEndTime.minute;
    
    return timeInMinutes >= startInMinutes && timeInMinutes <= endInMinutes;
  }

  @override
  String toString() {
    return 'UserSettings('
        'notificationsEnabled: $notificationsEnabled, '
        'notificationIntervalMinutes: $notificationIntervalMinutes, '
        'workStartTime: ${workStartTime.hour}:${workStartTime.minute}, '
        'workEndTime: ${workEndTime.hour}:${workEndTime.minute}, '
        'workDays: $workDays, '
        'selectedPainPoints: ${selectedPainPoints.length}, '
        'treatmentsPerSession: $treatmentsPerSession, '
        'maxSnoozeCount: $maxSnoozeCount, '
        'language: $language)';
  }
}

// Custom TimeOfDay Adapter for Hive
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 6;

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readInt();
    final minute = reader.readInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
  }
}
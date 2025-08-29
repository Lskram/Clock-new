import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'break_time.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 2)
class UserSettings extends HiveObject {
  @HiveField(0)
  bool isNotificationEnabled;

  @HiveField(1)
  int intervalMinutes;

  @HiveField(2)
  int treatmentsPerSession;

  @HiveField(3)
  int maxSnoozeCount;

  @HiveField(4)
  List<int> snoozeIntervals;

  @HiveField(5)
  TimeOfDay workStartTime;

  @HiveField(6)
  TimeOfDay workEndTime;

  @HiveField(7)
  List<int> workDays;

  @HiveField(8)
  List<String> selectedPainPoints;

  @HiveField(9)
  List<BreakTime> breakTimes;

  @HiveField(10)
  DateTime? lastNotificationTime;

  @HiveField(11)
  bool isFirstLaunch;

  @HiveField(12)
  String? userId;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  UserSettings({
    this.isNotificationEnabled = true,
    this.intervalMinutes = 60,
    this.treatmentsPerSession = 3,
    this.maxSnoozeCount = 3,
    this.snoozeIntervals = const [5, 10, 15],
    required this.workStartTime,
    required this.workEndTime,
    this.workDays = const [1, 2, 3, 4, 5], // Mon-Fri
    this.selectedPainPoints = const [],
    this.breakTimes = const [],
    this.lastNotificationTime,
    this.isFirstLaunch = true,
    this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Factory method for creating default settings - แก้ไข TimeOfDay constructor
  factory UserSettings.createDefault() {
    return UserSettings(
      isNotificationEnabled: true,
      intervalMinutes: 60,
      treatmentsPerSession: 3,
      maxSnoozeCount: 3,
      snoozeIntervals: const [5, 10, 15],
      workStartTime:
          const TimeOfDay(hour: 9, minute: 0), // ลบ const จาก constructor
      workEndTime: const TimeOfDay(hour: 17, minute: 0),
      workDays: const [1, 2, 3, 4, 5], // Monday to Friday
      selectedPainPoints: const [],
      breakTimes: BreakTime.getDefaultBreakTimes(),
      isFirstLaunch: true,
    );
  }

  // Copy with method
  UserSettings copyWith({
    bool? isNotificationEnabled,
    int? intervalMinutes,
    int? treatmentsPerSession,
    int? maxSnoozeCount,
    List<int>? snoozeIntervals,
    TimeOfDay? workStartTime,
    TimeOfDay? workEndTime,
    List<int>? workDays,
    List<String>? selectedPainPoints,
    List<BreakTime>? breakTimes,
    DateTime? lastNotificationTime,
    bool? isFirstLaunch,
    String? userId,
  }) {
    return UserSettings(
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      treatmentsPerSession: treatmentsPerSession ?? this.treatmentsPerSession,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      snoozeIntervals: snoozeIntervals ?? this.snoozeIntervals,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      workDays: workDays ?? this.workDays,
      selectedPainPoints: selectedPainPoints ?? this.selectedPainPoints,
      breakTimes: breakTimes ?? this.breakTimes,
      lastNotificationTime: lastNotificationTime ?? this.lastNotificationTime,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      userId: userId ?? this.userId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Validation methods
  bool get isValid {
    return intervalMinutes > 0 &&
        treatmentsPerSession > 0 &&
        selectedPainPoints.isNotEmpty && // แก้ไข isEmpty เป็น isNotEmpty
        workDays.isNotEmpty &&
        maxSnoozeCount >= 0;
  }

  bool get hasValidWorkHours {
    final startMinutes = workStartTime.hour * 60 + workStartTime.minute;
    final endMinutes = workEndTime.hour * 60 + workEndTime.minute;
    return endMinutes > startMinutes;
  }

  bool get hasSelectedPainPoints {
    return selectedPainPoints.isNotEmpty;
  }

  // Helper methods
  bool isWorkingDay(int weekday) {
    return workDays.contains(weekday);
  }

  bool isWithinWorkHours(TimeOfDay time) {
    if (!hasValidWorkHours) return false;

    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = workStartTime.hour * 60 + workStartTime.minute;
    final endMinutes = workEndTime.hour * 60 + workEndTime.minute;

    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  Duration get workDuration {
    if (!hasValidWorkHours) return Duration.zero;

    final startMinutes = workStartTime.hour * 60 + workStartTime.minute;
    final endMinutes = workEndTime.hour * 60 + workEndTime.minute;

    return Duration(minutes: endMinutes - startMinutes);
  }

  int get estimatedNotificationsPerDay {
    if (!hasValidWorkHours || intervalMinutes <= 0) return 0;

    final workMinutes = workDuration.inMinutes;
    return (workMinutes / intervalMinutes).floor();
  }

  // Update methods
  void updateLastNotificationTime() {
    lastNotificationTime = DateTime.now();
    updatedAt = DateTime.now();
    save(); // Save to Hive
  }

  void markAsUsed() {
    if (isFirstLaunch) {
      isFirstLaunch = false;
      updatedAt = DateTime.now();
      save();
    }
  }

  void addPainPoint(String painPointId) {
    if (!selectedPainPoints.contains(painPointId)) {
      selectedPainPoints.add(painPointId);
      updatedAt = DateTime.now();
      save();
    }
  }

  void removePainPoint(String painPointId) {
    if (selectedPainPoints.remove(painPointId)) {
      updatedAt = DateTime.now();
      save();
    }
  }

  void addBreakTime(BreakTime breakTime) {
    breakTimes.add(breakTime);
    updatedAt = DateTime.now();
    save();
  }

  void removeBreakTime(String breakTimeId) {
    breakTimes.removeWhere((bt) => bt.id == breakTimeId);
    updatedAt = DateTime.now();
    save();
  }

  // Convert to/from JSON for backup/restore
  Map<String, dynamic> toJson() {
    return {
      'isNotificationEnabled': isNotificationEnabled,
      'intervalMinutes': intervalMinutes,
      'treatmentsPerSession': treatmentsPerSession,
      'maxSnoozeCount': maxSnoozeCount,
      'snoozeIntervals': snoozeIntervals,
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
      'breakTimes': breakTimes.map((bt) => bt.toJson()).toList(),
      'lastNotificationTime': lastNotificationTime?.toIso8601String(),
      'isFirstLaunch': isFirstLaunch,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      isNotificationEnabled: json['isNotificationEnabled'] ?? true,
      intervalMinutes: json['intervalMinutes'] ?? 60,
      treatmentsPerSession: json['treatmentsPerSession'] ?? 3,
      maxSnoozeCount: json['maxSnoozeCount'] ?? 3,
      snoozeIntervals: List<int>.from(json['snoozeIntervals'] ?? [5, 10, 15]),
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
      breakTimes: (json['breakTimes'] as List?)
              ?.map((bt) => BreakTime.fromJson(bt))
              .toList() ??
          [],
      lastNotificationTime: json['lastNotificationTime'] != null
          ? DateTime.parse(json['lastNotificationTime'])
          : null,
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      userId: json['userId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'UserSettings('
        'isNotificationEnabled: $isNotificationEnabled, '
        'intervalMinutes: $intervalMinutes, '
        'treatmentsPerSession: $treatmentsPerSession, '
        'selectedPainPoints: ${selectedPainPoints.length} items, '
        'workHours: ${workStartTime.format(null)} - ${workEndTime.format(null)}'
        ')';
  }
}

// Hive adapter for TimeOfDay
@HiveType(typeId: 6)
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 6;

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readByte();
    final minute = reader.readByte();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeByte(obj.hour);
    writer.writeByte(obj.minute);
  }
}

import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class UserSettings extends HiveObject {
  @HiveField(0)
  List<int> selectedPainPointIds;

  @HiveField(1)
  bool isNotificationEnabled;

  @HiveField(2)
  int intervalMinutes;

  @HiveField(3)
  TimeOfDay workStartTime;

  @HiveField(4)
  TimeOfDay workEndTime;

  @HiveField(5)
  List<int> workDays; // 1-7 (จันทร์-อาทิตย์)

  @HiveField(6)
  List<BreakTime> breakTimes;

  @HiveField(7)
  bool isSoundEnabled;

  @HiveField(8)
  bool isVibrationEnabled;

  @HiveField(9)
  int maxSnoozeCount;

  @HiveField(10)
  List<int> snoozeIntervals; // นาที [5, 15, 30]

  @HiveField(11)
  bool isFirstTimeSetup;

  @HiveField(12)
  DateTime? lastNotificationTime;

  @HiveField(13)
  DateTime? nextNotificationTime;

  UserSettings({
    this.selectedPainPointIds = const [],
    this.isNotificationEnabled = true,
    this.intervalMinutes = 60,
    this.workStartTime = const TimeOfDay(hour: 9, minute: 0),
    this.workEndTime = const TimeOfDay(hour: 18, minute: 0),
    this.workDays = const [1, 2, 3, 4, 5], // จ-ศ
    this.breakTimes = const [],
    this.isSoundEnabled = true,
    this.isVibrationEnabled = true,
    this.maxSnoozeCount = 3,
    this.snoozeIntervals = const [5, 15, 30],
    this.isFirstTimeSetup = true,
    this.lastNotificationTime,
    this.nextNotificationTime,
  });

  UserSettings copyWith({
    List<int>? selectedPainPointIds,
    bool? isNotificationEnabled,
    int? intervalMinutes,
    TimeOfDay? workStartTime,
    TimeOfDay? workEndTime,
    List<int>? workDays,
    List<BreakTime>? breakTimes,
    bool? isSoundEnabled,
    bool? isVibrationEnabled,
    int? maxSnoozeCount,
    List<int>? snoozeIntervals,
    bool? isFirstTimeSetup,
    DateTime? lastNotificationTime,
    DateTime? nextNotificationTime,
  }) {
    return UserSettings(
      selectedPainPointIds: selectedPainPointIds ?? this.selectedPainPointIds,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      workDays: workDays ?? this.workDays,
      breakTimes: breakTimes ?? this.breakTimes,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      snoozeIntervals: snoozeIntervals ?? this.snoozeIntervals,
      isFirstTimeSetup: isFirstTimeSetup ?? this.isFirstTimeSetup,
      lastNotificationTime: lastNotificationTime ?? this.lastNotificationTime,
      nextNotificationTime: nextNotificationTime ?? this.nextNotificationTime,
    );
  }

  bool get hasSelectedPainPoints => selectedPainPointIds.length >= 1;
  bool get hasValidWorkTime => workStartTime.hour < workEndTime.hour;
  bool get isSetupComplete => !isFirstTimeSetup && hasSelectedPainPoints;

  Duration get intervalDuration => Duration(minutes: intervalMinutes);

  bool isWorkDay(DateTime date) {
    return workDays.contains(date.weekday);
  }

  bool isInWorkTime(DateTime time) {
    final timeOfDay = TimeOfDay.fromDateTime(time);
    return _isTimeAfterOrEqual(timeOfDay, workStartTime) &&
        _isTimeBefore(timeOfDay, workEndTime);
  }

  bool isInBreakTime(DateTime time) {
    final timeOfDay = TimeOfDay.fromDateTime(time);
    return breakTimes.any((breakTime) => breakTime.contains(timeOfDay));
  }

  bool _isTimeAfterOrEqual(TimeOfDay time, TimeOfDay reference) {
    return time.hour > reference.hour ||
        (time.hour == reference.hour && time.minute >= reference.minute);
  }

  bool _isTimeBefore(TimeOfDay time, TimeOfDay reference) {
    return time.hour < reference.hour ||
        (time.hour == reference.hour && time.minute < reference.minute);
  }
}

@HiveType(typeId: 5)
class BreakTime extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final TimeOfDay startTime;

  @HiveField(2)
  final TimeOfDay endTime;

  @HiveField(3)
  final bool isEnabled;

  BreakTime({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isEnabled = true,
  });

  BreakTime copyWith({
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isEnabled,
  }) {
    return BreakTime(
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  bool contains(TimeOfDay time) {
    if (!isEnabled) return false;

    return _isTimeAfterOrEqual(time, startTime) && _isTimeBefore(time, endTime);
  }

  Duration get duration {
    final start = Duration(hours: startTime.hour, minutes: startTime.minute);
    final end = Duration(hours: endTime.hour, minutes: endTime.minute);
    return end - start;
  }

  bool _isTimeAfterOrEqual(TimeOfDay time, TimeOfDay reference) {
    return time.hour > reference.hour ||
        (time.hour == reference.hour && time.minute >= reference.minute);
  }

  bool _isTimeBefore(TimeOfDay time, TimeOfDay reference) {
    return time.hour < reference.hour ||
        (time.hour == reference.hour && time.minute < reference.minute);
  }
}

@HiveType(typeId: 6)
class TimeOfDay extends HiveObject {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  factory TimeOfDay.now() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get displayTime {
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour < 12 ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDay &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

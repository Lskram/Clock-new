import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../utils/constants.dart';

part 'break_time.g.dart';

@HiveType(typeId: 5)
class BreakTime extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  TimeOfDay startTime;

  @HiveField(4)
  TimeOfDay endTime;

  @HiveField(5)
  bool isEnabled;

  @HiveField(6)
  List<int> weekdays; // 1-7 (Monday to Sunday)

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  BreakTime({
    required this.id,
    required this.name,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isEnabled = true,
    this.weekdays = const [1, 2, 3, 4, 5], // Monday to Friday
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Factory method for creating default break times
  static List<BreakTime> getDefaultBreakTimes() {
    return [
      BreakTime(
        id: 'lunch',
        name: 'พักกลางวัน',
        description: 'พักกลางวันสำหรับรับประทานอาหาร',
        startTime: const TimeOfDay(hour: 12, minute: 0),
        endTime: const TimeOfDay(hour: 13, minute: 0),
        isEnabled: true,
        weekdays: const [1, 2, 3, 4, 5], // Monday to Friday
      ),
      BreakTime(
        id: 'afternoon',
        name: 'พักบ่าย',
        description: 'พักช่วงบ่ายสำหรับผ่อนคลาย',
        startTime: const TimeOfDay(hour: 15, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 15),
        isEnabled: true,
        weekdays: const [1, 2, 3, 4, 5],
      ),
    ];
  }

  // Copy with method
  BreakTime copyWith({
    String? id,
    String? name,
    String? description,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isEnabled,
    List<int>? weekdays,
  }) {
    return BreakTime(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isEnabled: isEnabled ?? this.isEnabled,
      weekdays: weekdays ?? List<int>.from(this.weekdays),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Check if current time is within this break time
  bool isTimeInRange(TimeOfDay currentTime) {
    if (!isEnabled) return false;

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  // Check if break time is active today
  bool isActiveToday() {
    final today = DateTime.now().weekday;
    return isEnabled && weekdays.contains(today);
  }

  // Check if break time is active on specific weekday
  bool isActiveOnWeekday(int weekday) {
    return isEnabled && weekdays.contains(weekday);
  }

  // Get duration of break time in minutes
  int get durationInMinutes {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes - startMinutes;
  }

  // Get duration as Duration object
  Duration get duration {
    return Duration(minutes: durationInMinutes);
  }

  // Check if break time is valid (end time after start time)
  bool get isValid {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes > startMinutes && weekdays.isNotEmpty;
  }

  // Format time range as string
  String get timeRangeString {
    final startFormatted = startTime.format(null);
    final endFormatted = endTime.format(null);
    return '$startFormatted - $endFormatted';
  }

  // Get weekdays as string
  String get weekdaysString {
    const weekdayNames = {
      1: 'จ',
      2: 'อ',
      3: 'พ',
      4: 'พฤ',
      5: 'ศ',
      6: 'ส',
      7: 'อา',
    };

    if (weekdays.length == 7) {
      return 'ทุกวัน';
    } else if (weekdays.length == 5 &&
        weekdays.contains(1) &&
        weekdays.contains(2) &&
        weekdays.contains(3) &&
        weekdays.contains(4) &&
        weekdays.contains(5)) {
      return 'จันทร์-ศุกร์';
    } else if (weekdays.length == 2 &&
        weekdays.contains(6) &&
        weekdays.contains(7)) {
      return 'เสาร์-อาทิตย์';
    } else {
      return weekdays.map((day) => weekdayNames[day] ?? '').join(', ');
    }
  }

  // Enable/disable break time
  void enable() {
    isEnabled = true;
    updatedAt = DateTime.now();
    save();
  }

  void disable() {
    isEnabled = false;
    updatedAt = DateTime.now();
    save();
  }

  // Update break time
  void updateTime(TimeOfDay newStartTime, TimeOfDay newEndTime) {
    startTime = newStartTime;
    endTime = newEndTime;
    updatedAt = DateTime.now();
    save();
  }

  void updateWeekdays(List<int> newWeekdays) {
    weekdays = List<int>.from(newWeekdays);
    updatedAt = DateTime.now();
    save();
  }

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'isEnabled': isEnabled,
      'weekdays': weekdays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BreakTime.fromJson(Map<String, dynamic> json) {
    return BreakTime(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      isEnabled: json['isEnabled'] ?? true,
      weekdays: List<int>.from(json['weekdays'] ?? [1, 2, 3, 4, 5]),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreakTime &&
        other.id == id &&
        other.name == name &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, startTime, endTime, isEnabled);
  }

  @override
  String toString() {
    return 'BreakTime('
        'id: $id, '
        'name: $name, '
        'time: $timeRangeString, '
        'isEnabled: $isEnabled, '
        'weekdays: $weekdaysString'
        ')';
  }
}

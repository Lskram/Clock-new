import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 5)
class BreakTime extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  TimeOfDay startTime;

  @HiveField(3)
  TimeOfDay endTime;

  @HiveField(4)
  bool isEnabled;

  @HiveField(5)
  bool blockNotifications;

  @HiveField(6)
  List<int> activeDays; // 1=Monday, 7=Sunday

  BreakTime({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.isEnabled = true,
    this.blockNotifications = true,
    this.activeDays = const [1, 2, 3, 4, 5],
  });

  factory BreakTime.create({
    required String name,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    bool isEnabled = true,
    bool blockNotifications = true,
    List<int>? activeDays,
  }) {
    final id = 'break_${DateTime.now().millisecondsSinceEpoch}';
    return BreakTime(
      id: id,
      name: name,
      startTime: startTime,
      endTime: endTime,
      isEnabled: isEnabled,
      blockNotifications: blockNotifications,
      activeDays: activeDays ?? [1, 2, 3, 4, 5],
    );
  }

  BreakTime copyWith({
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isEnabled,
    bool? blockNotifications,
    List<int>? activeDays,
  }) {
    return BreakTime(
      id: id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isEnabled: isEnabled ?? this.isEnabled,
      blockNotifications: blockNotifications ?? this.blockNotifications,
      activeDays: activeDays ?? List.from(this.activeDays),
    );
  }

  bool isActiveToday() {
    final today = DateTime.now().weekday;
    return isEnabled && activeDays.contains(today);
  }

  bool isCurrentlyActive() {
    if (!isActiveToday()) return false;

    final now = TimeOfDay.now();
    final nowInMinutes = now.hour * 60 + now.minute;
    final startInMinutes = startTime.hour * 60 + startTime.minute;
    final endInMinutes = endTime.hour * 60 + endTime.minute;

    if (startInMinutes <= endInMinutes) {
      // Same day break
      return nowInMinutes >= startInMinutes && nowInMinutes <= endInMinutes;
    } else {
      // Overnight break
      return nowInMinutes >= startInMinutes || nowInMinutes <= endInMinutes;
    }
  }

  Duration get duration {
    final startInMinutes = startTime.hour * 60 + startTime.minute;
    final endInMinutes = endTime.hour * 60 + endTime.minute;

    int durationInMinutes;
    if (startInMinutes <= endInMinutes) {
      durationInMinutes = endInMinutes - startInMinutes;
    } else {
      // Overnight break
      durationInMinutes = (24 * 60 - startInMinutes) + endInMinutes;
    }

    return Duration(minutes: durationInMinutes);
  }

  String get formattedDuration {
    final dur = duration;
    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;

    if (hours > 0) {
      return '${hours}ชั่วโมง ${minutes}นาที';
    }
    return '${minutes}นาที';
  }

  String get formattedTime {
    return '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'isEnabled': isEnabled,
      'blockNotifications': blockNotifications,
      'activeDays': activeDays,
    };
  }

  factory BreakTime.fromJson(Map<String, dynamic> json) {
    return BreakTime(
      id: json['id'],
      name: json['name'],
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
      isEnabled: json['isEnabled'] ?? true,
      blockNotifications: json['blockNotifications'] ?? true,
      activeDays: List<int>.from(json['activeDays'] ?? [1, 2, 3, 4, 5]),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreakTime && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BreakTime(id: $id, name: $name, time: $formattedTime, enabled: $isEnabled)';
  }

  // Static method to create default break times
  static List<BreakTime> getDefaultBreakTimes() {
    return [
      BreakTime(
        id: 'lunch_break',
        name: 'พักเที่ยง',
        startTime: const TimeOfDay(hour: 12, minute: 0),
        endTime: const TimeOfDay(hour: 13, minute: 0),
        isEnabled: true,
        blockNotifications: true,
        activeDays: [1, 2, 3, 4, 5],
      ),
      BreakTime(
        id: 'afternoon_break',
        name: 'พักบ่าย',
        startTime: const TimeOfDay(hour: 15, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 15),
        isEnabled: false,
        blockNotifications: true,
        activeDays: [1, 2, 3, 4, 5],
      ),
    ];
  }
}

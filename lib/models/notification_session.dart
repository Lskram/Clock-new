import 'package:hive/hive.dart';

part 'notification_session.g.dart';

@HiveType(typeId: 2)
class NotificationSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime scheduledTime;

  @HiveField(2)
  final int selectedPainPointId;

  @HiveField(3)
  final List<String> selectedTreatmentIds;

  @HiveField(4)
  final NotificationStatus status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? completedAt;

  @HiveField(7)
  final DateTime? skippedAt;

  @HiveField(8)
  final int snoozeCount;

  @HiveField(9)
  final DateTime? lastSnoozedAt;

  NotificationSession({
    required this.id,
    required this.scheduledTime,
    required this.selectedPainPointId,
    required this.selectedTreatmentIds,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.skippedAt,
    this.snoozeCount = 0,
    this.lastSnoozedAt,
  });

  NotificationSession copyWith({
    String? id,
    DateTime? scheduledTime,
    int? selectedPainPointId,
    List<String>? selectedTreatmentIds,
    NotificationStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? skippedAt,
    int? snoozeCount,
    DateTime? lastSnoozedAt,
  }) {
    return NotificationSession(
      id: id ?? this.id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      selectedPainPointId: selectedPainPointId ?? this.selectedPainPointId,
      selectedTreatmentIds: selectedTreatmentIds ?? this.selectedTreatmentIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      skippedAt: skippedAt ?? this.skippedAt,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      lastSnoozedAt: lastSnoozedAt ?? this.lastSnoozedAt,
    );
  }

  bool get isCompleted => status == NotificationStatus.completed;
  bool get isSkipped => status == NotificationStatus.skipped;
  bool get isPending => status == NotificationStatus.pending;
  bool get isSnoozed => status == NotificationStatus.snoozed;

  bool get canSnooze => snoozeCount < 3 && status == NotificationStatus.pending;

  Duration get totalDuration {
    int totalSeconds = 0;
    // จะคำนวณจาก selectedTreatmentIds ใน service
    return Duration(seconds: totalSeconds);
  }
}

@HiveType(typeId: 3)
enum NotificationStatus {
  @HiveField(0)
  pending, // รอทำ

  @HiveField(1)
  snoozed, // เลื่อนไว้

  @HiveField(2)
  completed, // ทำเสร็จแล้ว

  @HiveField(3)
  skipped, // ข้ามไป

  @HiveField(4)
  expired, // หมดเวลา (ไม่ได้ทำ)
}

extension NotificationStatusExtension on NotificationStatus {
  String get displayName {
    switch (this) {
      case NotificationStatus.pending:
        return 'รอทำ';
      case NotificationStatus.snoozed:
        return 'เลื่อนไว้';
      case NotificationStatus.completed:
        return 'เสร็จแล้ว';
      case NotificationStatus.skipped:
        return 'ข้ามไป';
      case NotificationStatus.expired:
        return 'หมดเวลา';
    }
  }

  String get emoji {
    switch (this) {
      case NotificationStatus.pending:
        return '⏰';
      case NotificationStatus.snoozed:
        return '😴';
      case NotificationStatus.completed:
        return '✅';
      case NotificationStatus.skipped:
        return '⏭️';
      case NotificationStatus.expired:
        return '⏱️';
    }
  }
}

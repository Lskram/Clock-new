import 'package:hive/hive.dart';

@HiveType(typeId: 3)
enum NotificationStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  snoozed,
  @HiveField(3)
  skipped,
  @HiveField(4)
  dismissed,
}

@HiveType(typeId: 4)
class NotificationSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime scheduledTime;

  @HiveField(2)
  DateTime? completedTime;

  @HiveField(3)
  List<String> treatmentIds;

  @HiveField(4)
  List<String> completedTreatmentIds;

  @HiveField(5)
  NotificationStatus status;

  @HiveField(6)
  int snoozeCount;

  @HiveField(7)
  DateTime? lastSnoozeTime;

  @HiveField(8)
  Map<String, dynamic> metadata;

  NotificationSession({
    required this.id,
    required this.scheduledTime,
    this.completedTime,
    this.treatmentIds = const [],
    this.completedTreatmentIds = const [],
    this.status = NotificationStatus.pending,
    this.snoozeCount = 0,
    this.lastSnoozeTime,
    this.metadata = const {},
  });

  factory NotificationSession.create({
    required List<String> treatmentIds,
    required DateTime scheduledTime,
    Map<String, dynamic>? metadata,
  }) {
    final id = 'session_${DateTime.now().millisecondsSinceEpoch}';
    return NotificationSession(
      id: id,
      scheduledTime: scheduledTime,
      treatmentIds: List.from(treatmentIds),
      metadata: metadata ?? {},
    );
  }

  NotificationSession copyWith({
    DateTime? scheduledTime,
    DateTime? completedTime,
    List<String>? treatmentIds,
    List<String>? completedTreatmentIds,
    NotificationStatus? status,
    int? snoozeCount,
    DateTime? lastSnoozeTime,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationSession(
      id: id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completedTime: completedTime ?? this.completedTime,
      treatmentIds: treatmentIds ?? List.from(this.treatmentIds),
      completedTreatmentIds:
          completedTreatmentIds ?? List.from(this.completedTreatmentIds),
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      lastSnoozeTime: lastSnoozeTime ?? this.lastSnoozeTime,
      metadata: metadata ?? Map.from(this.metadata),
    );
  }

  void markAsCompleted() {
    status = NotificationStatus.completed;
    completedTime = DateTime.now();
    save();
  }

  void markAsSkipped() {
    status = NotificationStatus.skipped;
    save();
  }

  void markAsDismissed() {
    status = NotificationStatus.dismissed;
    save();
  }

  void snooze() {
    status = NotificationStatus.snoozed;
    snoozeCount++;
    lastSnoozeTime = DateTime.now();
    save();
  }

  void addCompletedTreatment(String treatmentId) {
    if (!completedTreatmentIds.contains(treatmentId)) {
      completedTreatmentIds.add(treatmentId);
      save();
    }
  }

  bool get isCompleted => status == NotificationStatus.completed;
  bool get isPending => status == NotificationStatus.pending;
  bool get isSnoozed => status == NotificationStatus.snoozed;
  bool get isSkipped => status == NotificationStatus.skipped;
  bool get isDismissed => status == NotificationStatus.dismissed;

  bool get hasAllTreatmentsCompleted {
    return completedTreatmentIds.length == treatmentIds.length &&
        treatmentIds.isNotEmpty;
  }

  double get completionProgress {
    if (treatmentIds.isEmpty) return 0.0;
    return completedTreatmentIds.length / treatmentIds.length;
  }

  Duration get durationSinceScheduled {
    return DateTime.now().difference(scheduledTime);
  }

  Duration? get durationToComplete {
    if (completedTime == null) return null;
    return completedTime!.difference(scheduledTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduledTime': scheduledTime.toIso8601String(),
      'completedTime': completedTime?.toIso8601String(),
      'treatmentIds': treatmentIds,
      'completedTreatmentIds': completedTreatmentIds,
      'status': status.index,
      'snoozeCount': snoozeCount,
      'lastSnoozeTime': lastSnoozeTime?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory NotificationSession.fromJson(Map<String, dynamic> json) {
    return NotificationSession(
      id: json['id'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      completedTime: json['completedTime'] != null
          ? DateTime.parse(json['completedTime'])
          : null,
      treatmentIds: List<String>.from(json['treatmentIds'] ?? []),
      completedTreatmentIds:
          List<String>.from(json['completedTreatmentIds'] ?? []),
      status: NotificationStatus.values[json['status'] ?? 0],
      snoozeCount: json['snoozeCount'] ?? 0,
      lastSnoozeTime: json['lastSnoozeTime'] != null
          ? DateTime.parse(json['lastSnoozeTime'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationSession(id: $id, status: $status, scheduled: $scheduledTime)';
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'pain_point.dart';
import 'treatment.dart';
import 'user_settings.dart';
import 'notification_session.dart';
import 'break_time.dart';

// =============================================================================
// Hive Adapter สำหรับ PainPoint (TypeId: 0)
// =============================================================================
class PainPointAdapter extends TypeAdapter<PainPoint> {
  @override
  final int typeId = 0;

  @override
  PainPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return PainPoint(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      iconPath: fields[4] as String?,
      relatedTreatmentIds: (fields[5] as List?)?.cast<String>() ?? [],
      isDefault: fields[6] as bool? ?? false,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PainPoint obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.iconPath)
      ..writeByte(5)
      ..write(obj.relatedTreatmentIds)
      ..writeByte(6)
      ..write(obj.isDefault)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }
}

// =============================================================================
// Hive Adapter สำหรับ Treatment (TypeId: 1)
// =============================================================================
class TreatmentAdapter extends TypeAdapter<Treatment> {
  @override
  final int typeId = 1;

  @override
  Treatment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Treatment(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      instructions: (fields[3] as List?)?.cast<String>() ?? [],
      durationSeconds: fields[4] as int,
      category: fields[5] as String,
      imagePath: fields[6] as String?,
      videoPath: fields[7] as String?,
      targetPainPoints: (fields[8] as List?)?.cast<String>() ?? [],
      difficulty: fields[9] as int? ?? 1,
      isDefault: fields[10] as bool? ?? false,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      completedCount: fields[13] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Treatment obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.instructions)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.videoPath)
      ..writeByte(8)
      ..write(obj.targetPainPoints)
      ..writeByte(9)
      ..write(obj.difficulty)
      ..writeByte(10)
      ..write(obj.isDefault)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.completedCount);
  }
}

// =============================================================================
// Hive Adapter สำหรับ UserSettings (TypeId: 2)
// =============================================================================
class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return UserSettings(
      notificationsEnabled: fields[0] as bool? ?? true,
      notificationIntervalMinutes: fields[1] as int? ?? 60,
      workStartTime: fields[2] as TimeOfDay,
      workEndTime: fields[3] as TimeOfDay,
      workDays: (fields[4] as List?)?.cast<int>() ?? [1, 2, 3, 4, 5],
      selectedPainPoints: (fields[5] as List?)?.cast<String>() ?? [],
      treatmentsPerSession: fields[6] as int? ?? 3,
      maxSnoozeCount: fields[7] as int? ?? 3,
      snoozeIntervals: (fields[8] as List?)?.cast<int>() ?? [5, 10, 15],
      themeMode: fields[9] as ThemeMode? ?? ThemeMode.system,
      language: fields[10] as String? ?? 'th',
      soundEnabled: fields[11] as bool? ?? true,
      vibrationEnabled: fields[12] as bool? ?? true,
      volume: fields[13] as double? ?? 0.8,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.notificationsEnabled)
      ..writeByte(1)
      ..write(obj.notificationIntervalMinutes)
      ..writeByte(2)
      ..write(obj.workStartTime)
      ..writeByte(3)
      ..write(obj.workEndTime)
      ..writeByte(4)
      ..write(obj.workDays)
      ..writeByte(5)
      ..write(obj.selectedPainPoints)
      ..writeByte(6)
      ..write(obj.treatmentsPerSession)
      ..writeByte(7)
      ..write(obj.maxSnoozeCount)
      ..writeByte(8)
      ..write(obj.snoozeIntervals)
      ..writeByte(9)
      ..write(obj.themeMode)
      ..writeByte(10)
      ..write(obj.language)
      ..writeByte(11)
      ..write(obj.soundEnabled)
      ..writeByte(12)
      ..write(obj.vibrationEnabled)
      ..writeByte(13)
      ..write(obj.volume);
  }
}

// =============================================================================
// Hive Adapter สำหรับ NotificationStatus (TypeId: 3)
// =============================================================================
class NotificationStatusAdapter extends TypeAdapter<NotificationStatus> {
  @override
  final int typeId = 3;

  @override
  NotificationStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return NotificationStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, NotificationStatus obj) {
    writer.writeByte(obj.index);
  }
}

// =============================================================================
// Hive Adapter สำหรับ NotificationSession (TypeId: 4)
// =============================================================================
class NotificationSessionAdapter extends TypeAdapter<NotificationSession> {
  @override
  final int typeId = 4;

  @override
  NotificationSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return NotificationSession(
      id: fields[0] as String,
      scheduledTime: fields[1] as DateTime,
      completedTime: fields[2] as DateTime?,
      treatmentIds: (fields[3] as List?)?.cast<String>() ?? [],
      completedTreatmentIds: (fields[4] as List?)?.cast<String>() ?? [],
      status: fields[5] as NotificationStatus? ?? NotificationStatus.pending,
      snoozeCount: fields[6] as int? ?? 0,
      lastSnoozeTime: fields[7] as DateTime?,
      metadata: Map<String, dynamic>.from(fields[8] as Map? ?? {}),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.scheduledTime)
      ..writeByte(2)
      ..write(obj.completedTime)
      ..writeByte(3)
      ..write(obj.treatmentIds)
      ..writeByte(4)
      ..write(obj.completedTreatmentIds)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.snoozeCount)
      ..writeByte(7)
      ..write(obj.lastSnoozeTime)
      ..writeByte(8)
      ..write(obj.metadata);
  }
}

// =============================================================================
// Hive Adapter สำหรับ BreakTime (TypeId: 5)
// =============================================================================
class BreakTimeAdapter extends TypeAdapter<BreakTime> {
  @override
  final int typeId = 5;

  @override
  BreakTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return BreakTime(
      id: fields[0] as String,
      name: fields[1] as String,
      startTime: fields[2] as TimeOfDay,
      endTime: fields[3] as TimeOfDay,
      isEnabled: fields[4] as bool? ?? true,
      blockNotifications: fields[5] as bool? ?? true,
      activeDays: (fields[6] as List?)?.cast<int>() ?? [1, 2, 3, 4, 5],
    );
  }

  @override
  void write(BinaryWriter writer, BreakTime obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.blockNotifications)
      ..writeByte(6)
      ..write(obj.activeDays);
  }
}

// =============================================================================
// Hive Adapter สำหรับ TimeOfDay (TypeId: 6)
// =============================================================================
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

// =============================================================================
// Hive Adapter สำหรับ ThemeMode (TypeId: 7)
// =============================================================================
class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 7;

  @override
  ThemeMode read(BinaryReader reader) {
    final index = reader.readByte();
    return ThemeMode.values[index];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeByte(obj.index);
  }
}

// =============================================================================
// Helper Class สำหรับการลงทะเบียน Adapters ทั้งหมด
// =============================================================================
class HiveAdapters {
  static void registerAll() {
    // Register adapters only if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PainPointAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TreatmentAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(NotificationStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(NotificationSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(BreakTimeAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(TimeOfDayAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(ThemeModeAdapter());
    }
  }

  static void unregisterAll() {
    // Helper method to unregister all adapters (useful for testing)
    for (int i = 0; i <= 7; i++) {
      if (Hive.isAdapterRegistered(i)) {
        // Note: Hive doesn't provide unregister method
        // This is just a placeholder for documentation
      }
    }
  }

  static List<int> getAllRegisteredTypeIds() {
    return [0, 1, 2, 3, 4, 5, 6, 7];
  }
}

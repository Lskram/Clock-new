import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../models/pain_point.dart';
import '../models/break_time.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class SettingsController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Observable settings
  final Rx<UserSettings> _settings = UserSettings.createDefault().obs;
  UserSettings get settings => _settings.value;

  // Available options
  final RxList<PainPoint> availablePainPoints = <PainPoint>[].obs;
  final RxList<BreakTime> availableBreakTimes = <BreakTime>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      isLoading.value = true;

      // Load current settings
      await loadSettings();

      // Load available options
      availablePainPoints.value = await _databaseService.getAllPainPoints();
      availableBreakTimes.value = await _databaseService.getAllBreakTimes();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load settings from database
  Future<void> loadSettings() async {
    try {
      final savedSettings = await _databaseService.getUserSettings();
      if (savedSettings != null) {
        _settings.value = savedSettings;
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Save settings to database
  Future<bool> saveSettings() async {
    try {
      await _databaseService.saveUserSettings(_settings.value);

      // Reschedule notifications with new settings
      await _notificationService.rescheduleAllNotifications();

      Get.snackbar(
        'สำเร็จ',
        'บันทึกการตั้งค่าเรียบร้อย',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      debugPrint('Error saving settings: $e');
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถบันทึกการตั้งค่าได้',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Update notification settings
  void updateNotificationEnabled(bool enabled) {
    _settings.update((settings) {
      settings?.isNotificationEnabled = enabled;
    });
  }

  void updateIntervalMinutes(int minutes) {
    _settings.update((settings) {
      settings?.intervalMinutes = minutes;
    });
  }

  void updateTreatmentsPerSession(int count) {
    _settings.update((settings) {
      settings?.treatmentsPerSession = count;
    });
  }

  // Update work hours
  void updateWorkStartTime(TimeOfDay time) {
    _settings.update((settings) {
      settings?.workStartTime = time;
    });
  }

  void updateWorkEndTime(TimeOfDay time) {
    _settings.update((settings) {
      settings?.workEndTime = time;
    });
  }

  void updateWorkDays(List<int> days) {
    _settings.update((settings) {
      settings?.workDays = days;
    });
  }

  // Update selected pain points
  void togglePainPoint(String painPointId) {
    _settings.update((settings) {
      if (settings != null) {
        final selectedPainPoints =
            List<String>.from(settings.selectedPainPoints);

        if (selectedPainPoints.contains(painPointId)) {
          selectedPainPoints.remove(painPointId);
        } else {
          selectedPainPoints.add(painPointId);
        }

        settings.selectedPainPoints = selectedPainPoints;
      }
    });
  }

  bool isPainPointSelected(String painPointId) {
    return _settings.value.selectedPainPoints.contains(painPointId);
  }

  // Update break times
  void updateBreakTimes(List<BreakTime> breakTimes) {
    _settings.update((settings) {
      settings?.breakTimes = breakTimes;
    });
  }

  // Reset to default settings
  Future<void> resetToDefault() async {
    try {
      _settings.value = UserSettings.createDefault();
      await saveSettings();

      Get.snackbar(
        'สำเร็จ',
        'รีเซ็ตการตั้งค่าเป็นค่าเริ่มต้นแล้ว',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  // Validation methods
  bool get isValidConfiguration {
    return _settings.value.selectedPainPoints.isNotEmpty &&
        _settings.value.intervalMinutes > 0 &&
        _settings.value.treatmentsPerSession > 0;
  }

  String? get configurationError {
    if (_settings.value.selectedPainPoints.isEmpty) {
      return 'กรุณาเลือกจุดที่ปวดเมื่อยอย่างน้อย 1 จุด';
    }

    if (_settings.value.intervalMinutes <= 0) {
      return 'ช่วงเวลาการแจ้งเตือนต้องมากกว่า 0 นาที';
    }

    if (_settings.value.treatmentsPerSession <= 0) {
      return 'จำนวนท่าต่อครั้งต้องมากกว่า 0';
    }

    return null;
  }
}

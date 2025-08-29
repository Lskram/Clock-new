import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../models/pain_point.dart';
import '../models/treatment.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class SettingsController extends GetxController {
  // Services
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Observable variables
  final Rx<UserSettings> _settings = UserSettings.defaultSettings().obs;
  final RxList<PainPoint> _availablePainPoints = <PainPoint>[].obs;
  final RxList<Treatment> _availableTreatments = <Treatment>[].obs;
  final RxBool _isLoading = false.obs;

  // Getters
  UserSettings get settings => _settings.value;
  List<PainPoint> get availablePainPoints => _availablePainPoints;
  List<Treatment> get availableTreatments => _availableTreatments;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _initializeSettings();
    _loadAvailableData();
  }

  // Initialize settings from database
  Future<void> _initializeSettings() async {
    try {
      _isLoading.value = true;
      final savedSettings = await _databaseService.getUserSettings();
      if (savedSettings != null) {
        _settings.value = savedSettings;
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Load available pain points and treatments
  Future<void> _loadAvailableData() async {
    try {
      _availablePainPoints.value = await _databaseService.getAllPainPoints();
      _availableTreatments.value = await _databaseService.getAllTreatments();
    } catch (e) {
      debugPrint('Error loading available data: $e');
    }
  }

  // Update notification settings
  Future<void> updateNotificationEnabled(bool enabled) async {
    try {
      final newSettings = settings.copyWith(notificationsEnabled: enabled);
      await _saveSettings(newSettings);

      if (enabled) {
        await _notificationService.scheduleRandomNotifications();
      } else {
        await _notificationService.cancelAllNotifications();
      }
    } catch (e) {
      debugPrint('Error updating notification setting: $e');
    }
  }

  // Update notification interval
  Future<void> updateNotificationInterval(int intervalMinutes) async {
    try {
      final newSettings =
          settings.copyWith(notificationIntervalMinutes: intervalMinutes);
      await _saveSettings(newSettings);

      if (settings.notificationsEnabled) {
        await _notificationService.scheduleRandomNotifications();
      }
    } catch (e) {
      debugPrint('Error updating notification interval: $e');
    }
  }

  // Update work hours
  Future<void> updateWorkHours(TimeOfDay startTime, TimeOfDay endTime) async {
    try {
      final newSettings = settings.copyWith(
        workStartTime: startTime,
        workEndTime: endTime,
      );
      await _saveSettings(newSettings);

      if (settings.notificationsEnabled) {
        await _notificationService.scheduleRandomNotifications();
      }
    } catch (e) {
      debugPrint('Error updating work hours: $e');
    }
  }

  // Update work days
  Future<void> updateWorkDays(List<int> workDays) async {
    try {
      final newSettings = settings.copyWith(workDays: workDays);
      await _saveSettings(newSettings);

      if (settings.notificationsEnabled) {
        await _notificationService.scheduleRandomNotifications();
      }
    } catch (e) {
      debugPrint('Error updating work days: $e');
    }
  }

  // Update selected pain points
  Future<void> updateSelectedPainPoints(List<String> painPointIds) async {
    try {
      if (painPointIds.length > maxSelectedPainPoints) {
        Get.snackbar(
          'ข้อจำกัด',
          'สามารถเลือกได้สูงสุด $maxSelectedPainPoints รายการ',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final newSettings = settings.copyWith(selectedPainPoints: painPointIds);
      await _saveSettings(newSettings);
    } catch (e) {
      debugPrint('Error updating selected pain points: $e');
    }
  }

  // Update treatments per session
  Future<void> updateTreatmentsPerSession(int count) async {
    try {
      final newSettings = settings.copyWith(treatmentsPerSession: count);
      await _saveSettings(newSettings);
    } catch (e) {
      debugPrint('Error updating treatments per session: $e');
    }
  }

  // Update max snooze count
  Future<void> updateMaxSnoozeCount(int maxCount) async {
    try {
      final newSettings = settings.copyWith(maxSnoozeCount: maxCount);
      await _saveSettings(newSettings);
    } catch (e) {
      debugPrint('Error updating max snooze count: $e');
    }
  }

  // Update snooze intervals
  Future<void> updateSnoozeIntervals(List<int> intervals) async {
    try {
      final newSettings = settings.copyWith(snoozeIntervals: intervals);
      await _saveSettings(newSettings);
    } catch (e) {
      debugPrint('Error updating snooze intervals: $e');
    }
  }

  // Update theme mode
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      final newSettings = settings.copyWith(themeMode: themeMode);
      await _saveSettings(newSettings);
      Get.changeThemeMode(themeMode);
    } catch (e) {
      debugPrint('Error updating theme mode: $e');
    }
  }

  // Update language
  Future<void> updateLanguage(String languageCode) async {
    try {
      final newSettings = settings.copyWith(language: languageCode);
      await _saveSettings(newSettings);

      final locale = Locale(languageCode);
      await Get.updateLocale(locale);
    } catch (e) {
      debugPrint('Error updating language: $e');
    }
  }

  // Reset settings to default
  Future<void> resetToDefault() async {
    try {
      await Get.dialog(
        AlertDialog(
          title: const Text('รีเซ็ตการตั้งค่า'),
          content: const Text(
              'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตการตั้งค่าทั้งหมดเป็นค่าเริ่มต้น?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await _resetSettings();
              },
              child: const Text('รีเซ็ต'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  // Private method to reset settings
  Future<void> _resetSettings() async {
    try {
      _isLoading.value = true;
      final defaultSettings = UserSettings.defaultSettings();
      await _saveSettings(defaultSettings);

      Get.snackbar(
        'สำเร็จ',
        'รีเซ็ตการตั้งค่าเรียบร้อยแล้ว',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error in reset settings: $e');
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถรีเซ็ตการตั้งค่าได้',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Save settings to database
  Future<void> _saveSettings(UserSettings newSettings) async {
    try {
      await _databaseService.saveUserSettings(newSettings);
      _settings.value = newSettings;
    } catch (e) {
      debugPrint('Error saving settings: $e');
      throw e;
    }
  }

  // Validation methods
  bool isValidWorkTime(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return startMinutes < endMinutes;
  }

  bool isValidNotificationInterval(int intervalMinutes) {
    return intervalMinutes >= minIntervalMinutes &&
        intervalMinutes <= maxIntervalMinutes;
  }

  bool isValidTreatmentsPerSession(int count) {
    return count >= 1 && count <= 10;
  }

  bool isValidMaxSnoozeCount(int count) {
    return count >= 0 && count <= 10;
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return settings.toJson();
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settingsJson) async {
    try {
      final importedSettings = UserSettings.fromJson(settingsJson);
      await _saveSettings(importedSettings);

      Get.snackbar(
        'สำเร็จ',
        'นำเข้าการตั้งค่าเรียบร้อยแล้ว',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error importing settings: $e');
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถนำเข้าการตั้งค่าได้',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

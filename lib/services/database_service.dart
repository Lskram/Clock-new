import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_settings.dart';
import '../models/treatment.dart';
import '../models/notification_session.dart';
import '../utils/constants.dart';

class DatabaseService extends GetxService {
  late Box<UserSettings> _settingsBox;
  late Box<Treatment> _treatmentsBox;
  late Box<NotificationSession> _sessionsBox;

  // Initialize method for GetxService
  Future<DatabaseService> init() async {
    await _openBoxes();
    return this;
  }

  Future<void> _openBoxes() async {
    try {
      _settingsBox = await Hive.openBox<UserSettings>(HiveBoxes.SETTINGS);
      _treatmentsBox = await Hive.openBox<Treatment>(HiveBoxes.TREATMENTS);
      _sessionsBox =
          await Hive.openBox<NotificationSession>(HiveBoxes.SESSIONS);

      print('All Hive boxes opened successfully');
    } catch (e) {
      print('Error opening Hive boxes: $e');
      rethrow;
    }
  }

  // User Settings Methods
  Future<UserSettings?> getUserSettings() async {
    try {
      return _settingsBox.get(HiveKeys.USER_SETTINGS);
    } catch (e) {
      print('Error loading user settings: $e');
      return null;
    }
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    try {
      await _settingsBox.put(HiveKeys.USER_SETTINGS, settings);
      print('User settings saved successfully');
    } catch (e) {
      print('Error saving user settings: $e');
      rethrow;
    }
  }

  // Custom Treatments Methods
  Future<List<Treatment>> getCustomTreatments() async {
    try {
      return _treatmentsBox.values.where((t) => t.isCustom).toList();
    } catch (e) {
      print('Error loading custom treatments: $e');
      return [];
    }
  }

  Future<void> saveCustomTreatment(Treatment treatment) async {
    try {
      await _treatmentsBox.put(treatment.id, treatment);
      print('Custom treatment saved: ${treatment.name}');
    } catch (e) {
      print('Error saving custom treatment: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomTreatment(String treatmentId) async {
    try {
      await _treatmentsBox.delete(treatmentId);
      print('Custom treatment deleted: $treatmentId');
    } catch (e) {
      print('Error deleting custom treatment: $e');
      rethrow;
    }
  }

  Future<Treatment?> getTreatment(String treatmentId) async {
    try {
      return _treatmentsBox.get(treatmentId);
    } catch (e) {
      print('Error loading treatment: $e');
      return null;
    }
  }

  // Notification Sessions Methods
  Future<void> saveNotificationSession(NotificationSession session) async {
    try {
      await _sessionsBox.put(session.id, session);
      print('Notification session saved: ${session.id}');
    } catch (e) {
      print('Error saving notification session: $e');
      rethrow;
    }
  }

  Future<NotificationSession?> getNotificationSession(String sessionId) async {
    try {
      return _sessionsBox.get(sessionId);
    } catch (e) {
      print('Error loading notification session: $e');
      return null;
    }
  }

  Future<List<NotificationSession>> getAllSessions({
    DateTime? startDate,
    DateTime? endDate,
    NotificationStatus? status,
  }) async {
    try {
      var sessions = _sessionsBox.values.toList();

      // Filter by date range
      if (startDate != null) {
        sessions =
            sessions.where((s) => s.scheduledTime.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        sessions =
            sessions.where((s) => s.scheduledTime.isBefore(endDate)).toList();
      }

      // Filter by status
      if (status != null) {
        sessions = sessions.where((s) => s.status == status).toList();
      }

      // Sort by scheduled time (newest first)
      sessions.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      return sessions;
    } catch (e) {
      print('Error loading sessions: $e');
      return [];
    }
  }

  Future<List<NotificationSession>> getTodaySessions() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await getAllSessions(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  Future<List<NotificationSession>> getSessionsInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await getAllSessions(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Statistics Methods
  Future<Map<String, int>> getSessionStatsByStatus(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sessions = await getAllSessions(
        startDate: startDate,
        endDate: endDate,
      );

      final stats = <String, int>{};
      for (final status in NotificationStatus.values) {
        stats[status.name] = sessions.where((s) => s.status == status).length;
      }

      return stats;
    } catch (e) {
      print('Error calculating session stats: $e');
      return {};
    }
  }

  Future<Map<int, int>> getPainPointUsageStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sessions = await getAllSessions(
        startDate: startDate,
        endDate: endDate,
      );

      final stats = <int, int>{};
      for (final session in sessions) {
        final painPointId = session.selectedPainPointId;
        stats[painPointId] = (stats[painPointId] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Error calculating pain point usage stats: $e');
      return {};
    }
  }

  // Cleanup Methods
  Future<void> deleteOldSessions({int keepDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      final oldSessions = _sessionsBox.values
          .where((s) => s.scheduledTime.isBefore(cutoffDate))
          .toList();

      for (final session in oldSessions) {
        await _sessionsBox.delete(session.id);
      }

      print('Deleted ${oldSessions.length} old sessions');
    } catch (e) {
      print('Error deleting old sessions: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _settingsBox.clear();
      await _treatmentsBox.clear();
      await _sessionsBox.clear();

      print('All data cleared successfully');
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }

  // Database info methods
  int get totalSessions => _sessionsBox.length;
  int get totalCustomTreatments =>
      _treatmentsBox.values.where((t) => t.isCustom).length;
  bool get hasUserSettings => _settingsBox.containsKey(HiveKeys.USER_SETTINGS);

  // Close boxes when app terminates
  @override
  void onClose() {
    _settingsBox.close();
    _treatmentsBox.close();
    _sessionsBox.close();
    super.onClose();
  }
}

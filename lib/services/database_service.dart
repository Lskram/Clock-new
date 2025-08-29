import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pain_point.dart';
import '../models/treatment.dart';
import '../models/user_settings.dart';
import '../models/notification_session.dart';
import '../models/break_time.dart';
import '../utils/constants.dart';

class DatabaseService {
  // Box references
  late Box<PainPoint> _painPointsBox;
  late Box<Treatment> _treatmentsBox;
  late Box<UserSettings> _settingsBox;
  late Box<NotificationSession> _sessionsBox;
  late Box<BreakTime> _breakTimesBox;

  // Initialization status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Initialize all Hive boxes
  Future<void> initialize() async {
    try {
      debugPrint('DatabaseService: Initializing...');

      // Open all boxes
      _painPointsBox = await Hive.openBox<PainPoint>('painPoints');
      debugPrint('DatabaseService: PainPoints box opened');

      _treatmentsBox = await Hive.openBox<Treatment>('treatments');
      debugPrint('DatabaseService: Treatments box opened');

      _settingsBox = await Hive.openBox<UserSettings>('userSettings');
      debugPrint('DatabaseService: Settings box opened');

      _sessionsBox = await Hive.openBox<NotificationSession>('sessions');
      debugPrint('DatabaseService: Sessions box opened');

      _breakTimesBox = await Hive.openBox<BreakTime>('breakTimes');
      debugPrint('DatabaseService: BreakTimes box opened');

      // Initialize default data if boxes are empty
      await _initializeDefaultData();

      _isInitialized = true;
      debugPrint('DatabaseService: Initialization completed successfully');
    } catch (e) {
      debugPrint('DatabaseService: Initialization error - $e');
      throw e;
    }
  }

  // Initialize default data if needed
  Future<void> _initializeDefaultData() async {
    try {
      // Initialize default pain points if empty
      if (_painPointsBox.isEmpty) {
        debugPrint('DatabaseService: Adding default pain points');
        final defaultPainPoints = PainPoint.getDefaultPainPoints();
        for (final painPoint in defaultPainPoints) {
          await _painPointsBox.put(painPoint.id, painPoint);
        }
      }

      // Initialize default treatments if empty
      if (_treatmentsBox.isEmpty) {
        debugPrint('DatabaseService: Adding default treatments');
        final defaultTreatments = Treatment.getDefaultTreatments();
        for (final treatment in defaultTreatments) {
          await _treatmentsBox.put(treatment.id, treatment);
        }
      }

      // Initialize default settings if empty
      if (_settingsBox.isEmpty) {
        debugPrint('DatabaseService: Adding default settings');
        final defaultSettings = UserSettings.defaultSettings();
        await _settingsBox.put('default', defaultSettings);
      }

      // Initialize default break times if empty
      if (_breakTimesBox.isEmpty) {
        debugPrint('DatabaseService: Adding default break times');
        final defaultBreakTimes = BreakTime.getDefaultBreakTimes();
        for (final breakTime in defaultBreakTimes) {
          await _breakTimesBox.put(breakTime.id, breakTime);
        }
      }

      debugPrint('DatabaseService: Default data initialization completed');
    } catch (e) {
      debugPrint('DatabaseService: Error initializing default data - $e');
      throw e;
    }
  }

  // ==========================================================================
  // PAIN POINTS METHODS
  // ==========================================================================

  Future<List<PainPoint>> getAllPainPoints() async {
    try {
      return _painPointsBox.values.toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting all pain points - $e');
      return [];
    }
  }

  Future<PainPoint?> getPainPointById(String id) async {
    try {
      return _painPointsBox.get(id);
    } catch (e) {
      debugPrint('DatabaseService: Error getting pain point by id - $e');
      return null;
    }
  }

  Future<void> savePainPoint(PainPoint painPoint) async {
    try {
      await _painPointsBox.put(painPoint.id, painPoint);
      debugPrint('DatabaseService: Pain point saved - ${painPoint.id}');
    } catch (e) {
      debugPrint('DatabaseService: Error saving pain point - $e');
      throw e;
    }
  }

  Future<void> deletePainPoint(String id) async {
    try {
      await _painPointsBox.delete(id);
      debugPrint('DatabaseService: Pain point deleted - $id');
    } catch (e) {
      debugPrint('DatabaseService: Error deleting pain point - $e');
      throw e;
    }
  }

  Future<List<PainPoint>> getPainPointsByCategory(String category) async {
    try {
      return _painPointsBox.values
          .where((painPoint) => painPoint.category == category)
          .toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting pain points by category - $e');
      return [];
    }
  }

  // ==========================================================================
  // TREATMENTS METHODS
  // ==========================================================================

  Future<List<Treatment>> getAllTreatments() async {
    try {
      return _treatmentsBox.values.toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting all treatments - $e');
      return [];
    }
  }

  Future<Treatment?> getTreatmentById(String id) async {
    try {
      return _treatmentsBox.get(id);
    } catch (e) {
      debugPrint('DatabaseService: Error getting treatment by id - $e');
      return null;
    }
  }

  Future<void> saveTreatment(Treatment treatment) async {
    try {
      await _treatmentsBox.put(treatment.id, treatment);
      debugPrint('DatabaseService: Treatment saved - ${treatment.id}');
    } catch (e) {
      debugPrint('DatabaseService: Error saving treatment - $e');
      throw e;
    }
  }

  Future<void> deleteTreatment(String id) async {
    try {
      await _treatmentsBox.delete(id);
      debugPrint('DatabaseService: Treatment deleted - $id');
    } catch (e) {
      debugPrint('DatabaseService: Error deleting treatment - $e');
      throw e;
    }
  }

  Future<List<Treatment>> getTreatmentsByCategory(String category) async {
    try {
      return _treatmentsBox.values
          .where((treatment) => treatment.category == category)
          .toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting treatments by category - $e');
      return [];
    }
  }

  Future<List<Treatment>> getTreatmentsForPainPoints(
      List<String> painPointIds) async {
    try {
      return _treatmentsBox.values
          .where((treatment) => treatment.targetPainPoints
              .any((painPointId) => painPointIds.contains(painPointId)))
          .toList();
    } catch (e) {
      debugPrint(
          'DatabaseService: Error getting treatments for pain points - $e');
      return [];
    }
  }

  // ==========================================================================
  // USER SETTINGS METHODS
  // ==========================================================================

  Future<UserSettings?> getUserSettings() async {
    try {
      return _settingsBox.get('default');
    } catch (e) {
      debugPrint('DatabaseService: Error getting user settings - $e');
      return null;
    }
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    try {
      await _settingsBox.put('default', settings);
      debugPrint('DatabaseService: User settings saved');
    } catch (e) {
      debugPrint('DatabaseService: Error saving user settings - $e');
      throw e;
    }
  }

  Future<void> resetUserSettings() async {
    try {
      await _settingsBox.clear();
      final defaultSettings = UserSettings.defaultSettings();
      await _settingsBox.put('default', defaultSettings);
      debugPrint('DatabaseService: User settings reset to default');
    } catch (e) {
      debugPrint('DatabaseService: Error resetting user settings - $e');
      throw e;
    }
  }

  // ==========================================================================
  // NOTIFICATION SESSIONS METHODS
  // ==========================================================================

  Future<List<NotificationSession>> getAllSessions() async {
    try {
      return _sessionsBox.values.toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting all sessions - $e');
      return [];
    }
  }

  Future<NotificationSession?> getSessionById(String id) async {
    try {
      return _sessionsBox.get(id);
    } catch (e) {
      debugPrint('DatabaseService: Error getting session by id - $e');
      return null;
    }
  }

  Future<void> saveSession(NotificationSession session) async {
    try {
      await _sessionsBox.put(session.id, session);
      debugPrint('DatabaseService: Session saved - ${session.id}');
    } catch (e) {
      debugPrint('DatabaseService: Error saving session - $e');
      throw e;
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      await _sessionsBox.delete(id);
      debugPrint('DatabaseService: Session deleted - $id');
    } catch (e) {
      debugPrint('DatabaseService: Error deleting session - $e');
      throw e;
    }
  }

  Future<List<NotificationSession>> getRecentSessions({int limit = 10}) async {
    try {
      final sessions = _sessionsBox.values.toList();
      sessions.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
      return sessions.take(limit).toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting recent sessions - $e');
      return [];
    }
  }

  Future<List<NotificationSession>> getSessionsByStatus(
      NotificationStatus status) async {
    try {
      return _sessionsBox.values
          .where((session) => session.status == status)
          .toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting sessions by status - $e');
      return [];
    }
  }

  Future<List<NotificationSession>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return _sessionsBox.values
          .where((session) =>
              session.scheduledTime.isAfter(startDate) &&
              session.scheduledTime.isBefore(endDate))
          .toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting sessions by date range - $e');
      return [];
    }
  }

  // ==========================================================================
  // BREAK TIMES METHODS
  // ==========================================================================

  Future<List<BreakTime>> getAllBreakTimes() async {
    try {
      return _breakTimesBox.values.toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting all break times - $e');
      return [];
    }
  }

  Future<BreakTime?> getBreakTimeById(String id) async {
    try {
      return _breakTimesBox.get(id);
    } catch (e) {
      debugPrint('DatabaseService: Error getting break time by id - $e');
      return null;
    }
  }

  Future<void> saveBreakTime(BreakTime breakTime) async {
    try {
      await _breakTimesBox.put(breakTime.id, breakTime);
      debugPrint('DatabaseService: Break time saved - ${breakTime.id}');
    } catch (e) {
      debugPrint('DatabaseService: Error saving break time - $e');
      throw e;
    }
  }

  Future<void> deleteBreakTime(String id) async {
    try {
      await _breakTimesBox.delete(id);
      debugPrint('DatabaseService: Break time deleted - $id');
    } catch (e) {
      debugPrint('DatabaseService: Error deleting break time - $e');
      throw e;
    }
  }

  Future<List<BreakTime>> getActiveBreakTimes() async {
    try {
      return _breakTimesBox.values
          .where((breakTime) => breakTime.isEnabled)
          .toList();
    } catch (e) {
      debugPrint('DatabaseService: Error getting active break times - $e');
      return [];
    }
  }

  Future<BreakTime?> getCurrentActiveBreakTime() async {
    try {
      final activeBreakTimes = await getActiveBreakTimes();
      for (final breakTime in activeBreakTimes) {
        if (breakTime.isCurrentlyActive()) {
          return breakTime;
        }
      }
      return null;
    } catch (e) {
      debugPrint(
          'DatabaseService: Error getting current active break time - $e');
      return null;
    }
  }

  // ==========================================================================
  // STATISTICS AND ANALYTICS METHODS
  // ==========================================================================

  Future<Map<String, int>> getSessionStatsByStatus() async {
    try {
      final sessions = await getAllSessions();
      final stats = <String, int>{};

      for (final session in sessions) {
        final statusKey = session.status.toString();
        stats[statusKey] = (stats[statusKey] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      debugPrint('DatabaseService: Error getting session stats by status - $e');
      return {};
    }
  }

  Future<Map<String, int>> getTreatmentCompletionStats() async {
    try {
      final treatments = await getAllTreatments();
      final stats = <String, int>{};

      for (final treatment in treatments) {
        stats[treatment.name] = treatment.completedCount;
      }

      return stats;
    } catch (e) {
      debugPrint(
          'DatabaseService: Error getting treatment completion stats - $e');
      return {};
    }
  }

  Future<int> getCompletedSessionsCount({DateTime? since}) async {
    try {
      final sessions = await getAllSessions();
      if (since == null) {
        return sessions.where((s) => s.isCompleted).length;
      }

      return sessions
          .where((s) => s.isCompleted && s.scheduledTime.isAfter(since))
          .length;
    } catch (e) {
      debugPrint(
          'DatabaseService: Error getting completed sessions count - $e');
      return 0;
    }
  }

  Future<Duration> getTotalExerciseTime({DateTime? since}) async {
    try {
      final sessions = await getAllSessions();
      Duration totalTime = Duration.zero;

      for (final session in sessions) {
        if (!session.isCompleted) continue;
        if (since != null && session.scheduledTime.isBefore(since)) continue;

        // Calculate total time for completed treatments in this session
        for (final treatmentId in session.completedTreatmentIds) {
          final treatment = await getTreatmentById(treatmentId);
          if (treatment != null) {
            totalTime += Duration(seconds: treatment.durationSeconds);
          }
        }
      }

      return totalTime;
    } catch (e) {
      debugPrint('DatabaseService: Error getting total exercise time - $e');
      return Duration.zero;
    }
  }

  // ==========================================================================
  // DATA MANAGEMENT AND MAINTENANCE
  // ==========================================================================

  Future<void> cleanupOldSessions(
      {int daysToKeep = cleanupOldSessionsDays}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final sessionsToDelete = _sessionsBox.values
          .where((session) => session.scheduledTime.isBefore(cutoffDate))
          .map((session) => session.id)
          .toList();

      for (final sessionId in sessionsToDelete) {
        await deleteSession(sessionId);
      }

      debugPrint(
          'DatabaseService: Cleaned up ${sessionsToDelete.length} old sessions');
    } catch (e) {
      debugPrint('DatabaseService: Error cleaning up old sessions - $e');
    }
  }

  Future<void> compactDatabase() async {
    try {
      await _painPointsBox.compact();
      await _treatmentsBox.compact();
      await _settingsBox.compact();
      await _sessionsBox.compact();
      await _breakTimesBox.compact();

      debugPrint('DatabaseService: Database compacted successfully');
    } catch (e) {
      debugPrint('DatabaseService: Error compacting database - $e');
    }
  }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      return {
        'painPointsCount': _painPointsBox.length,
        'treatmentsCount': _treatmentsBox.length,
        'settingsCount': _settingsBox.length,
        'sessionsCount': _sessionsBox.length,
        'breakTimesCount': _breakTimesBox.length,
        'isInitialized': _isInitialized,
      };
    } catch (e) {
      debugPrint('DatabaseService: Error getting database info - $e');
      return {};
    }
  }

  // ==========================================================================
  // IMPORT/EXPORT FUNCTIONALITY
  // ==========================================================================

  Future<Map<String, dynamic>> exportAllData() async {
    try {
      return {
        'painPoints': _painPointsBox.values.map((p) => p.toJson()).toList(),
        'treatments': _treatmentsBox.values.map((t) => t.toJson()).toList(),
        'settings': (await getUserSettings())?.toJson(),
        'sessions': _sessionsBox.values.map((s) => s.toJson()).toList(),
        'breakTimes': _breakTimesBox.values.map((b) => b.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': appVersion,
      };
    } catch (e) {
      debugPrint('DatabaseService: Error exporting data - $e');
      throw e;
    }
  }

  Future<bool> importAllData(Map<String, dynamic> data) async {
    try {
      // Clear existing data
      await clearAllData();

      // Import pain points
      if (data['painPoints'] != null) {
        for (final painPointData in data['painPoints'] as List) {
          final painPoint = PainPoint.fromJson(painPointData);
          await savePainPoint(painPoint);
        }
      }

      // Import treatments
      if (data['treatments'] != null) {
        for (final treatmentData in data['treatments'] as List) {
          final treatment = Treatment.fromJson(treatmentData);
          await saveTreatment(treatment);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        final settings = UserSettings.fromJson(data['settings']);
        await saveUserSettings(settings);
      }

      // Import sessions
      if (data['sessions'] != null) {
        for (final sessionData in data['sessions'] as List) {
          final session = NotificationSession.fromJson(sessionData);
          await saveSession(session);
        }
      }

      // Import break times
      if (data['breakTimes'] != null) {
        for (final breakTimeData in data['breakTimes'] as List) {
          final breakTime = BreakTime.fromJson(breakTimeData);
          await saveBreakTime(breakTime);
        }
      }

      debugPrint('DatabaseService: Data import completed successfully');
      return true;
    } catch (e) {
      debugPrint('DatabaseService: Error importing data - $e');
      return false;
    }
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  Future<void> clearAllData() async {
    try {
      await _painPointsBox.clear();
      await _treatmentsBox.clear();
      await _settingsBox.clear();
      await _sessionsBox.clear();
      await _breakTimesBox.clear();

      debugPrint('DatabaseService: All data cleared');
    } catch (e) {
      debugPrint('DatabaseService: Error clearing all data - $e');
      throw e;
    }
  }

  Future<void> resetToDefaults() async {
    try {
      await clearAllData();
      await _initializeDefaultData();

      debugPrint('DatabaseService: Reset to defaults completed');
    } catch (e) {
      debugPrint('DatabaseService: Error resetting to defaults - $e');
      throw e;
    }
  }

  Future<void> close() async {
    try {
      await _painPointsBox.close();
      await _treatmentsBox.close();
      await _settingsBox.close();
      await _sessionsBox.close();
      await _breakTimesBox.close();

      _isInitialized = false;
      debugPrint('DatabaseService: All boxes closed');
    } catch (e) {
      debugPrint('DatabaseService: Error closing boxes - $e');
    }
  }

  // ==========================================================================
  // VALIDATION METHODS
  // ==========================================================================

  bool isValidPainPointId(String id) {
    return _painPointsBox.containsKey(id);
  }

  bool isValidTreatmentId(String id) {
    return _treatmentsBox.containsKey(id);
  }

  bool isValidSessionId(String id) {
    return _sessionsBox.containsKey(id);
  }

  bool isValidBreakTimeId(String id) {
    return _breakTimesBox.containsKey(id);
  }

  Future<bool> validateTreatmentIds(List<String> treatmentIds) async {
    try {
      for (final id in treatmentIds) {
        if (!isValidTreatmentId(id)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('DatabaseService: Error validating treatment IDs - $e');
      return false;
    }
  }

  Future<bool> validatePainPointIds(List<String> painPointIds) async {
    try {
      for (final id in painPointIds) {
        if (!isValidPainPointId(id)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('DatabaseService: Error validating pain point IDs - $e');
      return false;
    }
  }
}

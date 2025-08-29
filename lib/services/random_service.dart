import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/treatment.dart';
import '../models/pain_point.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';

class RandomService {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final Random _random = Random();

  // Generate random treatments based on user's selected pain points
  Future<List<Treatment>> generateRandomTreatments({
    required UserSettings settings,
    int? count,
  }) async {
    try {
      final treatmentCount = count ?? settings.treatmentsPerSession;
      final selectedPainPoints = settings.selectedPainPoints;

      if (selectedPainPoints.isEmpty) {
        debugPrint('No pain points selected, returning empty list');
        return [];
      }

      // Get all available treatments
      final allTreatments = await _databaseService.getAllTreatments();

      if (allTreatments.isEmpty) {
        debugPrint('No treatments available');
        return [];
      }

      // Filter treatments based on selected pain points
      final relevantTreatments = allTreatments.where((treatment) {
        return treatment.targetPainPoints.any(
          (painPointId) => selectedPainPoints.contains(painPointId),
        );
      }).toList();

      if (relevantTreatments.isEmpty) {
        debugPrint('No relevant treatments found for selected pain points');
        // If no relevant treatments found, return random treatments from all
        return _selectRandomTreatmentsFromList(allTreatments, treatmentCount);
      }

      return _selectRandomTreatmentsFromList(
          relevantTreatments, treatmentCount);
    } catch (e) {
      debugPrint('Error generating random treatments: $e');
      return [];
    }
  }

  // Select random treatments from a list (แก้ไข return type)
  List<Treatment> _selectRandomTreatmentsFromList(
      List<Treatment> treatments, int count) {
    if (treatments.isEmpty) return <Treatment>[];

    final shuffled = List<Treatment>.from(treatments);
    shuffled.shuffle(_random);

    // Return requested count or all available treatments (whichever is smaller)
    final actualCount = math.min(count, shuffled.length);
    return shuffled.take(actualCount).toList();
  }

  // Generate balanced treatment selection (mix of different categories)
  Future<List<Treatment>> generateBalancedTreatments({
    required UserSettings settings,
    int? count,
  }) async {
    try {
      final treatmentCount = count ?? settings.treatmentsPerSession;
      final selectedPainPoints = settings.selectedPainPoints;

      if (selectedPainPoints.isEmpty) return [];

      final allTreatments = await _databaseService.getAllTreatments();

      // Group treatments by category
      final treatmentsByCategory = <String, List<Treatment>>{};
      for (final treatment in allTreatments) {
        if (treatment.targetPainPoints.any(
          (painPointId) => selectedPainPoints.contains(painPointId),
        )) {
          treatmentsByCategory.putIfAbsent(treatment.category, () => []);
          treatmentsByCategory[treatment.category]!.add(treatment);
        }
      }

      final selectedTreatments = <Treatment>[];
      final categories = treatmentsByCategory.keys.toList();
      categories.shuffle(_random);

      // Try to get at least one treatment from each category
      int treatmentsPerCategory = treatmentCount ~/ categories.length;
      int remainingTreatments = treatmentCount % categories.length;

      for (final category in categories) {
        final categoryTreatments = treatmentsByCategory[category]!;
        categoryTreatments.shuffle(_random);

        final countForCategory =
            treatmentsPerCategory + (remainingTreatments > 0 ? 1 : 0);

        if (remainingTreatments > 0) remainingTreatments--;

        final actualCount =
            math.min(countForCategory, categoryTreatments.length);
        selectedTreatments.addAll(categoryTreatments.take(actualCount));
      }

      // If we still need more treatments, add randomly from remaining
      if (selectedTreatments.length < treatmentCount) {
        final remaining = allTreatments
            .where((t) => !selectedTreatments.contains(t))
            .where((t) => t.targetPainPoints.any(
                  (painPointId) => selectedPainPoints.contains(painPointId),
                ))
            .toList();

        remaining.shuffle(_random);
        final needed = treatmentCount - selectedTreatments.length;
        selectedTreatments.addAll(remaining.take(needed));
      }

      selectedTreatments.shuffle(_random);
      return selectedTreatments;
    } catch (e) {
      debugPrint('Error generating balanced treatments: $e');
      return [];
    }
  }

  // Generate treatments with difficulty progression
  Future<List<Treatment>> generateProgressiveTreatments({
    required UserSettings settings,
    int? count,
  }) async {
    try {
      final treatmentCount = count ?? settings.treatmentsPerSession;
      final selectedPainPoints = settings.selectedPainPoints;

      if (selectedPainPoints.isEmpty) return [];

      final allTreatments = await _databaseService.getAllTreatments();
      final relevantTreatments = allTreatments.where((treatment) {
        return treatment.targetPainPoints.any(
          (painPointId) => selectedPainPoints.contains(painPointId),
        );
      }).toList();

      if (relevantTreatments.isEmpty) return [];

      // Group by difficulty
      final treatmentsByDifficulty = <int, List<Treatment>>{};
      for (final treatment in relevantTreatments) {
        treatmentsByDifficulty.putIfAbsent(treatment.difficulty, () => []);
        treatmentsByDifficulty[treatment.difficulty]!.add(treatment);
      }

      final selectedTreatments = <Treatment>[];
      final difficulties = treatmentsByDifficulty.keys.toList()..sort();

      // Distribute treatments across difficulties
      int treatmentsPerDifficulty = treatmentCount ~/ difficulties.length;
      int remainingTreatments = treatmentCount % difficulties.length;

      for (final difficulty in difficulties) {
        final difficultyTreatments = treatmentsByDifficulty[difficulty]!;
        difficultyTreatments.shuffle(_random);

        final countForDifficulty =
            treatmentsPerDifficulty + (remainingTreatments > 0 ? 1 : 0);

        if (remainingTreatments > 0) remainingTreatments--;

        final actualCount =
            math.min(countForDifficulty, difficultyTreatments.length);
        selectedTreatments.addAll(difficultyTreatments.take(actualCount));
      }

      return selectedTreatments;
    } catch (e) {
      debugPrint('Error generating progressive treatments: $e');
      return [];
    }
  }

  // Generate next notification time within work hours
  DateTime generateNextNotificationTime(UserSettings settings) {
    final now = DateTime.now();
    final intervalMinutes = settings.notificationIntervalMinutes;

    // Start from next interval
    final nextTime = now.add(Duration(minutes: intervalMinutes));

    return _adjustToWorkHours(nextTime, settings);
  }

  // Generate multiple future notification times
  List<DateTime> generateNotificationSchedule({
    required UserSettings settings,
    required int days,
  }) {
    final schedule = <DateTime>[];
    final now = DateTime.now();

    for (int day = 0; day < days; day++) {
      final targetDate = now.add(Duration(days: day));

      // Skip if not a work day
      if (!settings.isWorkDay(targetDate)) continue;

      final daySchedule = _generateDaySchedule(targetDate, settings);
      schedule.addAll(daySchedule);
    }

    return schedule;
  }

  // Generate schedule for a single day
  List<DateTime> _generateDaySchedule(DateTime date, UserSettings settings) {
    final schedule = <DateTime>[];
    final workStart = DateTime(
      date.year,
      date.month,
      date.day,
      settings.workStartTime.hour,
      settings.workStartTime.minute,
    );

    final workEnd = DateTime(
      date.year,
      date.month,
      date.day,
      settings.workEndTime.hour,
      settings.workEndTime.minute,
    );

    final intervalMinutes = settings.notificationIntervalMinutes;
    DateTime currentTime = workStart;

    while (currentTime.isBefore(workEnd)) {
      schedule.add(currentTime);
      currentTime = currentTime.add(Duration(minutes: intervalMinutes));
    }

    return schedule;
  }

  // Adjust time to fall within work hours
  DateTime _adjustToWorkHours(DateTime time, UserSettings settings) {
    final date = time;
    final workStart = DateTime(
      date.year,
      date.month,
      date.day,
      settings.workStartTime.hour,
      settings.workStartTime.minute,
    );

    final workEnd = DateTime(
      date.year,
      date.month,
      date.day,
      settings.workEndTime.hour,
      settings.workEndTime.minute,
    );

    // If before work hours, set to work start
    if (time.isBefore(workStart)) {
      return workStart;
    }

    // If after work hours, move to next work day
    if (time.isAfter(workEnd)) {
      return _findNextWorkDay(time, settings);
    }

    return time;
  }

  // Find next work day start time
  DateTime _findNextWorkDay(DateTime fromTime, UserSettings settings) {
    DateTime nextDay = DateTime(
      fromTime.year,
      fromTime.month,
      fromTime.day + 1,
      settings.workStartTime.hour,
      settings.workStartTime.minute,
    );

    // Keep looking for next work day
    while (!settings.isWorkDay(nextDay)) {
      nextDay = nextDay.add(const Duration(days: 1));
    }

    return nextDay;
  }

  // Generate random delay (for more natural notifications)
  Duration generateRandomDelay({int maxMinutes = 5}) {
    final randomMinutes = _random.nextInt(maxMinutes + 1);
    return Duration(minutes: randomMinutes);
  }

  // Check if current time is suitable for notifications
  bool isGoodTimeForNotification(UserSettings settings) {
    final now = DateTime.now();

    // Check if it's a work day
    if (!settings.isWorkDay(now)) return false;

    // Check if it's within work hours
    if (!settings.isWorkTime(TimeOfDay.fromDateTime(now))) return false;

    return true;
  }

  // Generate weighted random selection (favor less-used treatments)
  Future<List<Treatment>> generateWeightedTreatments({
    required UserSettings settings,
    int? count,
  }) async {
    try {
      final treatmentCount = count ?? settings.treatmentsPerSession;
      final selectedPainPoints = settings.selectedPainPoints;

      if (selectedPainPoints.isEmpty) return [];

      final allTreatments = await _databaseService.getAllTreatments();
      final relevantTreatments = allTreatments.where((treatment) {
        return treatment.targetPainPoints.any(
          (painPointId) => selectedPainPoints.contains(painPointId),
        );
      }).toList();

      if (relevantTreatments.isEmpty) return [];

      // Calculate weights (inverse of completion count)
      final maxCompletions = relevantTreatments
          .map((t) => t.completedCount)
          .fold<int>(0, math.max);

      final weightedTreatments = <Treatment>[];
      for (final treatment in relevantTreatments) {
        // Higher weight for less-used treatments
        final weight = maxCompletions - treatment.completedCount + 1;
        for (int i = 0; i < weight; i++) {
          weightedTreatments.add(treatment);
        }
      }

      weightedTreatments.shuffle(_random);
      final selectedTreatments = <Treatment>[];
      final usedTreatments = <String>{};

      for (final treatment in weightedTreatments) {
        if (usedTreatments.contains(treatment.id)) continue;
        selectedTreatments.add(treatment);
        usedTreatments.add(treatment.id);

        if (selectedTreatments.length >= treatmentCount) break;
      }

      return selectedTreatments;
    } catch (e) {
      debugPrint('Error generating weighted treatments: $e');
      return [];
    }
  }
}

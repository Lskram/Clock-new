import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/treatment.dart';
import '../models/pain_point.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';

class RandomService extends GetxService {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final math.Random _random = math.Random();

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

  // Select random treatments from a list - แก้ไข return type
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
      if (allTreatments.isEmpty) return [];

      // Group treatments by pain points
      final treatmentsByPainPoint = <String, List<Treatment>>{};

      for (final painPointId in selectedPainPoints) {
        treatmentsByPainPoint[painPointId] = allTreatments
            .where(
                (treatment) => treatment.targetPainPoints.contains(painPointId))
            .toList();
      }

      // Select treatments ensuring balance across pain points
      final selectedTreatments = <Treatment>[];
      final painPointQueue = List<String>.from(selectedPainPoints);

      while (selectedTreatments.length < treatmentCount &&
          painPointQueue.isNotEmpty) {
        // Shuffle to ensure randomness
        painPointQueue.shuffle(_random);

        for (final painPointId in List<String>.from(painPointQueue)) {
          if (selectedTreatments.length >= treatmentCount) break;

          final availableTreatments = treatmentsByPainPoint[painPointId] ?? [];
          final unselectedTreatments = availableTreatments
              .where((t) => !selectedTreatments.contains(t))
              .toList();

          if (unselectedTreatments.isNotEmpty) {
            final randomTreatment = unselectedTreatments[
                _random.nextInt(unselectedTreatments.length)];
            selectedTreatments.add(randomTreatment);
          } else {
            // No more treatments for this pain point, remove it from queue
            painPointQueue.remove(painPointId);
          }
        }
      }

      return selectedTreatments;
    } catch (e) {
      debugPrint('Error generating balanced treatments: $e');
      return [];
    }
  }

  // Generate treatments by difficulty level
  Future<List<Treatment>> generateTreatmentsByDifficulty({
    required UserSettings settings,
    required int difficulty,
    int? count,
  }) async {
    try {
      final treatmentCount = count ?? settings.treatmentsPerSession;
      final selectedPainPoints = settings.selectedPainPoints;

      if (selectedPainPoints.isEmpty) return [];

      final allTreatments = await _databaseService.getAllTreatments();

      final filteredTreatments = allTreatments.where((treatment) {
        return treatment.difficulty == difficulty &&
            treatment.targetPainPoints.any(
              (painPointId) => selectedPainPoints.contains(painPointId),
            );
      }).toList();

      return _selectRandomTreatmentsFromList(
          filteredTreatments, treatmentCount);
    } catch (e) {
      debugPrint('Error generating treatments by difficulty: $e');
      return [];
    }
  }

  // Generate treatments by duration range
  Future<List<Treatment>> generateTreatmentsByDuration({
    required UserSettings settings,
    required int minDuration,
    required int maxDuration,
    int? count,
  }) async {
    try {
      final treatmentCount = count ?? settings.treatmentsPerSession;
      final selectedPainPoints = settings.selectedPainPoints;

      if (selectedPainPoints.isEmpty) return [];

      final allTreatments = await _databaseService.getAllTreatments();

      final filteredTreatments = allTreatments.where((treatment) {
        return treatment.duration >= minDuration &&
            treatment.duration <= maxDuration &&
            treatment.targetPainPoints.any(
              (painPointId) => selectedPainPoints.contains(painPointId),
            );
      }).toList();

      return _selectRandomTreatmentsFromList(
          filteredTreatments, treatmentCount);
    } catch (e) {
      debugPrint('Error generating treatments by duration: $e');
      return [];
    }
  }

  // Generate smart session (considers time of day, break times, etc.)
  Future<List<Treatment>> generateSmartSession({
    required UserSettings settings,
    int? count,
  }) async {
    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay.now();
      final treatmentCount = count ?? settings.treatmentsPerSession;

      // Check if it's during break time
      final isBreakTime = settings.breakTimes.any((breakTime) {
        return breakTime.isEnabled && breakTime.isTimeInRange(currentTime);
      });

      // Adjust difficulty and duration based on time and context
      int targetDifficulty;
      int maxDuration;

      if (isBreakTime) {
        // During break time, prefer easier and shorter exercises
        targetDifficulty = 1;
        maxDuration = 60; // 1 minute max
      } else if (_isEarlyMorning(currentTime)) {
        // Early morning - gentle warm-up exercises
        targetDifficulty = 1;
        maxDuration = 90;
      } else if (_isAfternoon(currentTime)) {
        // Afternoon - more energetic exercises
        targetDifficulty = 2;
        maxDuration = 120;
      } else {
        // Regular time - balanced selection
        targetDifficulty = 0; // Any difficulty
        maxDuration = 180;
      }

      List<Treatment> treatments;

      if (targetDifficulty > 0) {
        treatments = await generateTreatmentsByDifficulty(
          settings: settings,
          difficulty: targetDifficulty,
          count: treatmentCount,
        );

        // If not enough treatments found, fallback to general selection
        if (treatments.length < treatmentCount) {
          final additionalTreatments = await generateRandomTreatments(
            settings: settings,
            count: treatmentCount - treatments.length,
          );
          treatments.addAll(additionalTreatments);
        }
      } else {
        treatments = await generateRandomTreatments(
          settings: settings,
          count: treatmentCount,
        );
      }

      // Filter by duration if needed
      if (maxDuration < 180) {
        treatments =
            treatments.where((t) => t.duration <= maxDuration).toList();
      }

      return treatments.take(treatmentCount).toList();
    } catch (e) {
      debugPrint('Error generating smart session: $e');
      return await generateRandomTreatments(settings: settings, count: count);
    }
  }

  // Helper methods for time-based logic
  bool _isEarlyMorning(TimeOfDay time) {
    return time.hour >= 6 && time.hour < 10;
  }

  bool _isAfternoon(TimeOfDay time) {
    return time.hour >= 14 && time.hour < 18;
  }

  // Get treatment statistics for debugging
  Future<Map<String, dynamic>> getTreatmentStats() async {
    try {
      final allTreatments = await _databaseService.getAllTreatments();

      final stats = {
        'total': allTreatments.length,
        'byDifficulty': <int, int>{},
        'byPainPoint': <String, int>{},
        'avgDuration': 0.0,
      };

      // Count by difficulty
      for (final treatment in allTreatments) {
        stats['byDifficulty'][treatment.difficulty] =
            (stats['byDifficulty'][treatment.difficulty] ?? 0) + 1;

        // Count by pain points
        for (final painPointId in treatment.targetPainPoints) {
          stats['byPainPoint'][painPointId] =
              (stats['byPainPoint'][painPointId] ?? 0) + 1;
        }
      }

      // Calculate average duration
      if (allTreatments.isNotEmpty) {
        final totalDuration =
            allTreatments.map((t) => t.duration).reduce((a, b) => a + b);
        stats['avgDuration'] = totalDuration / allTreatments.length;
      }

      debugPrint('Treatment stats: $stats');
      return stats;
    } catch (e) {
      debugPrint('Error getting treatment stats: $e');
      return {};
    }
  }

  // Utility method for testing randomness
  Future<void> testRandomDistribution({
    required UserSettings settings,
    int iterations = 100,
  }) async {
    try {
      final distributionCount = <String, int>{};

      for (int i = 0; i < iterations; i++) {
        final treatments = await generateRandomTreatments(settings: settings);

        for (final treatment in treatments) {
          distributionCount[treatment.id] =
              (distributionCount[treatment.id] ?? 0) + 1;
        }
      }

      debugPrint('Random distribution test ($iterations iterations):');
      distributionCount.forEach((treatmentId, count) {
        final percentage = (count / iterations * 100).toStringAsFixed(1);
        debugPrint('$treatmentId: $count times ($percentage%)');
      });
    } catch (e) {
      debugPrint('Error in random distribution test: $e');
    }
  }
}

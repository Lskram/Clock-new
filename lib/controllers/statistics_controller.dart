import 'package:get/get.dart';

import '../models/notification_session.dart';
import '../services/database_service.dart';

class StatisticsController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Observable variables
  final RxMap<String, int> todayStats = <String, int>{}.obs;
  final RxMap<String, int> weekStats = <String, int>{}.obs;
  final RxMap<String, int> monthStats = <String, int>{}.obs;
  final RxMap<int, int> painPointUsageStats = <int, int>{}.obs;
  final RxList<NotificationSession> recentSessions =
      <NotificationSession>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTodayStats();
  }

  /// โหลดสถิติวันนี้
  Future<void> loadTodayStats() async {
    try {
      isLoading.value = true;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final stats = await _databaseService.getSessionStatsByStatus(
        startOfDay,
        endOfDay,
      );

      // คำนวณสถิติ
      final total = stats.values.fold(0, (sum, count) => sum + count);
      final completed = stats[NotificationStatus.completed.name] ?? 0;
      final skipped = stats[NotificationStatus.skipped.name] ?? 0;
      final pending = stats[NotificationStatus.pending.name] ?? 0;
      final snoozed = stats[NotificationStatus.snoozed.name] ?? 0;

      todayStats.assignAll({
        'total': total,
        'completed': completed,
        'skipped': skipped,
        'pending': pending,
        'snoozed': snoozed,
      });

      print('Today stats loaded: $todayStats');
    } catch (e) {
      print('Error loading today stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// โหลดสถิติสัปดาห์นี้
  Future<void> loadWeekStats() async {
    try {
      final today = DateTime.now();
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final startDate =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endDate = startDate.add(const Duration(days: 7));

      final stats = await _databaseService.getSessionStatsByStatus(
        startDate,
        endDate,
      );

      final total = stats.values.fold(0, (sum, count) => sum + count);
      final completed = stats[NotificationStatus.completed.name] ?? 0;
      final skipped = stats[NotificationStatus.skipped.name] ?? 0;

      weekStats.assignAll({
        'total': total,
        'completed': completed,
        'skipped': skipped,
        'success_rate': total > 0 ? ((completed / total) * 100).round() : 0,
      });
    } catch (e) {
      print('Error loading week stats: $e');
    }
  }

  /// โหลดสถิติเดือนนี้
  Future<void> loadMonthStats() async {
    try {
      final today = DateTime.now();
      final startOfMonth = DateTime(today.year, today.month, 1);
      final endOfMonth = DateTime(today.year, today.month + 1, 1);

      final stats = await _databaseService.getSessionStatsByStatus(
        startOfMonth,
        endOfMonth,
      );

      final total = stats.values.fold(0, (sum, count) => sum + count);
      final completed = stats[NotificationStatus.completed.name] ?? 0;

      monthStats.assignAll({
        'total': total,
        'completed': completed,
        'average_per_day': (completed / today.day).round(),
      });
    } catch (e) {
      print('Error loading month stats: $e');
    }
  }

  /// โหลดสถิติการใช้งาน pain points
  Future<void> loadPainPointUsageStats() async {
    try {
      final today = DateTime.now();
      final startOfMonth = DateTime(today.year, today.month, 1);

      final usage = await _databaseService.getPainPointUsageStats(
        startOfMonth,
        today,
      );

      painPointUsageStats.assignAll(usage);
    } catch (e) {
      print('Error loading pain point usage stats: $e');
    }
  }

  /// โหลด sessions ล่าสุด
  Future<void> loadRecentSessions({int limit = 10}) async {
    try {
      final sessions = await _databaseService.getAllSessions();
      recentSessions.assignAll(sessions.take(limit).toList());
    } catch (e) {
      print('Error loading recent sessions: $e');
    }
  }

  /// ได้อัตราความสำเร็จวันนี้
  double get todaySuccessRate {
    final total = todayStats['total'] ?? 0;
    final completed = todayStats['completed'] ?? 0;

    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  /// ได้อัตราความสำเร็จสัปดาห์นี้
  double get weekSuccessRate {
    final total = weekStats['total'] ?? 0;
    final completed = weekStats['completed'] ?? 0;

    if (total == 0) return 0.0;
    return (completed / total) * 100;
  }

  /// ได้สถิติรายวันใน 7 วันล่าสุด
  Future<List<Map<String, dynamic>>> getDailyStatsForWeek() async {
    try {
      final today = DateTime.now();
      final weekData = <Map<String, dynamic>>[];

      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final dayStats = await _databaseService.getSessionStatsByStatus(
          startOfDay,
          endOfDay,
        );

        final total = dayStats.values.fold(0, (sum, count) => sum + count);
        final completed = dayStats[NotificationStatus.completed.name] ?? 0;

        weekData.add({
          'date': date,
          'dayName': _getDayName(date.weekday),
          'total': total,
          'completed': completed,
          'successRate': total > 0 ? ((completed / total) * 100).round() : 0,
        });
      }

      return weekData;
    } catch (e) {
      print('Error getting daily stats for week: $e');
      return [];
    }
  }

  /// ได้ pain point ที่ใช้บ่อยที่สุด
  String get mostUsedPainPointName {
    if (painPointUsageStats.isEmpty) return 'ไม่มีข้อมูล';

    final mostUsedId = painPointUsageStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return _getPainPointName(mostUsedId);
  }

  /// ได้ช่วงเวลาที่ทำได้ดีที่สุด
  Future<String> getBestPerformanceTime() async {
    try {
      final completedSessions = await _databaseService.getAllSessions(
        status: NotificationStatus.completed,
      );

      if (completedSessions.isEmpty) return 'ไม่มีข้อมูล';

      // นับตามช่วงเวลา
      final hourCounts = <int, int>{};
      for (final session in completedSessions) {
        final hour = session.scheduledTime.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }

      // หาช่วงเวลาที่ทำได้ดีที่สุด
      final bestHour =
          hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      return '${bestHour.toString().padLeft(2, '0')}:00-${(bestHour + 1).toString().padLeft(2, '0')}:00';
    } catch (e) {
      print('Error getting best performance time: $e');
      return 'ไม่มีข้อมูล';
    }
  }

  /// รีเฟรชข้อมูลทั้งหมด
  Future<void> refreshAllStats() async {
    await Future.wait([
      loadTodayStats(),
      loadWeekStats(),
      loadMonthStats(),
      loadPainPointUsageStats(),
      loadRecentSessions(),
    ]);
  }

  /// ลบข้อมูลเก่าทิ้ง
  Future<void> cleanupOldData() async {
    try {
      await _databaseService.deleteOldSessions();
      await refreshAllStats();

      Get.snackbar(
        'ล้างข้อมูลสำเร็จ',
        'ลบข้อมูลเก่าทิ้งแล้ว',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error cleaning up old data: $e');
      Get.snackbar(
        'ข้อผิดพลาด',
        'ไม่สามารถล้างข้อมูลได้',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Export ข้อมูลสถิติเป็น summary
  Map<String, dynamic> exportStatsSummary() {
    return {
      'today': todayStats.value,
      'week': weekStats.value,
      'month': monthStats.value,
      'painPointUsage': painPointUsageStats.value,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Helper methods
  String _getDayName(int weekday) {
    const dayNames = [
      '', // weekday starts from 1
      'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'
    ];
    return dayNames[weekday];
  }

  String _getPainPointName(int painPointId) {
    const painPointNames = {
      1: 'ศีรษะ',
      2: 'ตา',
      3: 'คอ',
      4: 'บ่าและไหล่',
      5: 'หลังส่วนบน',
      6: 'หลังส่วนล่าง',
      7: 'แขน/ศอก',
      8: 'ข้อมือ/มือ/นิ้ว',
      9: 'ขา',
      10: 'เท้า',
    };
    return painPointNames[painPointId] ?? 'ไม่ระบุ';
  }

  /// ได้ข้อมูลสถิติสำหรับ chart
  List<Map<String, dynamic>> getWeeklyChartData() {
    // สำหรับใช้กับ chart library
    return List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return {
        'day': _getDayName(date.weekday),
        'completed': 0, // จะได้จาก getDailyStatsForWeek()
        'total': 0,
      };
    });
  }

  /// คำนวณ streak (จำนวนวันติดต่อกันที่ทำได้)
  Future<int> calculateCurrentStreak() async {
    try {
      final today = DateTime.now();
      int streak = 0;

      for (int i = 0; i < 30; i++) {
        // ตรวจสอบ 30 วันย้อนหลัง
        final date = today.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final dayStats = await _databaseService.getSessionStatsByStatus(
          startOfDay,
          endOfDay,
        );

        final completed = dayStats[NotificationStatus.completed.name] ?? 0;

        if (completed > 0) {
          streak++;
        } else {
          break; // หยุดนับเมื่อเจอวันที่ไม่ได้ทำ
        }
      }

      return streak;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }

  /// ได้เป้าหมายประจำวัน (จากการตั้งค่า)
  int getDailyGoal() {
    // TODO: ดึงจากการตั้งค่าผู้ใช้
    // ตอนนี้ใช้ค่าเริ่มต้นตามช่วงเวลาทำงาน 8 ชม. / ทุก 1 ชม. = 8 ครั้ง
    return 8;
  }

  /// ตรวจสอบว่าวันนี้บรรลุเป้าหมายหรือไม่
  bool get isTodayGoalAchieved {
    final completed = todayStats['completed'] ?? 0;
    return completed >= getDailyGoal();
  }

  /// ได้เปอร์เซ็นต์ความก้าวหน้าต่อเป้าหมายวันนี้
  double get todayGoalProgress {
    final completed = todayStats['completed'] ?? 0;
    final goal = getDailyGoal();

    if (goal == 0) return 0.0;
    return (completed / goal * 100).clamp(0.0, 100.0);
  }

  /// ได้ข้อความสำหรับแสดงสถิติ
  String getTodayStatusMessage() {
    final completed = todayStats['completed'] ?? 0;
    final total = todayStats['total'] ?? 0;
    final goal = getDailyGoal();

    if (total == 0) {
      return 'วันนี้ยังไม่มีการแจ้งเตือน';
    }

    if (completed >= goal) {
      return 'ยินดีด้วย! วันนี้คุณบรรลุเป้าหมายแล้ว 🎉';
    } else if (completed > 0) {
      return 'ทำได้ดี! ทำไปแล้ว $completed ครั้งจาก $total ครั้ง';
    } else {
      return 'ยังไม่ได้เริ่มออกกำลังกายวันนี้';
    }
  }

  /// ได้คำแนะนำตามสถิติ
  String getMotivationalTip() {
    final successRate = todaySuccessRate;

    if (successRate >= 80) {
      return 'เยี่ยมมาก! คุณทำได้ดีมาก รักษาไว้แบบนี้นะ! 💪';
    } else if (successRate >= 60) {
      return 'ทำได้ดี! ลองเพิ่มความสม่ำเสมอนิดหน่อยจะดีมาก 👍';
    } else if (successRate >= 40) {
      return 'เริ่มได้แล้ว! ลองตั้งการแจ้งเตือนให้ชัดเจนมากขึ้น ⏰';
    } else if (successRate > 0) {
      return 'เริ่มต้นใหม่ได้เสมอ! การดูแลสุขภาพสำคัญมาก 🌟';
    } else {
      return 'เริ่มต้นดูแลสุขภาพกันเถอะ! แค่นิดหน่อยก็มีผลมาก ✨';
    }
  }
}

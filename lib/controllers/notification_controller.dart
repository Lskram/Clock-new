import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/notification_session.dart';
import '../models/treatment.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';
import '../services/random_service.dart';
import '../routes/app_routes.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final RandomService _randomService = Get.find<RandomService>();

  // Observable variables
  final Rx<NotificationSession?> currentSession =
      Rx<NotificationSession?>(null);
  final RxList<Treatment> currentTreatments = <Treatment>[].obs;
  final RxList<bool> treatmentCompletionStatus = <bool>[].obs;
  final RxString currentPainPointName = ''.obs;
  final RxInt completedTreatmentCount = 0.obs;
  final RxBool isSessionActive = false.obs;
  final RxBool isLoading = false.obs;
  final RxString sessionGreeting = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkForActiveSession();
  }

  /// ตรวจสอบว่ามี session ที่ยังไม่เสร็จหรือไม่
  Future<void> _checkForActiveSession() async {
    try {
      // ตรวจสอบจากพารามิเตอร์ที่ส่งมา (จาก notification tap)
      final sessionId = Get.parameters['sessionId'];
      if (sessionId != null && sessionId.isNotEmpty) {
        await loadSessionById(sessionId);
        return;
      }

      // หรือตรวจสอบจาก pending sessions วันนี้
      final todaySessions = await _databaseService.getTodaySessions();
      final pendingSession = todaySessions
          .where((s) =>
              s.status == NotificationStatus.pending ||
              s.status == NotificationStatus.snoozed)
          .firstOrNull;

      if (pendingSession != null) {
        await loadSessionById(pendingSession.id);
      }
    } catch (e) {
      print('Error checking for active session: $e');
    }
  }

  /// โหลด session ตาม ID
  Future<void> loadSessionById(String sessionId) async {
    try {
      isLoading.value = true;

      final session = await _databaseService.getNotificationSession(sessionId);
      if (session == null) {
        Get.snackbar('ข้อผิดพลาด', 'ไม่พบข้อมูล session');
        return;
      }

      await _loadSessionData(session);
    } catch (e) {
      print('Error loading session: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถโหลดข้อมูลได้');
    } finally {
      isLoading.value = false;
    }
  }

  /// โหลดข้อมูลของ session
  Future<void> _loadSessionData(NotificationSession session) async {
    currentSession.value = session;
    isSessionActive.value = true;

    // โหลดชื่อ pain point
    currentPainPointName.value = await _randomService.getPainPointName(
      session.selectedPainPointId,
    );

    // โหลด treatments
    final treatments = <Treatment>[];
    for (final treatmentId in session.selectedTreatmentIds) {
      final treatment = await _randomService.getTreatment(treatmentId);
      if (treatment != null) {
        treatments.add(treatment);
      }
    }

    currentTreatments.assignAll(treatments);

    // เตรียมสถานะการทำ treatments (เริ่มต้นเป็น false ทั้งหมด)
    treatmentCompletionStatus.assignAll(
      List.generate(treatments.length, (index) => false),
    );

    completedTreatmentCount.value = 0;

    // สร้างข้อความทักทาย
    sessionGreeting.value = _randomService.generateSessionGreeting();

    print('Session loaded: ${session.id}');
    print('Pain point: ${currentPainPointName.value}');
    print('Treatments count: ${treatments.length}');
  }

  /// มาร์คว่าท่านี้เสร็จแล้ว
  void markTreatmentCompleted(int treatmentIndex) {
    if (treatmentIndex >= 0 &&
        treatmentIndex < treatmentCompletionStatus.length) {
      treatmentCompletionStatus[treatmentIndex] = true;
      _updateCompletedCount();
      update(); // อัปเดต UI
    }
  }

  /// ยกเลิกการมาร์คท่า
  void markTreatmentUncompleted(int treatmentIndex) {
    if (treatmentIndex >= 0 &&
        treatmentIndex < treatmentCompletionStatus.length) {
      treatmentCompletionStatus[treatmentIndex] = false;
      _updateCompletedCount();
      update();
    }
  }

  /// อัปเดตจำนวนท่าที่เสร็จ
  void _updateCompletedCount() {
    completedTreatmentCount.value =
        treatmentCompletionStatus.where((completed) => completed).length;
  }

  /// ตรวจสอบว่าทำครบทุกท่าหรือยัง
  bool get isAllTreatmentsCompleted {
    return completedTreatmentCount.value == currentTreatments.length &&
        currentTreatments.isNotEmpty;
  }

  /// ได้เปอร์เซ็นต์ความก้าวหน้า
  double get progressPercentage {
    if (currentTreatments.isEmpty) return 0.0;
    return completedTreatmentCount.value / currentTreatments.length;
  }

  /// ได้ระยะเวลารวมของ session
  Duration get totalSessionDuration {
    return Duration(
      seconds: currentTreatments
          .map((t) => t.durationSeconds)
          .fold(0, (sum, duration) => sum + duration),
    );
  }

  /// เสร็จสิ้น session
  Future<void> completeSession() async {
    if (currentSession.value == null) return;

    try {
      isLoading.value = true;

      await _notificationService.completeNotificationSession(
        currentSession.value!.id,
      );

      // แสดงข้อความยินดี
      Get.snackbar(
        'เยี่ยมมาก! 🎉',
        'คุณทำออกกำลังกายเสร็จแล้ว! ร่างกายจะสดชื่นขึ้นแน่นอน',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // รีเซ็ตข้อมูล
      _resetSession();

      // กลับไปหน้าหลัก
      Get.offNamedUntil(AppRoutes.HOME, (route) => false);
    } catch (e) {
      print('Error completing session: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถบันทึกผลลัพธ์ได้');
    } finally {
      isLoading.value = false;
    }
  }

  /// เลื่อนการแจ้งเตือน
  Future<void> snoozeSession(int minutes) async {
    if (currentSession.value == null) return;

    try {
      isLoading.value = true;

      await _notificationService.snoozeNotification(
        currentSession.value!.id,
        minutes,
      );

      Get.snackbar(
        'เลื่อนการแจ้งเตือนแล้ว ⏰',
        'จะแจ้งเตือนอีกครั้งใน $minutes นาที',
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );

      _resetSession();
      Get.back(); // กลับไปหน้าก่อนหน้า
    } catch (e) {
      print('Error snoozing session: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถเลื่อนการแจ้งเตือนได้');
    } finally {
      isLoading.value = false;
    }
  }

  /// ข้าม session นี้
  Future<void> skipSession() async {
    if (currentSession.value == null) return;

    try {
      isLoading.value = true;

      await _notificationService.skipNotificationSession(
        currentSession.value!.id,
      );

      Get.snackbar(
        'ข้ามแล้ว ⏭️',
        'ไม่เป็นไร! ครั้งหน้าจะมีโอกาสดูแลสุขภาพอีก',
        backgroundColor: Colors.grey.withOpacity(0.8),
        colorText: Colors.white,
      );

      _resetSession();
      Get.offNamedUntil(AppRoutes.HOME, (route) => false);
    } catch (e) {
      print('Error skipping session: $e');
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถข้าม session ได้');
    } finally {
      isLoading.value = false;
    }
  }

  /// รีเซ็ตข้อมูล session
  void _resetSession() {
    currentSession.value = null;
    currentTreatments.clear();
    treatmentCompletionStatus.clear();
    currentPainPointName.value = '';
    completedTreatmentCount.value = 0;
    isSessionActive.value = false;
    sessionGreeting.value = '';
  }

  /// ได้รายการ snooze options
  List<Map<String, dynamic>> get snoozeOptions {
    return [
      {'minutes': 5, 'label': '5 นาที'},
      {'minutes': 15, 'label': '15 นาที'},
      {'minutes': 30, 'label': '30 นาที'},
    ];
  }

  /// ตรวจสอบว่าสามารถเลื่อนได้อีกหรือไม่
  bool get canSnooze {
    return currentSession.value?.canSnooze ?? false;
  }

  /// ได้จำนวนครั้งที่เลื่อนแล้ว
  int get snoozeCount {
    return currentSession.value?.snoozeCount ?? 0;
  }

  /// ได้ข้อมูล summary สำหรับแสดงผล
  Future<Map<String, dynamic>> getSessionSummary() async {
    if (currentSession.value == null) return {};

    return await _randomService.createSessionSummary(
      currentSession.value!.selectedPainPointId,
      currentSession.value!.selectedTreatmentIds,
    );
  }

  /// แสดงไดอะล็อกยืนยันการข้าม
  Future<void> showSkipConfirmationDialog() async {
    Get.dialog(
      AlertDialog(
        title: const Text('ข้าม Session นี้?'),
        content: const Text(
          'คุณแน่ใจหรือไม่ที่จะข้ามการออกกำลังกายในครั้งนี้? '
          'การดูแลสุขภาพอย่างสม่ำเสมอจะช่วยให้คุณรู้สึกดีขึ้น',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              skipSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text('ข้าม'),
          ),
        ],
      ),
    );
  }

  /// แสดงไดอะล็อกเลือก snooze time
  Future<void> showSnoozeOptionsDialog() async {
    if (!canSnooze) {
      Get.snackbar(
        'ไม่สามารถเลื่อนได้',
        'คุณได้เลื่อนครบจำนวนที่กำหนดแล้ว',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('เลื่อนการแจ้งเตือน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: snoozeOptions.map((option) {
            return ListTile(
              title: Text('เลื่อน ${option['label']}'),
              onTap: () {
                Get.back();
                snoozeSession(option['minutes']);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:get/get.dart';

import '../models/pain_point.dart';
import '../models/treatment.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class RandomService extends GetxService {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final Random _random = Random();

  // Initialize method for GetxService
  Future<RandomService> init() async {
    return this;
  }

  /// สุ่มเลือกท่าออกกำลังกายสำหรับ notification session
  /// Returns: {'painPointId': int, 'treatmentIds': List<String>}
  Future<Map<String, dynamic>> selectRandomTreatments(
    List<int> availablePainPointIds,
  ) async {
    if (availablePainPointIds.isEmpty) {
      throw Exception('No pain points available for selection');
    }

    // สุ่มเลือก 1 จุดจาก pain points ที่ผู้ใช้เลือกไว้
    final selectedPainPointId =
        availablePainPointIds[_random.nextInt(availablePainPointIds.length)];

    // หาท่าออกกำลังกายทั้งหมดสำหรับจุดนี้
    final availableTreatments =
        await _getTreatmentsForPainPoint(selectedPainPointId);

    if (availableTreatments.isEmpty) {
      throw Exception(
          'No treatments available for pain point: $selectedPainPointId');
    }

    // สุ่มเลือก 2 ท่า (หรือน้อยกว่าถ้ามีไม่พอ)
    final selectedTreatments = _selectRandomTreatmentsFromList(
      availableTreatments,
      AppConstants.DEFAULT_TREATMENTS_PER_SESSION,
    );

    return {
      'painPointId': selectedPainPointId,
      'treatmentIds': selectedTreatments.map((t) => t.id).toList(),
    };
  }

  /// หาท่าออกกำลังกายทั้งหมดสำหรับ pain point นั้นๆ
  Future<List<Treatment>> _getTreatmentsForPainPoint(int painPointId) async {
    // รวม default treatments และ custom treatments
    final defaultTreatments =
        TreatmentData.getTreatmentsByPainPoint(painPointId);
    final customTreatments = await _databaseService.getCustomTreatments();

    final painPointCustomTreatments =
        customTreatments.where((t) => t.painPointId == painPointId).toList();

    return [...defaultTreatments, ...painPointCustomTreatments];
  }

  /// สุ่มเลือกท่าออกกำลังกายจาก list
  List<Treatment> _selectRandomTreatmentsFromList(
    List<Treatment> treatments,
    int count,
  ) {
    if (treatments.length <= count) {
      // ถ้ามีท่าไม่พอ ให้เอาทั้งหมด
      return List.from(treatments)..shuffle(_random);
    }

    // สุ่มเลือกจำนวนที่ต้องการ
    final shuffled = List.from(treatments)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// สุ่มเลือก pain point จาก list (สำหรับ testing)
  int selectRandomPainPoint(List<int> painPointIds) {
    if (painPointIds.isEmpty) {
      throw Exception('No pain points available');
    }
    return painPointIds[_random.nextInt(painPointIds.length)];
  }

  /// สุ่มเลือกช่วงเวลา snooze
  int selectRandomSnoozeInterval(List<int> availableIntervals) {
    if (availableIntervals.isEmpty) {
      return AppConstants.DEFAULT_SNOOZE_INTERVALS.first;
    }
    return availableIntervals[_random.nextInt(availableIntervals.length)];
  }

  /// ได้ชื่อ pain point จาก ID
  Future<String> getPainPointName(int painPointId) async {
    final painPoints = PainPointData.getAllPainPoints();
    final painPoint = painPoints.firstWhereOrNull((pp) => pp.id == painPointId);
    return painPoint?.name ?? 'ไม่ระบุ';
  }

  /// ได้ treatment จาก ID
  Future<Treatment?> getTreatment(String treatmentId) async {
    // ลองหาจาก default treatments ก่อน
    final defaultTreatments = TreatmentData.getAllTreatments();
    final defaultTreatment =
        defaultTreatments.firstWhereOrNull((t) => t.id == treatmentId);

    if (defaultTreatment != null) {
      return defaultTreatment;
    }

    // หาจาก custom treatments
    return await _databaseService.getTreatment(treatmentId);
  }

  /// คำนวณระยะเวลาทั้งหมดของ session
  Future<Duration> calculateSessionDuration(List<String> treatmentIds) async {
    int totalSeconds = 0;

    for (final treatmentId in treatmentIds) {
      final treatment = await getTreatment(treatmentId);
      if (treatment != null) {
        totalSeconds += treatment.durationSeconds;
      }
    }

    return Duration(seconds: totalSeconds);
  }

  /// สร้าง summary ของ session
  Future<Map<String, dynamic>> createSessionSummary(
    int painPointId,
    List<String> treatmentIds,
  ) async {
    final painPointName = await getPainPointName(painPointId);
    final treatments = <Treatment>[];
    int totalDuration = 0;

    for (final treatmentId in treatmentIds) {
      final treatment = await getTreatment(treatmentId);
      if (treatment != null) {
        treatments.add(treatment);
        totalDuration += treatment.durationSeconds;
      }
    }

    return {
      'painPointName': painPointName,
      'treatments': treatments,
      'totalDurationSeconds': totalDuration,
      'totalDurationFormatted':
          _formatDuration(Duration(seconds: totalDuration)),
    };
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes} นาที ${seconds} วินาที';
    } else {
      return '${seconds} วินาที';
    }
  }

  /// สุ่มข้อความสำหรับ notification (เพิ่มความหลากหลาย)
  String getRandomMotivationalMessage() {
    final messages = [
      'มาออกกำลังกายกันเถอะ! 💪',
      'ถึงเวลาดูแลสุขภาพแล้ว! 🌟',
      'พักหน้าจอสักครู่ มาขยับกันดีกว่า! 🤸‍♀️',
      'แค่ 2-3 นาที จะช่วยให้สดชื่นขึ้นเยอะ! ✨',
      'ร่างกายต้องการการเคลื่อนไหว! 🏃‍♂️',
      'มาคลายเครียดด้วยการออกกำลังกายกัน! 😌',
      'สุขภาพดีเริ่มจากการดูแลตัวเอง! ❤️',
      'ขยับนิดหน่อย สดชื่นล้นหล่น! 🌈',
    ];

    return messages[_random.nextInt(messages.length)];
  }

  /// สุ่มเลือก emoji สำหรับ pain point
  String getRandomPainPointEmoji(int painPointId) {
    final emojiMap = {
      1: ['🧠', '🤕', '😵'], // ศีรษะ
      2: ['👀', '😴', '💤'], // ตา
      3: ['💆‍♂️', '💆‍♀️', '🤲'], // คอ
      4: ['💪', '🤸‍♀️', '🙆‍♂️'], // บ่าและไหล่
      5: ['🧘‍♂️', '🧘‍♀️', '🤸'], // หลังส่วนบน
      6: ['🦴', '💺', '🪑'], // หลังส่วนล่าง
      7: ['💪', '🤲', '👐'], // แขน/ศอก
      8: ['👋', '✋', '🖐️'], // ข้อมือ/มือ/นิ้ว
      9: ['🦵', '🚶‍♂️', '🚶‍♀️'], // ขา
      10: ['👣', '🦶', '🩴'], // เท้า
    };

    final emojis = emojiMap[painPointId] ?? ['💆'];
    return emojis[_random.nextInt(emojis.length)];
  }

  /// สุ่มเลือกสี gradient สำหรับ UI
  int getRandomGradientIndex() {
    return _random.nextInt(5); // 0-4 ตาม AppColors.gradients
  }

  /// Generate unique session greeting
  String generateSessionGreeting() {
    final timeOfDay = DateTime.now().hour;
    final greetings = <String>[];

    if (timeOfDay < 12) {
      greetings.addAll([
        'อรุณสวัสดิ์! เริ่มวันใหม่ด้วยการดูแลตัวเอง 🌅',
        'สวัสดีตอนเช้า! มาเริ่มต้นวันด้วยความสดชื่น ☀️',
        'เช้าดี! ร่างกายพร้อมแล้วสำหรับการออกกำลัง 🌱',
      ]);
    } else if (timeOfDay < 17) {
      greetings.addAll([
        'ช่วงกลางวัน พักผ่อนสักครู่กับการออกกำลังกาย ⏰',
        'แวะมาดูแลสุขภาพกลางวันกันเถอะ 🕐',
        'หยุดพักสักครู่ มาขยับร่างกายกัน 🌞',
      ]);
    } else {
      greetings.addAll([
        'ช่วงเย็น เวลาดีสำหรับการผ่อนคลาย 🌆',
        'ใกล้หมดงานแล้ว มาคลายความเมื่อยล้า 🌇',
        'เย็นดี! มาทำให้ร่างกายสดชื่นก่อนกลับบ้าน ✨',
      ]);
    }

    return greetings[_random.nextInt(greetings.length)];
  }
}

import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Treatment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> instructions;

  @HiveField(4)
  int durationSeconds;

  @HiveField(5)
  String category;

  @HiveField(6)
  String? imagePath;

  @HiveField(7)
  String? videoPath;

  @HiveField(8)
  List<String> targetPainPoints;

  @HiveField(9)
  int difficulty; // 1-5

  @HiveField(10)
  bool isDefault;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  @HiveField(13)
  int completedCount;

  Treatment({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.durationSeconds,
    required this.category,
    this.imagePath,
    this.videoPath,
    this.targetPainPoints = const [],
    this.difficulty = 1,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.completedCount = 0,
  });

  factory Treatment.create({
    required String name,
    required String description,
    required List<String> instructions,
    required int durationSeconds,
    required String category,
    String? imagePath,
    String? videoPath,
    List<String>? targetPainPoints,
    int difficulty = 1,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return Treatment(
      id: '${now.millisecondsSinceEpoch}_${name.hashCode}',
      name: name,
      description: description,
      instructions: instructions,
      durationSeconds: durationSeconds,
      category: category,
      imagePath: imagePath,
      videoPath: videoPath,
      targetPainPoints: targetPainPoints ?? [],
      difficulty: difficulty,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );
  }

  Treatment copyWith({
    String? name,
    String? description,
    List<String>? instructions,
    int? durationSeconds,
    String? category,
    String? imagePath,
    String? videoPath,
    List<String>? targetPainPoints,
    int? difficulty,
    bool? isDefault,
    int? completedCount,
  }) {
    return Treatment(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructions: instructions ?? List.from(this.instructions),
      durationSeconds: durationSeconds ?? this.durationSeconds,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      videoPath: videoPath ?? this.videoPath,
      targetPainPoints: targetPainPoints ?? List.from(this.targetPainPoints),
      difficulty: difficulty ?? this.difficulty,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      completedCount: completedCount ?? this.completedCount,
    );
  }

  void incrementCompletedCount() {
    completedCount++;
    save(); // Save to Hive
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes > 0) {
      return '${minutes}นาที ${seconds}วินาทีน';
    }
    return '${seconds}วินาที';
  }

  String get difficultyText {
    switch (difficulty) {
      case 1:
        return 'ง่ายมาก';
      case 2:
        return 'ง่าย';
      case 3:
        return 'ปานกลาง';
      case 4:
        return 'ยาก';
      case 5:
        return 'ยากมาก';
      default:
        return 'ปานกลาง';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'durationSeconds': durationSeconds,
      'category': category,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'targetPainPoints': targetPainPoints,
      'difficulty': difficulty,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedCount': completedCount,
    };
  }

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instructions: List<String>.from(json['instructions']),
      durationSeconds: json['durationSeconds'],
      category: json['category'],
      imagePath: json['imagePath'],
      videoPath: json['videoPath'],
      targetPainPoints: List<String>.from(json['targetPainPoints'] ?? []),
      difficulty: json['difficulty'] ?? 1,
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      completedCount: json['completedCount'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Treatment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Treatment(id: $id, name: $name, duration: ${formattedDuration})';
  }

  // Static method to create default treatments
  static List<Treatment> getDefaultTreatments() {
    final now = DateTime.now();
    return [
      // Neck Treatments
      Treatment(
        id: 'neck_stretch_1',
        name: 'การหมุนคอ',
        description: 'หมุนคอช้าๆ เพื่อลดความเครียดของกล้ามเนื้อคอ',
        instructions: [
          'นั่งหรือยืนตัวตรง',
          'หมุนคอไปทางซ้ายช้าๆ 5 รอบ',
          'หมุนคอไปทางขวาช้าๆ 5 รอบ',
          'ทำซ้ำ 2-3 เซต',
        ],
        durationSeconds: 60,
        category: 'คอและไหล่',
        imagePath: 'assets/images/exercise_illustrations/neck_rotation.png',
        targetPainPoints: ['neck_pain'],
        difficulty: 1,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Treatment(
        id: 'neck_stretch_2',
        name: 'การยืดคอข้าง',
        description: 'ยืดกล้ามเนื้อด้านข้างของคอ',
        instructions: [
          'นั่งตัวตรง มือขวาจับที่เก้าอี้',
          'เอียงหัวไปทางซ้าย',
          'ใช้มือซ้ายดึงหัวเบาๆ',
          'ค้างไว้ 15-30 วินาที',
          'สลับข้าง',
        ],
        durationSeconds: 90,
        category: 'คอและไหล่',
        imagePath: 'assets/images/exercise_illustrations/neck_side_stretch.png',
        targetPainPoints: ['neck_pain'],
        difficulty: 2,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      // Shoulder Treatments
      Treatment(
        id: 'shoulder_roll',
        name: 'การหมุนไหล่',
        description: 'หมุนไหล่เพื่อคลายความตึงเครียด',
        instructions: [
          'ยืนหรือนั่งตัวตรง',
          'ยกไหล่ขึ้นหมุนไปข้างหลัง 10 รอบ',
          'หมุนไปข้างหน้า 10 รอบ',
          'ทำทั้งสองข้างพร้อมกัน',
        ],
        durationSeconds: 45,
        category: 'คอและไหล่',
        imagePath: 'assets/images/exercise_illustrations/shoulder_roll.png',
        targetPainPoints: ['shoulder_pain'],
        difficulty: 1,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Treatment(
        id: 'shoulder_stretch',
        name: 'การยืดไหล่',
        description: 'ยืดกล้ามเนื้อไหล่และหลังส่วนบน',
        instructions: [
          'ยืนตัวตรง',
          'ยกแขนขวาข้ามหน้าอก',
          'ใช้มือซ้ายดึงแขนขวาเข้าหาตัว',
          'ค้างไว้ 15-30 วินาที',
          'สลับข้าง',
        ],
        durationSeconds: 75,
        category: 'คอและไหล่',
        imagePath: 'assets/images/exercise_illustrations/shoulder_stretch.png',
        targetPainPoints: ['shoulder_pain'],
        difficulty: 2,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      // Eye Treatments
      Treatment(
        id: 'eye_exercise',
        name: 'การออกกำลังตา',
        description: 'การเคลื่อนไหวลูกตาเพื่อลดอาการเมื่อยล้า',
        instructions: [
          'นั่งตัวตรง',
          'มองขึ้นด้านบน ค้าง 2 วินาที',
          'มองลงด้านล่าง ค้าง 2 วินาที',
          'มองซ้าย-ขวา ค้างข้างละ 2 วินาที',
          'หมุนลูกตาตามเข็มนาฬิกา 5 รอบ',
          'หมุนทวนเข็มนาฬิกา 5 รอบ',
        ],
        durationSeconds: 60,
        category: 'ตา',
        imagePath: 'assets/images/exercise_illustrations/eye_exercise.png',
        targetPainPoints: ['eye_strain'],
        difficulty: 1,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Treatment(
        id: 'blink_exercise',
        name: 'การกะพริบตา',
        description: 'การกะพริบตาช้าๆ เพื่อให้ความชุมชื้นกับตา',
        instructions: [
          'นั่งสบายๆ',
          'กะพริบตาช้าๆ และแรงๆ',
          'ค้างหลับตา 2 วินาที',
          'ลืมตาช้าๆ',
          'ทำซ้ำ 10-15 ครั้ง',
        ],
        durationSeconds: 30,
        category: 'ตา',
        imagePath: 'assets/images/exercise_illustrations/blink_exercise.png',
        targetPainPoints: ['eye_strain'],
        difficulty: 1,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      // Back Treatments
      Treatment(
        id: 'back_stretch',
        name: 'การยืดหลัง',
        description: 'ยืดกล้ามเนื้อหลังส่วนบนและล่าง',
        instructions: [
          'นั่งบนเก้าอี้',
          'เอียงตัวข้างหน้า',
          'ให้แขนห้อยลงตรง',
          'ค้างไว้ 15-30 วินาที',
          'กลับสู่ท่าเริ่มต้นช้าๆ',
        ],
        durationSeconds: 60,
        category: 'หลัง',
        imagePath: 'assets/images/exercise_illustrations/back_stretch.png',
        targetPainPoints: ['back_pain'],
        difficulty: 2,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Treatment(
        id: 'spinal_twist',
        name: 'การบิดกระดูกสันหลัง',
        description: 'บิดตัวเพื่อยืดกล้ามเนื้อหลัง',
        instructions: [
          'นั่งตัวตรงบนเก้าอี้',
          'วางมือขวาบนขาซ้าย',
          'บิดตัวไปทางซ้าย',
          'ค้างไว้ 15-30 วินาที',
          'สลับข้าง',
        ],
        durationSeconds: 90,
        category: 'หลัง',
        imagePath: 'assets/images/exercise_illustrations/spinal_twist.png',
        targetPainPoints: ['back_pain'],
        difficulty: 2,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      // Wrist Treatments
      Treatment(
        id: 'wrist_stretch',
        name: 'การยืดข้อมือ',
        description: 'ยืดกล้ามเนื้อข้อมือและนิ้วมือ',
        instructions: [
          'ยื่นแขนออกข้างหน้า',
          'งอข้อมือขึ้น ฝ่ามือหันออก',
          'ใช้มืออีกข้างดึงนิ้วเข้าหาตัว',
          'ค้างไว้ 15-30 วินาที',
          'สลับข้าง',
        ],
        durationSeconds: 75,
        category: 'แขนและมือ',
        imagePath: 'assets/images/exercise_illustrations/wrist_stretch.png',
        targetPainPoints: ['wrist_pain'],
        difficulty: 2,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Treatment(
        id: 'hand_exercise',
        name: 'การออกกำลังมือ',
        description: 'การเคลื่อนไหวมือและนิ้วมือ',
        instructions: [
          'กำมือแน่น แล้วคลายออก',
          'ทำ 10 ครั้ง',
          'แยกนิ้วออกให้กว้างที่สุด',
          'ค้างไว้ 5 วินาที แล้วคลาย',
          'ทำ 10 ครั้ง',
        ],
        durationSeconds: 60,
        category: 'แขนและมือ',
        imagePath: 'assets/images/exercise_illustrations/hand_exercise.png',
        targetPainPoints: ['wrist_pain'],
        difficulty: 1,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

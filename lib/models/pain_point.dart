import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class PainPoint extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  String category;
  
  @HiveField(4)
  String? iconPath;
  
  @HiveField(5)
  List<String> relatedTreatmentIds;
  
  @HiveField(6)
  bool isDefault;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime updatedAt;

  PainPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.iconPath,
    this.relatedTreatmentIds = const [],
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PainPoint.create({
    required String name,
    required String description,
    required String category,
    String? iconPath,
    List<String>? relatedTreatmentIds,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return PainPoint(
      id: '${now.millisecondsSinceEpoch}_${name.hashCode}',
      name: name,
      description: description,
      category: category,
      iconPath: iconPath,
      relatedTreatmentIds: relatedTreatmentIds ?? [],
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );
  }

  PainPoint copyWith({
    String? name,
    String? description,
    String? category,
    String? iconPath,
    List<String>? relatedTreatmentIds,
    bool? isDefault,
  }) {
    return PainPoint(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconPath: iconPath ?? this.iconPath,
      relatedTreatmentIds: relatedTreatmentIds ?? List.from(this.relatedTreatmentIds),
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconPath': iconPath,
      'relatedTreatmentIds': relatedTreatmentIds,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PainPoint.fromJson(Map<String, dynamic> json) {
    return PainPoint(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      iconPath: json['iconPath'],
      relatedTreatmentIds: List<String>.from(json['relatedTreatmentIds'] ?? []),
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PainPoint && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PainPoint(id: $id, name: $name, category: $category)';
  }

  // Static method to create default pain points
  static List<PainPoint> getDefaultPainPoints() {
    final now = DateTime.now();
    return [
      PainPoint(
        id: 'neck_pain',
        name: 'ปวดคอ',
        description: 'อาการปวดเมื่อยบริเวณต้นคอและลำคอ',
        category: 'คอและไหล่',
        iconPath: 'assets/icons/neck_pain.png',
        relatedTreatmentIds: ['neck_stretch_1', 'neck_stretch_2', 'neck_massage'],
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      PainPoint(
        id: 'shoulder_pain',
        name: 'ปวดไหล่',
        description: 'อาการปวดเมื่อยบริเวณไหล่และกล้ามเนื้อรอบไหล่',
        category: 'คอและไหล่',
        iconPath: 'assets/icons/shoulder_pain.png',
        relatedTreatmentIds: ['shoulder_roll', 'shoulder_stretch', 'shoulder_massage'],
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      PainPoint(
        id: 'back_pain',
        name: 'ปวดหลัง',
        description: 'อาการปวดเมื่อยบริเวณหลังส่วนบนและหลังส่วนล่าง',
        category: 'หลัง',
        iconPath: 'assets/icons/back_pain.png',
        relatedTreatmentIds: ['back_stretch', 'spinal_twist', 'back_massage'],
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      PainPoint(
        id: 'eye_strain',
        name: 'ปวดตา',
        description: 'อาการเมื่อยล้าและปวดตาจากการใช้คอมพิวเตอร์นาน',
        category: 'ตา',
        iconPath: 'assets/icons/eye_strain.png',
        relatedTreatmentIds: ['eye_exercise', 'blink_exercise', 'focus_shift'],
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      PainPoint(
        id: 'wrist_pain',
        name: 'ปวดข้อมือ',
        description: 'อาการปวดเมื่อยบริเวณข้อมือจากการใช้เมาส์และแป้นพิมพ์',
        category: 'แขนและมือ',
        iconPath: 'assets/icons/wrist_pain.png',
        relatedTreatmentIds: ['wrist_stretch', 'hand_exercise', 'finger_stretch'],
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
import 'package:hive/hive.dart';

part 'pain_point.g.dart';

@HiveType(typeId: 0)
class PainPoint extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String iconPath;

  @HiveField(4)
  final bool isSelected;

  PainPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.isSelected = false,
  });

  PainPoint copyWith({
    int? id,
    String? name,
    String? description,
    String? iconPath,
    bool? isSelected,
  }) {
    return PainPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

// ข้อมูลจุดที่ปวดทั้หมด 10 จุด
class PainPointData {
  static List<PainPoint> getAllPainPoints() {
    return [
      PainPoint(
        id: 1,
        name: 'ศีรษะ',
        description: 'ปวดศีรษะ เครียด',
        iconPath: 'assets/icons/head.png',
      ),
      PainPoint(
        id: 2,
        name: 'ตา',
        description: 'ตาล้า มองหน้าจอนาน',
        iconPath: 'assets/icons/eyes.png',
      ),
      PainPoint(
        id: 3,
        name: 'คอ',
        description: 'ปวดคอ คอแข็ง',
        iconPath: 'assets/icons/neck.png',
      ),
      PainPoint(
        id: 4,
        name: 'บ่าและไหล่',
        description: 'ปวดบ่า ไหล่แข็ง',
        iconPath: 'assets/icons/shoulder.png',
      ),
      PainPoint(
        id: 5,
        name: 'หลังส่วนบน',
        description: 'ปวดหลัง ระหว่างสะบัก',
        iconPath: 'assets/icons/upper_back.png',
      ),
      PainPoint(
        id: 6,
        name: 'หลังส่วนล่าง',
        description: 'ปวดเอว หลังส่วนล่าง',
        iconPath: 'assets/icons/lower_back.png',
      ),
      PainPoint(
        id: 7,
        name: 'แขน/ศอก',
        description: 'ปวดแขน ศอกแข็ง',
        iconPath: 'assets/icons/arms.png',
      ),
      PainPoint(
        id: 8,
        name: 'ข้อมือ/มือ/นิ้ว',
        description: 'ปวดข้อมือ ชาปลายนิ้ว',
        iconPath: 'assets/icons/wrist.png',
      ),
      PainPoint(
        id: 9,
        name: 'ขา',
        description: 'ขาชา เข่าแข็ง',
        iconPath: 'assets/icons/legs.png',
      ),
      PainPoint(
        id: 10,
        name: 'เท้า',
        description: 'เท้าบวม ปวดข้อเท้า',
        iconPath: 'assets/icons/feet.png',
      ),
    ];
  }
}

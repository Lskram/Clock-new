import 'package:hive/hive.dart';

part 'treatment.g.dart';

@HiveType(typeId: 1)
class Treatment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int painPointId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final int durationSeconds;

  @HiveField(5)
  final String? imagePath;

  @HiveField(6)
  final bool isCustom;

  Treatment({
    required this.id,
    required this.painPointId,
    required this.name,
    required this.description,
    required this.durationSeconds,
    this.imagePath,
    this.isCustom = false,
  });

  Treatment copyWith({
    String? id,
    int? painPointId,
    String? name,
    String? description,
    int? durationSeconds,
    String? imagePath,
    bool? isCustom,
  }) {
    return Treatment(
      id: id ?? this.id,
      painPointId: painPointId ?? this.painPointId,
      name: name ?? this.name,
      description: description ?? this.description,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      imagePath: imagePath ?? this.imagePath,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

// ข้อมูลท่าออกกำลังกายทั้งหมด
class TreatmentData {
  static List<Treatment> getAllTreatments() {
    return [
      // ศีรษะ (3 ท่า)
      Treatment(
        id: 'T1',
        painPointId: 1,
        name: 'หายใจลึก ผ่อนคลาย',
        description: 'นั่งตัวตรง หลับตา หายใจเข้า-ออกลึกๆ ผ่อนคลายจิตใจ',
        durationSeconds: 30,
      ),
      Treatment(
        id: 'T2',
        painPointId: 1,
        name: 'กดจุดคลายเครียด',
        description: 'ใช้นิ้วชี้กดจุดระหว่างคิ้วเบาๆ ผ่อนคลายกล้ามเนื้อหน้าผาก',
        durationSeconds: 10,
      ),
      Treatment(
        id: 'T3',
        painPointId: 1,
        name: 'นวดขมับเป็นวงกลม',
        description: 'นวดเบาๆ ที่ขมับเป็นวงกลมทั้งสองข้าง ช่วยผ่อนคลาย',
        durationSeconds: 30,
      ),

      // ตา (3 ท่า)
      Treatment(
        id: 'T4',
        painPointId: 2,
        name: 'พักสายตา หลับลืมตา',
        description: 'หลับตาแน่น 5 วินาที แล้วลืมตา ทำซ้ำ 5 รอบ',
        durationSeconds: 25,
      ),
      Treatment(
        id: 'T5',
        painPointId: 2,
        name: 'กฎ 20-20-20',
        description: 'มองไกลออกไป 20 ฟุต เป็นเวลา 20 วินาที ผ่อนคลายสายตา',
        durationSeconds: 20,
      ),
      Treatment(
        id: 'T6',
        painPointId: 2,
        name: 'กลิ้งลูกตาทุกทิศทาง',
        description: 'กลิ้งลูกตามองบน-ล่าง-ซ้าย-ขวา ช้าๆ เพื่อยืดกล้ามเนื้อตา',
        durationSeconds: 30,
      ),

      // คอ (2 ท่า)
      Treatment(
        id: 'T7',
        painPointId: 3,
        name: 'เคลื่อนไหวคอทุกทิศทาง',
        description: 'ก้มคางแตะอก > เงยหน้า > หันซ้าย > หันขวา ช้าๆ',
        durationSeconds: 40,
      ),
      Treatment(
        id: 'T8',
        painPointId: 3,
        name: 'ยืดคอข้างใช้มือช่วย',
        description: 'เอียงคอไปข้างหนึ่ง ใช้มือกดเบาๆ ค้าง 10 วิ สลับข้าง',
        durationSeconds: 20,
      ),

      // บ่าและไหล่ (3 ท่า)
      Treatment(
        id: 'T9',
        painPointId: 4,
        name: 'ยกไหล่ขึ้น-ลง',
        description: 'ยกไหล่ทั้งสองข้างขึ้นให้สูงสุด แล้วปล่อยลง ทำ 10 ครั้ง',
        durationSeconds: 30,
      ),
      Treatment(
        id: 'T10',
        painPointId: 4,
        name: 'หมุนไหล่ไปหน้า-หลัง',
        description: 'หมุนไหล่ไปข้างหน้า 10 รอบ แล้วย้อนกลับ 10 รอบ',
        durationSeconds: 40,
      ),
      Treatment(
        id: 'T11',
        painPointId: 4,
        name: 'ดันไหล่เข้าหากัน',
        description: 'ดันไหล่ทั้งสองข้างเข้าหากันด้านหลัง ค้าง 5 วิ ทำ 5 ครั้ง',
        durationSeconds: 25,
      ),

      // หลังส่วนบน (3 ท่า)
      Treatment(
        id: 'T12',
        painPointId: 5,
        name: 'ประสานมือยืดไปหน้า',
        description: 'ประสานมือยืดแขนไปข้างหน้า ค้าง 15 วิ ผ่อนคลายหลัง',
        durationSeconds: 30,
      ),
      Treatment(
        id: 'T13',
        painPointId: 5,
        name: 'ยืดแขนข้ามอก',
        description: 'ยืดแขนข้างหนึ่งข้ามอก ใช้มืออีกข้างดึง ค้าง 15 วิ',
        durationSeconds: 15,
      ),
      Treatment(
        id: 'T14',
        painPointId: 5,
        name: 'หมุนลำตัวซ้าย-ขวา',
        description: 'นั่งหมุนลำตัวไปซ้าย-ขวา ช้าๆ เพื่อคลายกล้ามเนื้อหลัง',
        durationSeconds: 35,
      ),

      // หลังส่วนล่าง (2 ท่า)
      Treatment(
        id: 'T15',
        painPointId: 6,
        name: 'โค้งหลังแล้วงอ',
        description: 'โค้งหลังออกข้างหลัง แล้วงอตัวไปข้างหน้า สลับกัน',
        durationSeconds: 40,
      ),
      Treatment(
        id: 'T16',
        painPointId: 6,
        name: 'หมุนเอวเป็นวงกลม',
        description: 'ยืนหมุนเอวเป็นวงกลม ทั้งซ้าย-ขวา ช้าๆ',
        durationSeconds: 30,
      ),

      // แขน/ศอก (2 ท่า)
      Treatment(
        id: 'T17',
        painPointId: 7,
        name: 'งอ-เหยียดแขน',
        description: 'งอแขนแล้วเหยียดตรง สลับทั้งสองข้าง ทำ 10 ครั้ง',
        durationSeconds: 30,
      ),
      Treatment(
        id: 'T18',
        painPointId: 7,
        name: 'หมุนศอกเป็นวงกลม',
        description: 'หมุนศอกเป็นวงกลม ทั้งทิศทางหน้า-หลัง',
        durationSeconds: 25,
      ),

      // ข้อมือ/มือ/นิ้ว (3 ท่า)
      Treatment(
        id: 'T19',
        painPointId: 8,
        name: 'งอ-เหยียดข้อมือ',
        description: 'งอข้อมือขึ้น-ลง ช้าๆ ทั้งสองข้าง ทำ 10 ครั้ง',
        durationSeconds: 30,
      ),
      Treatment(
        id: 'T20',
        painPointId: 8,
        name: 'หมุนข้อมือทั้งสองทาง',
        description: 'หมุนข้อมือทั้งทิศทางขวา-ซ้าย ช้าๆ',
        durationSeconds: 25,
      ),
      Treatment(
        id: 'T21',
        painPointId: 8,
        name: 'กำมือแล้วกาง',
        description: 'กำมือแน่น 5 วิ แล้วกางนิ้วออกให้สุด ทำ 5 ครั้ง',
        durationSeconds: 25,
      ),

      // ขา (2 ท่า)
      Treatment(
        id: 'T22',
        painPointId: 9,
        name: 'ยกเข่าสลับข้าง',
        description: 'นั่งยกเข่าสลับซ้าย-ขวา ทำ 10 ครั้งแต่ละข้าง',
        durationSeconds: 40,
      ),
      Treatment(
        id: 'T23',
        painPointId: 9,
        name: 'เหยียดขาตรงออก',
        description: 'นั่งเหยียดขาตรงออกข้างหน้า สลับข้าง ค้าง 10 วิ',
        durationSeconds: 30,
      ),

      // เท้า (2 ท่า)
      Treatment(
        id: 'T24',
        painPointId: 10,
        name: 'งอ-เหยียดปลายเท้า',
        description: 'งอปลายเท้าขึ้น-ลง ช้าๆ ทั้งสองข้าง',
        durationSeconds: 30,
      ),
      Treatment(
        id: 'T25',
        painPointId: 10,
        name: 'หมุนข้อเท้าเป็นวงกลม',
        description: 'หมุนข้อเท้าเป็นวงกลม ทั้งทิศทางซ้าย-ขวา',
        durationSeconds: 35,
      ),
    ];
  }

  static List<Treatment> getTreatmentsByPainPoint(int painPointId) {
    return getAllTreatments()
        .where((t) => t.painPointId == painPointId)
        .toList();
  }
}

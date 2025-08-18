import 'package:flutter/material.dart';

class AlarmInfo {
  int? id;
  DateTime alarmDateTime;
  String description;
  bool isActive;
  List<Color>? gradientColors;
  int? gradientColorIndex; // เพิ่มสำหรับเก็บใน database

  AlarmInfo({
    this.id,
    required this.alarmDateTime,
    required this.description,
    this.isActive = true,
    this.gradientColors,
    this.gradientColorIndex,
  });

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
    id: json['id'],
    description: json['title'],
    alarmDateTime: DateTime.parse(json['alarmDateTime']),
    isActive: json['pending'] == 1, // แปลง int เป็น bool
    gradientColorIndex: json['gradientColorIndex'],
  );

  // เพิ่ม toMap method สำหรับแปลงเป็น Map เพื่อเก็บใน database
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': description, // ใช้ description เป็น title
    'alarmDateTime': alarmDateTime.toIso8601String(),
    'pending': isActive ? 1 : 0, // แปลง bool เป็น int
    'gradientColorIndex': gradientColorIndex,
  };
}
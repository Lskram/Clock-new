import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ClockViews extends StatefulWidget {
  final double size;

  const ClockViews({super.key, required this.size});

  @override
  State<ClockViews> createState() => _ClockViewsState();
}

class _ClockViewsState extends State<ClockViews> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // เพิ่ม Timer เพื่อให้นาฬิกาเคลื่อนไหว
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Transform.rotate(
          angle: -pi / 2,
          child: CustomPaint(painter: ClockPainter()),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  var dateTime = DateTime.now();

  @override
  void paint(Canvas canvas, Size size) {
    // ค่าของรัศมีนาฬิกา
    var centerX = size.width / 2;
    var centerY = size.width / 2;
    var center = Offset(centerX, centerY);
    var radius = min(centerX, centerY);

    // ค่าวงกลมแรก
    var fillBrush = Paint()..color = Color(0XFF444974);

    // ค่าเส้นขอบวงกลม
    var outlineBrush = Paint()
      ..color = Color(0XFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 20;

    // ค่าจุดกลางของนาฬิกา (เปลี่ยนชื่อจาก centerFillBrush เป็น centerDotBrush)
    var centerDotBrush = Paint()..color = Color(0XFFEAECFF);

    // ค่าเวลาเข็มยาววินาที
    var secHandBrush = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / 60;

    // ค่าเวลาเข็มกลางนาที
    var minHandBrush = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFF748EF6), Color(0xFF77DDFF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / 30;

    // ค่าเวลาเข็มสั้นชั่วโมง
    var hourHandBrush = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFFEA74AB), Color(0xFFC279FB)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / 24;

    // สร้าง dashBrush สำหรับเส้นปกติ
    var dashBrush = Paint()
      ..color = Color(0XFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // วาดวงกลมพื้นหลังและเส้นขอบ
    canvas.drawCircle(center, radius * 0.75, fillBrush);
    canvas.drawCircle(center, radius * 0.75, outlineBrush);

    //เข็มชั่วโมง - แก้ไขการคำนวณ
    var hourAngle = (dateTime.hour % 12) * 30 + dateTime.minute * 0.5;
    var hourHandX = centerX + radius * 0.4 * cos(hourAngle * pi / 180);
    var hourHandY = centerY + radius * 0.4 * sin(hourAngle * pi / 180);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    //เข็มนาที - แก้ไข centerY
    var minHandX = centerX + radius * 0.6 * cos(dateTime.minute * 6 * pi / 180);
    var minHandY = centerY + radius * 0.6 * sin(dateTime.minute * 6 * pi / 180);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    //เข็มวินาที - แก้ไข centerY
    var secHandX = centerX + radius * 0.6 * cos(dateTime.second * 6 * pi / 180);
    var secHandY = centerY + radius * 0.6 * sin(dateTime.second * 6 * pi / 180);
    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    // วาดจุดกลาง
    canvas.drawCircle(center, radius * 0.12, centerDotBrush);

    // วาดเส้นขีดบอกเวลา - แก้ไขการคำนวณ
    var outerRadius = radius * 0.75;
    var innerRadius = radius * 0.65;
    for (var i = 0; i < 360; i += 30) { // เปลี่ยนจาก 12 เป็น 30 เพื่อให้ได้ 12 เส้น
      var x1 = centerX + outerRadius * cos(i * pi / 180);
      var y1 = centerY + outerRadius * sin(i * pi / 180);
      var x2 = centerX + innerRadius * cos(i * pi / 180);
      var y2 = centerY + innerRadius * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
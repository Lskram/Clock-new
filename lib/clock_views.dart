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
  Timer? _timer; // เพิ่ม nullable Timer

  @override
  void initState() {
    super.initState();
    // เริ่มต้น timer และเก็บ reference ไว้
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) { // ตรวจสอบว่า widget ยังอยู่หรือไม่
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // ยกเลิก timer เมื่อ widget ถูกทำลาย
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
      ..strokeWidth = 16;

    // ค่าจุดกลางของนาฬิกา
    var centerFillBrush = Paint()..color = Color(0XFFEAECFF);

    // ค่าเวลาเข็มยาววินาที
    var secHandBrush = Paint()
      ..color = Colors.orange
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    // ค่าเวลาเข็มกลางนาที
    var minHandBrush = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFF748EF6), Color(0xFF77DDFF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    // ค่าเวลาเข็มสั้นชั่วโมง
    var hourHandBrush = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFFEA74AB), Color(0xFFC279FB)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16;

    // สร้าง dashBrush สำหรับเส้นปกติ
    var dashBrush = Paint()
      ..color = Color(0XFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;

    // สร้าง majorTickBrush สำหรับเส้นทุก 5 นาที (เด่นกว่า)
    var majorTickBrush = Paint()
      ..color = Color(0XFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius - 40, fillBrush);
    canvas.drawCircle(center, radius - 40, outlineBrush);

    //สร้างจุดบอกเวลา
    var secHandX = centerX + 60 * cos(dateTime.second * 6 * pi / 180);
    var secHandY = centerX + 60 * sin(dateTime.second * 6 * pi / 180);
    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    //สร้างจุดบอกเวลา
    var minHandX = centerX + 80 * cos(dateTime.minute * 6 * pi / 180);
    var minHandY = centerX + 80 * sin(dateTime.minute * 6 * pi / 180);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    //สร้างจุดบอกเวลา
    var hourHandX =
        centerX +
        80 * cos((dateTime.hour % 12) * 30 + dateTime.minute * 0.5) * pi / 180;
    var hourHandY =
        centerX +
        80 * sin((dateTime.hour % 12) * 30 + dateTime.minute * 0.5) * pi / 180;
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    canvas.drawCircle(center, 16, centerFillBrush);

    // สร้างเส้นขอบนาฬิกา
    var tickInnerRadius = radius - 24;
    var tickOutRadius = radius - 18;
    var majorTickInnerRadius = radius - 24;
    var majorTickOutRadius = radius - 15;

    for (double i = 0; i < 360; i += 3) {
      if (i % 30 == 0) {
        var x1 = centerX + majorTickInnerRadius * cos(i * pi / 180);
        var y1 = centerY + majorTickInnerRadius * sin(i * pi / 180);
        var x2 = centerX + majorTickOutRadius * cos(i * pi / 180);
        var y2 = centerY + majorTickOutRadius * sin(i * pi / 180);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), majorTickBrush);
      } else {
        var x1 = centerX + tickInnerRadius * cos(i * pi / 180);
        var y1 = centerY + tickInnerRadius * sin(i * pi / 180);
        var x2 = centerX + tickOutRadius * cos(i * pi / 180);
        var y2 = centerY + tickOutRadius * sin(i * pi / 180);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
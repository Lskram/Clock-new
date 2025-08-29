import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สถิติการใช้งาน'),
      ),
      body: const Center(
        child: Text(
          'หน้าสถิติ (ยังไม่ได้พัฒนา)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

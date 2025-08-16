import 'package:flutter/material.dart';
import 'package:flutter_application_1/enums.dart';
import 'package:flutter_application_1/views/home_page.dart';
import 'package:flutter_application_1/models/menu_info.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider<MenuInfo>(
        create: (context) => MenuInfo(
          MenuType.clock,
          title: 'Clock',
          imageSource:
              'assets/clock_icon.png', // ⭐ แก้ path ให้ตรงกับ data.dart
        ),
        child: Homepage(), // ⭐ เอา ChangeNotifierProvider ซ้อนออก
      ),
    );
  }
}

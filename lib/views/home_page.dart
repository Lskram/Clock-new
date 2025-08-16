import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/clock_views.dart';
import 'package:flutter_application_1/views/alarm_page.dart';
import 'package:flutter_application_1/models/menu_info.dart';
import 'package:flutter_application_1/enums.dart';
import 'package:flutter_application_1/data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D2F41),
      body: Row(
        children: <Widget>[
          // เมนูด้านซ้าย
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ใช้ data จาก data.dart แทนการ hardcode
              for (int i = 0; i < menuItems.length; i++)
                buildMenubutton(context, menuItems[i]),
            ],
          ),
          // เส้นผ่า
          VerticalDivider(color: Colors.white54, width: 1),
          // เนื้อหาหลัก
          Expanded(
            child: Consumer<MenuInfo>(
              builder: (BuildContext context, MenuInfo value, Widget? child) {
                if (value.menuType == MenuType.clock) {
                  return ClockPage();
                } else if (value.menuType == MenuType.alarm) {
                  return AlarmPage();
                } else {
                  return RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 20),
                      children: <TextSpan>[
                        TextSpan(text: 'Upcoming Tutorial\n'),
                        TextSpan(
                          text: value.title,
                          style: TextStyle(fontSize: 48),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenubutton(BuildContext context, MenuInfo menuInfo) {
    return Consumer<MenuInfo>(
      builder: (context, currentMenuInfo, child) {
        // เช็คว่าเมนูนี้ถูกเลือกหรือไม่
        bool isSelected = currentMenuInfo.menuType == menuInfo.menuType;
        
        return TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topRight: Radius.circular(32))
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
            backgroundColor: isSelected ? Color(0xFF444974) : Colors.transparent,
          ),
          onPressed: () {
            // อัพเดท MenuInfo
            Provider.of<MenuInfo>(context, listen: false).updateMenu(menuInfo);
          },
          child: Column(
            children: <Widget>[
              Image.asset(
                menuInfo.imageSource ?? 'assets/default_icon.png', // ป้องกัน null
                scale: 1.5,
              ),
              SizedBox(height: 16),
              Text(
                menuInfo.title ?? '', // ป้องกัน null
                style: TextStyle(
                  fontFamily: 'avenir',
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// แยก ClockPage ออกเป็น Widget แยก
class ClockPage extends StatelessWidget {
  const ClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var formattedTime = DateFormat('HH:mm').format(now);
    var formattedDate = DateFormat('EEE, d MMM').format(now);
    var timezoneString = now.timeZoneOffset.toString().split('.').first;
    var offsetSign = '';
    if (!timezoneString.startsWith('-')) offsetSign = '+';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวข้อ Clock
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(
              'Clock',
              style: TextStyle(
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          
          // เนื้อหานาฬิกา
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontFamily: 'avenir',
                    color: Colors.white,
                    fontSize: 64,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontFamily: 'avenir',
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: Align(
              alignment: Alignment.center,
              child: ClockViews(
                size: MediaQuery.of(context).size.height / 4,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timezone',
                  style: TextStyle(
                    fontFamily: 'avenir',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Icon(Icons.language_sharp, color: Colors.white),
                    SizedBox(width: 16),
                    Text(
                      'UTC$offsetSign$timezoneString',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
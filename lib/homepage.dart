import 'package:flutter/material.dart';
import 'package:flutter_application_1/clock_views.dart';
import 'package:intl/intl.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var formattedTime = DateFormat('HH:mm').format(now);
    var formattedDate = DateFormat('EEE, d MMM').format(now);
    var timezoneString = now.timeZoneOffset.toString().split('.').first;
    var offsetSign = '';
    if (!timezoneString.startsWith('-')) offsetSign = '+';
    // Removed print statement for production code

    return Scaffold(
      backgroundColor: Color(0xFF2D2F41),
      body: Row(
        children: <Widget>[
          // บา Home ฝั่งซ้าย
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildMenubutton('Clock', 'assets/clock_icon.png'),
              buildMenubutton('Alarm', 'assets/alarm_icon.png'),
              buildMenubutton('Timer', 'assets/timer_icon.png'),
              buildMenubutton('Stopwatch', 'assets/stopwatch_icon.png'),
            ],
          ),
          // เส้นผ่า
          VerticalDivider(color: Colors.white54, width: 1),
          // ข้อมูลนาฬิกา
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        SizedBox(width: 16),
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
            ),
          ),
        ],
      ),
    );
  }

  Padding buildMenubutton(String title, String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextButton(
        onPressed: () {},
        child: Column(
          children: <Widget>[
            Image.asset(image, scale: 1.5),
            SizedBox(height: 16),
            Text(
              title, // Removed unnecessary null check
              style: TextStyle(
                fontFamily: 'avenir',
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
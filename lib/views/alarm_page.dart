import 'package:flutter/material.dart';
import 'package:flutter_application_1/data.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Alarm',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'avenir',
            ),
          ),
          Expanded(
            child: ListView(
              children: alarms
                  .map<Widget>((alarm) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 32),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              alarm.gradientColors ?? [Colors.red, Colors.blue],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (alarm.gradientColors?.last ?? Colors.blue)
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(4, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: [
                                  Icon(
                                    Icons.label,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Office',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'avenir',
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                onChanged: (bool value) {
                                  setState(() {
                                    // Handle switch toggle
                                  });
                                },
                                value: true,
                                activeColor: Colors.white,
                              ),
                            ],
                          ),
                          Text(
                            'Mon-Fri',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'avenir',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '07:00 AM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'avenir',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 36,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })
                  .followedBy([
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 27, 29, 41),
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () {},
                        child: Column(
                          children: <Widget>[
                            Image.asset('assets/add_alarm.png', scale: 1.5),
                            SizedBox(height: 8),
                            Text(
                              'Add Alarm',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'avenir',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ])
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

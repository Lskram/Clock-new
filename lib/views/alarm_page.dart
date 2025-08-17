import 'package:flutter/material.dart';
import 'package:flutter_application_1/data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
  }

  // ขอสิทธิ์การแจ้งเตือน
  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      // ขอสิทธิ์ notifications
      await androidImplementation.requestNotificationsPermission();

      // ขอสิทธิ์ exact alarms
      await androidImplementation.requestExactAlarmsPermission();

      // ตรวจสอบสิทธิ์
      final bool? canScheduleExactAlarms = await androidImplementation
          .canScheduleExactNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              canScheduleExactAlarms == true
                  ? 'Exact alarms permission granted!'
                  : 'Please grant exact alarms permission in settings',
            ),
            backgroundColor: canScheduleExactAlarms == true
                ? Colors.green
                : Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // หัวข้อ + ปุ่มขอสิทธิ์
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alarm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'avenir',
                ),
              ),
              ElevatedButton(
                onPressed: _requestPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text(
                  'Grant Permissions',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
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
                        onPressed: () {
                          scheduleAlarm();
                        },
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

  void scheduleAlarm() async {
    var scheduledNotificationDateTime = DateTime.now().add(
      Duration(seconds: 10),
    );

    // ปรับให้ใช้งานได้กับ API ใหม่
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'alarm_notif',
          'alarm_notif',
          channelDescription: 'Channel for Alarm notification',
          sound: RawResourceAndroidNotificationSound(
            'notification',
          ), // ลบ .mp3 สำหรับ Android
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          importance: Importance.max,
          priority: Priority.high,
        ); // AndroidNotificationDetails

    // เปลี่ยนจาก IOSNotificationDetails เป็น DarwinNotificationDetails
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          sound: 'notification.mp3', // เก็บ .mp3 สำหรับ iOS
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    // ปรับ constructor ให้ใช้ named parameters
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // เปลี่ยนจาก schedule เป็น zonedSchedule และลบ parameter ที่ไม่รองรับ
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Office',
      'Good morning! Time for office.',
      tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // ลบบรรทัดนี้เพราะไม่รองรับในเวอร์ชันใหม่
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

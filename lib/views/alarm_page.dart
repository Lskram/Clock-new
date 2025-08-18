import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/theme_data.dart';
import 'package:flutter_application_1/models/alarm_info.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/alarm_helper.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? _alarmTime;
  late String _alarmTimeString;
  bool _isRepeatSelected = false;
  final AlarmHelper _alarmHelper =
      AlarmHelper(); // à¹€à¸›à¸¥à¸µà¹ˆà¸¢à¸™à¹€à¸›à¹‡à¸™ final
  Future<List<AlarmInfo>>? _alarms;

  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      debugPrint('------database initialized');
      loadAlarms();
    });
    super.initState();
  }

  void loadAlarms() {
    _alarms = _alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // à¸«à¸±à¸§à¸‚à¹‰à¸­ Alarm
          Text(
            'Alarm',
            style: TextStyle(
              fontFamily: 'avenir',
              fontWeight: FontWeight.w700,
              color: CustomColors.primaryTextColor,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 16),

          // à¸£à¸²à¸¢à¸à¸²à¸£ Alarms
          Expanded(
            child: FutureBuilder<List<AlarmInfo>>(
              future: _alarms,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: snapshot.data!
                        .map<Widget>((alarm) {
                          var alarmTime = DateFormat(
                            'hh:mm aa',
                          ).format(alarm.alarmDateTime);
                          var gradientColor =
                              alarm.gradientColors ?? GradientColors.sky;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColor,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColor.last.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: Offset(4, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.label,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          alarm.description ??
                                              'Alarm', // à¹€à¸›à¸¥à¸µà¹ˆà¸¢à¸™à¸ˆà¸²à¸ title à¹€à¸›à¹‡à¸™ description
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'avenir',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      onChanged: (bool value) {
                                        // à¹à¸„à¹ˆ UI à¹€à¸‰à¸¢à¹† à¹„à¸¡à¹ˆà¸•à¹‰à¸­à¸‡à¸—à¸³à¸­à¸°à¹„à¸£ (à¸•à¸²à¸¡à¸—à¸µà¹ˆà¸„à¸¸à¸“à¸‚à¸­)
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      alarmTime,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'avenir',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.white,
                                      onPressed: () {
                                        deleteAlarm(alarm.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        })
                        .followedBy([
                          // à¸›à¸¸à¹ˆà¸¡à¹€à¸žà¸´à¹ˆà¸¡ Alarm à¹ƒà¸«à¸¡à¹ˆ
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: CustomColors.clockBG,
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                              border: Border.all(
                                color: CustomColors.clockOutline,
                                width: 2,
                              ),
                            ),
                            child: MaterialButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              onPressed: () {
                                _alarmTimeString = DateFormat(
                                  'HH:mm',
                                ).format(DateTime.now());
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          padding: const EdgeInsets.all(32),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // à¹à¸ªà¸”à¸‡à¹€à¸§à¸¥à¸² - à¸à¸”à¹à¸¥à¹‰à¸§à¹à¸ªà¸”à¸‡ Time Picker
                                              TextButton(
                                                onPressed: () async {
                                                  var selectedTime =
                                                      await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            TimeOfDay.now(),
                                                      );
                                                  if (selectedTime != null) {
                                                    final now = DateTime.now();
                                                    var selectedDateTime =
                                                        DateTime(
                                                          now.year,
                                                          now.month,
                                                          now.day,
                                                          selectedTime.hour,
                                                          selectedTime.minute,
                                                        );
                                                    _alarmTime =
                                                        selectedDateTime;
                                                    setModalState(() {
                                                      _alarmTimeString =
                                                          DateFormat(
                                                            'HH:mm',
                                                          ).format(
                                                            selectedDateTime,
                                                          );
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  _alarmTimeString,
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),

                                              // Repeat Switch
                                              ListTile(
                                                title: Text('Repeat'),
                                                trailing: Switch(
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      _isRepeatSelected = value;
                                                    });
                                                  },
                                                  value: _isRepeatSelected,
                                                ),
                                              ),

                                              // Sound Option
                                              ListTile(
                                                title: Text('Sound'),
                                                trailing: Icon(
                                                  Icons.arrow_forward_ios,
                                                ),
                                                onTap: () {
                                                  // à¹à¸„à¹ˆ UI à¹€à¸‰à¸¢à¹† à¹„à¸¡à¹ˆà¸•à¹‰à¸­à¸‡à¸—à¸³à¸­à¸°à¹„à¸£
                                                },
                                              ),

                                              // Title Option
                                              ListTile(
                                                title: Text('Title'),
                                                trailing: Icon(
                                                  Icons.arrow_forward_ios,
                                                ),
                                                onTap: () {
                                                  // à¹à¸„à¹ˆ UI à¹€à¸‰à¸¢à¹† à¹„à¸¡à¹ˆà¸•à¹‰à¸­à¸‡à¸—à¸³à¸­à¸°à¹„à¸£
                                                },
                                              ),

                                              SizedBox(height: 16),

                                              // à¸›à¸¸à¹ˆà¸¡ Save
                                              FloatingActionButton.extended(
                                                onPressed: () {
                                                  onSaveAlarm(
                                                    _isRepeatSelected,
                                                  );
                                                },
                                                icon: Icon(Icons.alarm),
                                                label: Text('Save'),
                                                backgroundColor: Colors.blue,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 48,
                                  ),
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
                  );
                }
                return Center(
                  child: Text(
                    'Loading..',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void onSaveAlarm(bool isRepeating) {
    DateTime? scheduleAlarmDateTime;
    if (_alarmTime!.isAfter(DateTime.now())) {
      scheduleAlarmDateTime = _alarmTime;
    } else {
      scheduleAlarmDateTime = _alarmTime!.add(Duration(days: 1));
    }

    var alarmInfo = AlarmInfo(
      alarmDateTime: scheduleAlarmDateTime!,
      description: 'alarm', // à¹ƒà¸Šà¹‰ description à¹à¸—à¸™ title
      gradientColors: GradientColors
          .sky, // à¹ƒà¸Šà¹‰ gradientColors à¹à¸—à¸™ gradientColorIndex
      gradientColorIndex:
          0, // à¹€à¸žà¸´à¹ˆà¸¡à¸šà¸£à¸£à¸—à¸±à¸”à¸™à¸µà¹‰à¹€à¸žà¸·à¹ˆà¸­à¹ƒà¸«à¹‰à¸¡à¸µà¸„à¹ˆà¸² gradientColorIndex
    );
    _alarmHelper.insertAlarm(alarmInfo);

    if (mounted) {
      Navigator.pop(context);
    }
    loadAlarms();
  }

  void deleteAlarm(int? id) {
    if (id != null) {
      _alarmHelper.delete(id);
      loadAlarms();
    }
  }
}

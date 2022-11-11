import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:pet_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/app/data/models/schedule_info.dart';
import 'package:pet_app/app/data/theme_data.dart';
import 'package:dotted_border/dotted_border.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _validate = true;
  final _titleController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  DateTime _timeSetting =
      DateTime(2022, 1, 1, DateTime.now().hour, DateTime.now().minute);

  DateTime? _alarmTime;
  late String _alarmTimeString;
  bool _isRepeatSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Schedule')),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Expanded(
                child: StreamBuilder(
                    stream: readData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong! ${snapshot}');
                      } else if (snapshot.hasData) {
                        final schedules = snapshot.data!;
                        return ListView(
                          children: schedules.map(buildSchedule).followedBy([
                            if (schedules.length < 5)
                              DottedBorder(
                                strokeWidth: 2,
                                color: CustomColors.clockOutline,
                                borderType: BorderType.RRect,
                                radius: Radius.circular(24),
                                dashPattern: [5, 4],
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: CustomColors.clockBG,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24)),
                                  ),
                                  child: MaterialButton(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                    onPressed: () {
                                      _alarmTimeString = DateFormat('HH:mm')
                                          .format(DateTime.now());
                                      showModalBottomSheet(
                                        useRootNavigator: true,
                                        context: context,
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24),
                                          ),
                                        ),
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.all(32),
                                                child: Column(
                                                  children: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        var selectedTime =
                                                            await showTimePicker(
                                                          context: context,
                                                          initialTime:
                                                              TimeOfDay.now(),
                                                        );
                                                        if (selectedTime !=
                                                            null) {
                                                          var selectedDateTime =
                                                              DateTime(
                                                                  2022,
                                                                  1,
                                                                  1,
                                                                  selectedTime
                                                                      .hour,
                                                                  selectedTime
                                                                      .minute);
                                                          _timeSetting =
                                                              selectedDateTime;
                                                          setState(() {
                                                            _alarmTimeString =
                                                                DateFormat(
                                                                        'HH:mm')
                                                                    .format(
                                                                        selectedDateTime);
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        _alarmTimeString,
                                                        style: TextStyle(
                                                            fontSize: 32),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      title: Text('Repeat'),
                                                      trailing: Switch(
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _isRepeatSelected =
                                                                value;
                                                          });
                                                        },
                                                        value:
                                                            _isRepeatSelected,
                                                      ),
                                                    ),
                                                    TextField(
                                                      controller:
                                                          _titleController,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText: 'Title',
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    TextField(
                                                      controller:
                                                          _weightController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration: InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          hintText:
                                                              'Enter amount of food (gam)',
                                                          errorText: _validate
                                                              ? null
                                                              : 'Value Can\'t Be Empty'),
                                                    ),
                                                    SizedBox(height: 5),
                                                    ElevatedButton.icon(
                                                        onPressed: () {
                                                          if (_weightController
                                                              .text
                                                              .isNotEmpty) {
                                                            createUser();
                                                            setState(() =>
                                                                _validate =
                                                                    true);
                                                            _weightController
                                                                .clear();
                                                            _titleController
                                                                .clear();
                                                          } else {
                                                            setState(() =>
                                                                _validate =
                                                                    false);
                                                          }
                                                        },
                                                        icon: Icon(Icons.alarm),
                                                        label: Text('Save')),
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
                                        Image.asset(
                                          'assets/add_alarm.png',
                                          scale: 1.5,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add Schedule',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'avenir'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
                              Center(
                                  child: Text(
                                'Only 5 alarms allowed!',
                                style: TextStyle(color: Colors.white),
                              )),
                          ]).toList(),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              )
            ])));
  }

  Widget buildSchedule(ScheduleInfo schedule) {
    var alarmTime = DateFormat('hh:mm aa').format(schedule.timeSetting);
    var gradientColor = GradientTemplate.gradientTemplate[1].colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColor,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColor.last.withOpacity(0.4),
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
                children: <Widget>[
                  Icon(
                    Icons.label,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    schedule.title,
                    style: TextStyle(color: Colors.white, fontFamily: 'avenir'),
                  ),
                ],
              ),
              Switch(
                value: schedule.status,
                onChanged: (bool value) {
                  final docUser = FirebaseFirestore.instance
                      .collection('users')
                      .doc(schedule.id);
                  docUser.update({'status': value});
                },
                activeColor: Colors.white,
              ),
            ],
          ),
          Text(
            'Weight: ${schedule.weight} gam',
            style: TextStyle(color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                alarmTime,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'avenir',
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
              IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.white,
                  onPressed: () {
                    final docUser = FirebaseFirestore.instance
                        .collection('users')
                        .doc(schedule.id);
                    docUser.delete();
                  }),
            ],
          ),
          Text(
            schedule.isRepeating == true ? 'Everyday' : '',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future createUser() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    final user = ScheduleInfo(
        id: docUser.id,
        timeSetting: _timeSetting,
        isRepeating: _isRepeatSelected,
        title: _titleController.text,
        weight: int.parse(_weightController.text));
    final json = user.toJson();
    await docUser.set(json);
    Navigator.pop(context);
  }

  Stream<List<ScheduleInfo>> readData() => FirebaseFirestore.instance
      .collection('users')
      .orderBy('timeSetting', descending: false)
      .snapshots()
      .map((snapshort) => snapshort.docs
          .map((doc) => ScheduleInfo.fromJson(doc.data()))
          .toList());
}

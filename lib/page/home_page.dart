import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:pet_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/app/data/models/schedule_info.dart';
import 'package:pet_app/app/data/theme_data.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _maxFoodController = TextEditingController();
  bool _maxFoodValidate = true;
  bool _validate = true;
  var maxFood = "0";

  void pushTask(String weight) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("hand_push");
    await ref.set({"push": weight});
    print("succesed push");
  }

  void setMaxFood() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('pet_app_demo/maxfood').get();
    if (snapshot.exists) {
      maxFood = snapshot.value.toString();
    } else {
      print('No data available.');
      maxFood = "0";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      final validate = _controller.text.isNotEmpty;
      final maxFoodValidate = _maxFoodController.text.isNotEmpty;
      setState(() {
        _maxFoodValidate = maxFoodValidate;
        _validate = validate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSchedule(),
              Container(
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color.fromRGBO(52, 73, 94, 1.0))),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: _maxFoodController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Set max food',
                            border: InputBorder.none,
                            errorText: _maxFoodValidate
                                ? null
                                : 'Can\'t empty this feild'),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: _maxFoodValidate
                            ? () {
                                if (_maxFoodController.text.isEmpty) {
                                  setState(() {
                                    _maxFoodValidate = false;
                                  });
                                  return;
                                }
                                //TODO
                                DatabaseReference ref = FirebaseDatabase
                                    .instance
                                    .ref("pet_app_demo");
                                ref.update(
                                    {"maxfood": _maxFoodController.text});
                                _maxFoodController.clear();
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  _maxFoodValidate = true;
                                });
                              }
                            : () {
                                setState(() {
                                  _maxFoodValidate = false;
                                });
                              },
                        child: const Text("Set"))
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Color.fromRGBO(52, 73, 94, 1.0))),
                child: TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "Weight (gam)",
                      errorText: _validate ? null : 'Can\'t empty this feild'),
                  keyboardType: TextInputType.number,
                  controller: _controller,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: ElevatedButton(
                  child: const Text(
                    'Push',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: _validate
                      ? () {
                          if (_controller.text.isEmpty) {
                            setState(() {
                              _validate = false;
                            });
                            return;
                          }
                          pushTask(_controller.text);
                          DateTime time = DateTime.now();
                          String timeString = time.toIso8601String();
                          final docUser = FirebaseFirestore.instance
                              .collection('button')
                              .doc('my-button');
                          docUser.update({
                            'status': true,
                            'timeSetting': timeString,
                            'weight': int.parse(_controller.text)
                          });
                          _controller.clear();
                          FocusManager.instance.primaryFocus?.unfocus();
                          setState(() {
                            _validate = true;
                          });
                        }
                      : () {
                          setState(() {
                            _validate = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 200),
                    shape: const CircleBorder(),
                    backgroundColor: Color.fromRGBO(52, 73, 94, 1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSchedule() {
    var gradientColor = GradientTemplate.gradientTemplate[0].colors;
    var alarmTime = DateFormat('hh:mm aa').format(DateTime.now());
    setMaxFood();
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('pet_app_demo/maxfood');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      maxFood = data.toString();
      print(maxFood);
    });
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
        child: StreamBuilder(
            stream: readData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                alarmTime = "None";
              } else if (snapshot.hasData) {
                final schedules = snapshot.data!;
                if (schedules.length != 0) {
                  ScheduleInfo nextSchedule = schedules[0];
                  var now = DateTime.now().hour * 60 + DateTime.now().minute;
                  var i = 0;
                  bool flag = false;
                  for (final e in schedules) {
                    print(e.timeSetting);
                  }
                  for (i = schedules.length - 1; i >= 0; i--) {
                    if (schedules[i].status == true) {
                      if ((schedules[i].timeSetting.hour * 60 +
                              schedules[i].timeSetting.minute) >
                          now) {
                        flag = true;
                        break;
                      }
                    }
                  }
                  if (flag == true) {
                    nextSchedule = schedules[i];
                  } else {
                    nextSchedule = schedules[schedules.length - 1];
                  }
                  alarmTime =
                      DateFormat('hh:mm aa').format(nextSchedule.timeSetting);
                } else {
                  alarmTime = "None";
                }
              }
              return Column(
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
                            'Container Info',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'avenir'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Next schedule: ${alarmTime}",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'avenir',
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Max food: ${maxFood} gam',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }));
  }

  Stream<List<ScheduleInfo>> readData() => FirebaseFirestore.instance
      .collection('users')
      .orderBy('timeSetting', descending: true)
      .snapshots()
      .map((snapshort) => snapshort.docs
          .map((doc) => ScheduleInfo.fromJson(doc.data()))
          .toList());
}

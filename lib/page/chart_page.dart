import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_app/app/data/models/chart_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:pet_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_app/app/data/models/schedule_info.dart';
import 'package:pet_app/app/data/theme_data.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:get/get.dart';

class ChartBar extends StatefulWidget {
  int counter = 0;
  @override
  ChartBarState createState() {
    return ChartBarState();
  }
}

class ChartBarState extends State<ChartBar> {
  Future<List<OrderStats>> getOrderStats(int counter) {
    final calDate = DateTime.now().subtract(Duration(days: counter));
    String date1 = calDate.year.toString() +
        '-' +
        calDate.month.toString() +
        '-' +
        calDate.day.toString() +
        ' ' +
        '00:00:00';
    String date2 = calDate.year.toString() +
        '-' +
        calDate.month.toString() +
        '-' +
        (calDate.day + 1).toString() +
        ' ' +
        '00:00:00';
    print(date1);
    print(date2);
    return FirebaseFirestore.instance
        .collection('history')
        .orderBy('time')
        .where('time', isGreaterThanOrEqualTo: date1
            // DateTime(calDate.year, calDate.month, calDate.day
            )
        .where('time', isLessThanOrEqualTo: date2
            // DateTime(calDate.year, calDate.month, calDate.day + 1)
            )
        .get()
        .then((querySnapshot) => querySnapshot.docs
            .asMap()
            .entries
            .map((e) => OrderStats.fromSnapshot(e.value, e.key))
            .toList());
  }

  // Variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chart'),
      ),
      body: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.blueGrey,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () => setState(
                                    () {
                                      print('set');
                                      widget.counter++;
                                    },
                                  ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              )),
                          Text(
                            '${DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: widget.counter)))}',
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.counter == 0
                                      ? print('counter at 0')
                                      : widget.counter--;
                                });
                              },
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ))),
            FutureBuilder(
              future: getOrderStats(widget.counter),
              builder: (BuildContext context,
                  AsyncSnapshot<List<OrderStats>> snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    height: 250,
                    padding: const EdgeInsets.all(10),
                    child: CustomBarChart(orderStats: snapshot.data!),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              },
            ),
            // add here
            FutureBuilder(
              future: getOrderStats(widget.counter),
              builder: (BuildContext context,
                  AsyncSnapshot<List<OrderStats>> snapshot) {
                if (snapshot.hasData) {
                  return buildSchedule(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSchedule(List<OrderStats> finalList) {
    int total = 0;
    for (int i = 0; i < finalList.length; i++) {
      total += finalList[i].weight;
    }
    var gradientColor = GradientTemplate.gradientTemplate[1].colors;
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(52, 73, 94, 1.0),
        boxShadow: [
          BoxShadow(
            color: gradientColor.last.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 2,
            offset: Offset(4, 4),
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(8)),
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
                    "Info",
                    style: TextStyle(color: Colors.white, fontFamily: 'avenir'),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'Total Amount: ${total} gam',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'avenir',
                fontSize: 24,
                fontWeight: FontWeight.w700),
          ),
          Text(
            'Time(s): ${finalList.length}',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'avenir',
                fontSize: 24,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class CustomBarChart extends StatelessWidget {
  const CustomBarChart({
    Key? key,
    required this.orderStats,
  }) : super(key: key);

  final List<OrderStats> orderStats;

  @override
  Widget build(BuildContext context) {
    final finalList = <OrderStats>[];
    if (orderStats.length != 0) {
      print('Join Chart');
      finalList.add(orderStats[0]);
      int count = 0;
      for (int i = 1; i < orderStats.length; i++) {
        if (orderStats[i].dateTime.hour == finalList[count].dateTime.hour) {
          finalList[count].weight += orderStats[i].weight;
        } else {
          finalList.add(orderStats[i]);
          count++;
        }
      }
    }
    List<charts.Series<OrderStats, String>> series = [
      charts.Series(
        id: 'id',
        data: finalList,
        domainFn: (series, _) =>
            DateFormat.H().format(series.dateTime).toString(),
        measureFn: (series, _) => series.weight,
        colorFn: (series, _) => series.barColor!,
      )
    ];
    return charts.BarChart(
      series,
      animate: true,
    );
  }
}

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
    return FirebaseFirestore.instance
        .collection('history')
        .orderBy('time')
        .where('time',
            isGreaterThanOrEqualTo:
                DateTime(calDate.year, calDate.month, calDate.day))
        .where('time',
            isLessThanOrEqualTo:
                DateTime(calDate.year, calDate.month, calDate.day + 1))
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
              // future: orderStatsController.stats.value,
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
            )
          ],
        ),
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
    List<charts.Series<OrderStats, String>> series = [
      charts.Series(
        id: 'id',
        data: orderStats,
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

  Widget switchDate() {
    return Container();
  }
}

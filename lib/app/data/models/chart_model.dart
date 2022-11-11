import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderStats {
  final DateTime dateTime;
  final int index;
  final int weight;
  charts.Color? barColor;

  OrderStats({
    required this.dateTime,
    required this.index,
    required this.weight,
    this.barColor,
  }) {
    barColor = charts.ColorUtil.fromDartColor(Colors.black);
  }

  factory OrderStats.fromSnapshot(DocumentSnapshot snap, int index) {
    return OrderStats(
        dateTime: snap['time'].toDate(),
        // dateTime: DateTime.parse(snap['time']),
        index: index,
        weight: snap['weight']);
  }

  static final List<OrderStats> data = [
    OrderStats(dateTime: DateTime.now(), index: 2, weight: 1000),
    OrderStats(dateTime: DateTime.now(), index: 3, weight: 1100),
    OrderStats(dateTime: DateTime.now(), index: 4, weight: 900),
    OrderStats(dateTime: DateTime.now(), index: 5, weight: 850),
    OrderStats(dateTime: DateTime.now(), index: 6, weight: 1000),
    OrderStats(dateTime: DateTime.now(), index: 7, weight: 800),
    OrderStats(dateTime: DateTime.now(), index: 8, weight: 1200)
  ];
}

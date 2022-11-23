import 'dart:ffi';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderStats {
  final DateTime dateTime;
  int weight;
  charts.Color? barColor;

  OrderStats({
    required this.dateTime,
    required this.weight,
    this.barColor,
  }) {
    barColor = charts.ColorUtil.fromDartColor(Colors.black);
  }

  factory OrderStats.fromSnapshot(DocumentSnapshot snap, int index) {
    return OrderStats(
        dateTime: DateTime.parse(snap['time']), weight: snap['weight'].toInt());
  }
}

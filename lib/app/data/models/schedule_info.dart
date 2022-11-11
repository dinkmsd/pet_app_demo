class ScheduleInfo {
  String id;
  String title;
  DateTime timeSetting;
  bool status;
  bool isRepeating;
  int weight;

  ScheduleInfo(
      {this.id = "",
      this.title = "",
      required this.timeSetting,
      required this.isRepeating,
      this.status = true,
      required this.weight});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'timeSetting': timeSetting.toIso8601String(),
        'status': status,
        'isRepeating': isRepeating,
        'weight': weight
      };

  static ScheduleInfo fromJson(Map<String, dynamic> json) => ScheduleInfo(
      id: json["id"],
      title: json["title"],
      timeSetting: DateTime.parse(json["timeSetting"]),
      status: json["status"],
      isRepeating: json["isRepeating"],
      weight: json["weight"]);
}

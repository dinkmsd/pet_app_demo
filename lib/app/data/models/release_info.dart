class ReleaseFood {
  String id;
  DateTime timeSetting;
  bool status;
  int weight;

  ReleaseFood(
      {this.id = "",
      required this.timeSetting,
      this.status = true,
      required this.weight});

  Map<String, dynamic> toJson() => {
        'id': id,
        'timeSetting': timeSetting.toIso8601String(),
        'status': status,
        'weight': weight
      };

  static ReleaseFood fromJson(Map<String, dynamic> json) => ReleaseFood(
      id: json["id"],
      timeSetting: DateTime.parse(json["timeSetting"]),
      status: json["status"],
      weight: json["weight"]);
}

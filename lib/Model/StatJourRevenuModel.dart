class StatJourRevenuModel {
  final String category;
  final int value;

  StatJourRevenuModel({required this.category, required this.value});

  factory StatJourRevenuModel.fromMap(Map<String, dynamic> json) =>
      StatJourRevenuModel(category: json["category"], value: json["value"]);

  Map<String, dynamic> toMap() => {"category": category, "value": value};
}

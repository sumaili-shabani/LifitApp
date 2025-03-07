class PieData {
  final String category;
  final double value;

  PieData({required this.category, required this.value});

  factory PieData.fromJson(Map<String, dynamic> json) {
    return PieData(
      category: json['category'],
      value: (json['value'] as num).toDouble(),
    );
  }
}

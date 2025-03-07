class ChartData {
  final String category;
  final double value;

  ChartData({required this.category, required this.value});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      category: json['category'],
      value: (json['value'] as num).toDouble(),
    );
  }
}

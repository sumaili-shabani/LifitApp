class BarData {
  final String category;
  final double value;

  BarData({required this.category, required this.value});

  factory BarData.fromJson(Map<String, dynamic> json) {
    return BarData(
      category: json['category'],
      value: (json['value'] as num).toDouble(), // Convertit en `double`
    );
  }
}

class Place {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': {'latitude': latitude, 'longitude': longitude},
    };
  }

  static Place fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['location']['latitude'],
      longitude: json['location']['longitude'],
    );
  }
}

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Driver {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final String carModel;
  final String carColor;
  final String plateNumber;
  final double rating;
  final double distanceFromUser;

  LatLng get position => LatLng(latitude, longitude);

  Driver({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
    required this.carModel,
    required this.carColor,
    required this.plateNumber,
    required this.distanceFromUser,
    this.rating = 4.5,
  });
}

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideHistory {
  final String id;
  final String driverId;
  final String driverName;
  final String carModel;
  final double rating;
  final DateTime timestamp;
  final double price;
  final LatLng pickup;
  final LatLng destination;
  final String status;

  RideHistory({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.carModel,
    required this.rating,
    required this.timestamp,
    required this.price,
    required this.pickup,
    required this.destination,
    required this.status,
  });
}

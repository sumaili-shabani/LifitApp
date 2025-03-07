import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutePoint {
  final LatLng position;
  final String name;
  final int speedMs; // Vitesse en millisecondes entre ce point et le suivant

  const RoutePoint({
    required this.position,
    required this.name,
    required this.speedMs,
  });
}

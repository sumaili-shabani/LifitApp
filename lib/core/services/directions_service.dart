import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsResult {
  final List<LatLng> polylinePoints;
  final LatLngBounds bounds;
  final String startAddress;
  final String endAddress;
  final String distance;
  final String duration;
  final String durationText;

  DirectionsResult({
    required this.polylinePoints,
    required this.bounds,
    required this.startAddress,
    required this.endAddress,
    required this.distance,
    required this.duration,
    required this.durationText,
  });
}

class DirectionsService {
  final _polylinePoints = PolylinePoints();
  static const _apiKey = 'AIzaSyC6-UOrf9k9HrsGHwQt8EW6EsYqi58GFHo';

  Future<DirectionsResult?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        _apiKey,
        PointLatLng(origin.latitude, origin.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isEmpty) return null;

      final points = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      double minLat = origin.latitude;
      double maxLat = origin.latitude;
      double minLng = origin.longitude;
      double maxLng = origin.longitude;

      for (var point in points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      String formatDistance(String? distance) {
        if (distance == null) return 'Distance inconnue';
        final parts = distance.split(' ');
        if (parts.length >= 2) {
          final value = double.tryParse(parts[0]);
          if (value != null) {
            return '${value.toStringAsFixed(1)} km';
          }
        }
        return distance;
      }

      String formatDuration(String? duration) {
        if (duration == null) return 'Durée inconnue';
        final parts = duration.split(' ');
        if (parts.length >= 2) {
          final value = int.tryParse(parts[0]);
          if (value != null) {
            if (duration.contains('mins')) {
              return '$value min';
            } else if (duration.contains('hours')) {
              return '$value h ${parts.length > 2 ? '${parts[2]} min' : ''}';
            }
          }
        }
        return duration;
      }

      final formattedDistance = formatDistance(result.distance);
      final formattedDuration = formatDuration(result.duration);

      return DirectionsResult(
        polylinePoints: points,
        bounds: bounds,
        startAddress: result.startAddress ?? 'Point de départ',
        endAddress: result.endAddress ?? 'Destination',
        distance: formattedDistance,
        duration: formattedDuration,
        durationText: formattedDuration,
      );
    } catch (e) {
      print('Erreur lors de l\'obtention des directions: $e');
      return null;
    }
  }
}

import 'package:google_maps_flutter/google_maps_flutter.dart';

enum TrafficEventType {
  congestion,
  accident,
  construction,
  event,
  roadClosure
}

class TrafficEvent {
  final String id;
  final String description;
  final TrafficEventType type;
  final LatLng location;
  final double speedMultiplier; // Facteur qui affecte la vitesse (0.0 - 1.0)
  final DateTime startTime;
  final DateTime? endTime;

  const TrafficEvent({
    required this.id,
    required this.description,
    required this.type,
    required this.location,
    required this.speedMultiplier,
    required this.startTime,
    this.endTime,
  });

  String get typeIcon {
    switch (type) {
      case TrafficEventType.congestion:
        return '🚗';
      case TrafficEventType.accident:
        return '⚠️';
      case TrafficEventType.construction:
        return '🚧';
      case TrafficEventType.event:
        return '🎉';
      case TrafficEventType.roadClosure:
        return '🚫';
    }
  }

  String get statusDescription {
    if (endTime == null) return 'En cours';
    if (DateTime.now().isAfter(endTime!)) return 'Terminé';
    return 'Jusqu\'à ${endTime!.hour}:${endTime!.minute}';
  }
}

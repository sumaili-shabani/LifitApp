import 'package:google_maps_flutter/google_maps_flutter.dart';

class ZoneStats {
  final String zoneName;
  final LatLng center;
  final int visitCount;
  final double averageSpeed;
  final Map<int, int> hourlyTraffic; // Heure -> Nombre de passages
  final double congestionLevel; // 0.0 - 1.0

  const ZoneStats({
    required this.zoneName,
    required this.center,
    required this.visitCount,
    required this.averageSpeed,
    required this.hourlyTraffic,
    required this.congestionLevel,
  });

  String get trafficStatus {
    if (congestionLevel < 0.3) return 'Fluide';
    if (congestionLevel < 0.6) return 'Modéré';
    if (congestionLevel < 0.8) return 'Dense';
    return 'Très dense';
  }

  String get trafficIcon {
    if (congestionLevel < 0.3) return '🟢';
    if (congestionLevel < 0.6) return '🟡';
    if (congestionLevel < 0.8) return '🟠';
    return '🔴';
  }
}

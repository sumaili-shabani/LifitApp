import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DashedPolyline extends CustomPainter {
  final List<LatLng> points;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  DashedPolyline({
    required this.points,
    this.color = Colors.black,
    this.strokeWidth = 2,
    this.dashLength = 10,
    this.dashSpace = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];

      final dx = end.longitude - start.longitude;
      final dy = end.latitude - start.latitude;
      final distance = _calculateDistance(start, end);

      final numberOfDashes = (distance / (dashLength + dashSpace)).floor();

      for (int j = 0; j < numberOfDashes; j++) {
        final startFraction = j * (dashLength + dashSpace) / distance;
        final endFraction =
            (j * (dashLength + dashSpace) + dashLength) / distance;

        final dashStart = LatLng(
          start.latitude + dy * startFraction,
          start.longitude + dx * startFraction,
        );

        final dashEnd = LatLng(
          start.latitude + dy * endFraction,
          start.longitude + dx * endFraction,
        );

        canvas.drawLine(
          Offset(dashStart.longitude, dashStart.latitude),
          Offset(dashEnd.longitude, dashEnd.latitude),
          paint,
        );
      }
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    final dx = end.longitude - start.longitude;
    final dy = end.latitude - start.latitude;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';

class CarMarkerIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CarMarkerIcon({
    Key? key,
    this.size = 40,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.directions_car,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

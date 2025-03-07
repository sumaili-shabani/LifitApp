import 'package:flutter/material.dart';

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double percentage;

  const ResponsivePadding({required this.child, this.percentage = 0.05});

  @override
  Widget build(BuildContext context) {
    double paddingValue = MediaQuery.of(context).size.width * percentage;

    return Padding(padding: EdgeInsets.all(paddingValue), child: child);
  }
}

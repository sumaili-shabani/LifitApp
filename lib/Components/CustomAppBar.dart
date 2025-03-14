import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final bool showBackButton;
  final PreferredSizeWidget? bottom; // Correction ici ✅

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ConfigurationApp.successColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: title,
        centerTitle: false,
        leading:
            showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
                : null, // Ne s'affiche que si `showBackButton` est true
        actions: actions,
        bottom: bottom, // Correction ici ✅
      ),
    );
  }

  @override
  Size get preferredSize {
    double bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(
      80 + bottomHeight,
    ); // Ajuste la hauteur en fonction du bottom ✅
  }
}

import 'package:flutter/material.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/AmbassadeurWalletPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/MenuChauffeur.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/VehiculePage.dart';
import 'package:lifti_app/View/Pages/MenusPage/ProfilScreen.dart';
import 'package:lifti_app/core/theme/app_theme.dart';

class AmbassadeurApp extends StatefulWidget {
  const AmbassadeurApp({super.key});

  @override
  State<AmbassadeurApp> createState() => _AmbassadeurAppState();
}

class _AmbassadeurAppState extends State<AmbassadeurApp> {
  int _selectedIndex = 0;

  // Liste des écrans du menu
  final List<Widget> _pages = [
    AmbassadeurWalletPage(),
    VehiculePage(),
    MenuChauffeurPage(),
    ProfilScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: "Voiture",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Chauffeur"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

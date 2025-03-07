import 'package:flutter/material.dart';
import 'package:lifti_app/View/Pages/MenusPage/CoursesEnCoursScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/DashboardScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/HistoriqueScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapScreem.dart';
import 'package:lifti_app/View/Pages/MenusPage/ProfilScreen.dart';
import 'package:lifti_app/core/theme/app_theme.dart';

class ChauffeurApp extends StatefulWidget {
  const ChauffeurApp({super.key});

  @override
  State<ChauffeurApp> createState() => _ChauffeurAppState();
}

class _ChauffeurAppState extends State<ChauffeurApp> {
  int _selectedIndex = 0;

  // Liste des écrans du menu
  final List<Widget> _pages = [
    MapChauffeurScreem(),
    DashboardScreen(),
    CoursesEnCoursScreen(),
    HistoriqueScreen(),
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
      body: _pages[_selectedIndex], // Change de page selon l'index sélectionné
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        items: [
           BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Courses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historique",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

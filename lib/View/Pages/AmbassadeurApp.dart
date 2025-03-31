import 'package:flutter/material.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/ChauffeurPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/HistoriqueCourseScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/PassagerMapHomeScreem.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/WalletPage.dart';
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
    // PassagerMapHomeScreem(),
    // HistoriqueCourseScreen(),
    // WalletPage(),
    

    Center(child: Text("Accueil"),),
    Center(child: Text("Voiture")),
   ChauffeurAmbassadeurPage(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Chauffeur",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}




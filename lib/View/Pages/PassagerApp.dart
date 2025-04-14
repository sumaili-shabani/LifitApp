import 'package:flutter/material.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/HistoriqueCourseScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/PassagerMapHomeScreem.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/Recherche/SearchLocation.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/WalletPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/ProfilScreen.dart';

import 'package:lifti_app/core/theme/app_theme.dart';

class PassagerApp extends StatefulWidget {
  const PassagerApp({super.key});

  @override
  State<PassagerApp> createState() => _PassagerAppState();
}

class _PassagerAppState extends State<PassagerApp> {
  int _selectedIndex = 0;

  // Liste des écrans du menu
  final List<Widget> _pages = [
    SearchLocation(),
    HistoriqueCourseScreen(),
    WalletPage(),
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
            label: "Courses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Portefeuille",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}




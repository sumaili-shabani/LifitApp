import 'package:flutter/material.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/ResponsivePadding.dart';
import 'package:lifti_app/View/Components/DynamicBarChart.dart';
import 'package:lifti_app/View/Components/DynamicColumnChart.dart';
import 'package:lifti_app/View/Components/DynamicPieChart.dart';
import 'package:lifti_app/View/Components/StatJurnaliere.dart';
import 'package:lifti_app/View/Pages/MenusPage/AvisClientScreem.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';

import 'package:lifti_app/View/Pages/MenusPage/InfoDashBoardPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/InformationMenu.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/PaiementCommission.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/Statistique/PaieCommissionChart.dart';
import 'package:lifti_app/View/Pages/MenusPage/PetitCourseEnCourse.dart';
import 'package:intl/intl.dart';
import 'package:lifti_app/presentation/pages/intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String dateDuJour = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String avatarUser = "";
  String connected = "";
  int id = 0;
  int idRoleConnected = 0;
  int refConnected = 0;
  String emailConnected = "";

  Future getConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      connected = localStorage.getString('nameConnected')!;
      id = localStorage.getInt('idConnected')!;
      idRoleConnected = localStorage.getInt('idRoleConnected')!;
      refConnected = localStorage.getInt('idConnected')!;
      emailConnected = localStorage.getString('emailConnected')!;
      avatarUser = localStorage.getString('avatarConnected')!;
    });

    // print("connected $connected");
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('nameConnected');
    await prefs.remove('emailConnected');
    await prefs.remove('idRoleConnected');
    await prefs.remove('idConnected');
    await prefs.remove('userConnected');
    await prefs.remove('avatarConnected');
    await prefs.remove('token');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const IntroPage()),
      (route) => false,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConnected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("Tableau de Bord", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.newspaper_outlined, color: Colors.white),
            tooltip: "Savoir plus d'informations",
            onPressed: () {
              Navigator.of(
                context,
              ).push(AnimatedPageRoute(page: InformationMenuScreem()));
            },
          ),
         
          // ✅ Menu déroulant avec bouton Déconnexion
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white,),
            onSelected: (String value) {
              if (value == "logout") {
                // print("Déconnexion...");
                logout();
              } else if (value == "message") {
                // print("Voir les messages...");
               Navigator.of(
                  context,
                ).push(AnimatedPageRoute(page: CorrespondentsPage()));
              } else if (value == "calendar") {
                // print("Voir le calendrier...");
              
              
              } else {
                print("Boom");
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: "message",
                    child: Row(
                      children: [Icon(Icons.chat), Text(" Messagerie")],
                    ),
                  ),
                  // PopupMenuItem(
                  //   value: "calendar",
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.taxi_alert),
                  //       Text(" Commande Taxi"),
                  //     ],
                  //   ),
                  // ),
                  PopupMenuItem(
                    value: "logout",
                    child: Row(
                      children: [
                        Icon(Icons.logout_outlined),
                        Text(" Déconnexion"),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: ResponsivePadding(
          percentage: 0.02,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoDashBoardPage(),
              SizedBox(height: 20),
              Text(
                "Statistiques Par mode de paiement",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DynamicPieChart(),

              StatistiqueJour(),
              SizedBox(height: 20),

              // SizedBox(height: 20),
              // _buildStatistiquesRevenusBonus(),

              //column chart mensuel
              DynamicColumnChart(),

              // _buildGraphiqueRevenus(),
              // SizedBox(height: 20),
              // PetitCourseEnCourse(),
              SizedBox(height: 20),

              // _buildEvaluations(),
              AvisClientScreem(),
              SizedBox(height: 20),
              Text(
                "Statistiques Par mode de paiement",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DynamicBarChart(),

              // mes ajouts commission
              SizedBox(height: 10),
              // liste de paiement de la personne
              SizedBox(height: 300, child: PaiementCommission()),

              PaieCommissionChart(),

              //fin ajouts commissions
            ],
          ),
        ),
      ),
    );
  }

 
}

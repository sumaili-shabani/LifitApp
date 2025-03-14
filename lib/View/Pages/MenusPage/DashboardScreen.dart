import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/ResponsivePadding.dart';
import 'package:lifti_app/View/Components/DynamicBarChart.dart';
import 'package:lifti_app/View/Components/DynamicColumnChart.dart';
import 'package:lifti_app/View/Components/DynamicPieChart.dart';
import 'package:lifti_app/View/Components/StatJurnaliere.dart';
import 'package:lifti_app/View/Pages/MenusPage/AvisClientScreem.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/CommandeTaxi.dart';
import 'package:lifti_app/View/Pages/MenusPage/InfoDashBoardPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/PaiementCommission.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/Statistique/PaieCommissionChart.dart';
import 'package:lifti_app/View/Pages/MenusPage/PetitCourseEnCourse.dart';
import 'package:lifti_app/core/theme/app_theme.dart';
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
          // ✅ Ajout de l'avatar du chauffeur
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 20,
              child: Center(child: Image.asset("assets/images/logo.png")),
            ),
          ),

          // ✅ Menu déroulant avec bouton Déconnexion
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white,),
            onSelected: (String value) {
              if (value == "logout") {
                print("Déconnexion...");
                logout();
              } else if (value == "message") {
                // print("Voir les messages...");
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CorrespondentsPage()),
                );
              } else if (value == "calendar") {
                // print("Voir le calendrier...");
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CommandeTaxiScreem()),
                );
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
                  PopupMenuItem(
                    value: "calendar",
                    child: Row(
                      children: [
                        Icon(Icons.taxi_alert),
                        Text(" Commande Taxi"),
                      ],
                    ),
                  ),
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
              PetitCourseEnCourse(),
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

  // 🟢 2. Statistiques Revenus & Bonus (Affichés en colonne)
  Widget _buildStatistiquesRevenusBonus() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Statistiques du Jour",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildStatRow("Date", dateDuJour, Icons.calendar_today),
            _buildStatRow("Revenus du jour", "\$150", Icons.attach_money),
            _buildStatRow("Bonus Total", "\$25", Icons.card_giftcard),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 🟢 3. Graphique des revenus
  Widget _buildGraphiqueRevenus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Revenus des 5 derniers jours",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, 30),
                    FlSpot(1, 50),
                    FlSpot(2, 40),
                    FlSpot(3, 80),
                    FlSpot(4, 60),
                  ],
                  isCurved: true,
                  color: AppTheme.primaryGreen,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

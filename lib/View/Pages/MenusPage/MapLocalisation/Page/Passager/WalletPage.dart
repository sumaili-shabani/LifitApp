import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';

import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Model/ChauffeurDashBoardModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CourseEnCours.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/EmergencyAlertSheet.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/PaiementCommission.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/PassagerHistoriqueCourse.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/Statistique/DynamicColumnChart.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/Statistique/DynamicPieChart.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/Statistique/PaieCommissionChart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final double totalEarnings = 250.75;
  final int totalRides = 15;
  final double totalDistance = 120.5;
  final double totalPaid = 500.30;

  int userId = 0;

  final List<Map<String, dynamic>> paymentHistory = [
    {
      "chauffeur": "Jean Dupont",
      "course": "Standard",
      "vehicule": "Toyota Prius",
      "destination": "Aéroport",
      "mode": "Carte",
      "date": "12/03/2025",
      "montant": 15.50,
    },
    {
      "chauffeur": "Paul Martin",
      "course": "Luxe",
      "vehicule": "Mercedes E-Class",
      "montant": 35.00,
      "date": "11/03/2025",
      "mode": "Espèces",
      "destination": "Hôpital Heal Africa",
      "depart": "Centre-Ville",
    },
    {
      "chauffeur": "Sophie Bernard",
      "course": "Economique",
      "vehicule": "Toyota Corolla",
      "date": "10/03/2025",
      "montant": 250.00,
      "mode": "Mobile Money",
      "destination": "Université Goma",
      "depart": "Gare Centrale",
    },
  ];

  TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  void showEmergencyBottomSheet(BuildContext context, int userId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EmergencyAlertSheet(userId: userId),
    );
  }

  //voir l'id de la personne connecté
  getIdentifiant() async {
    int? idConnected =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    setState(() {
      userId = idConnected!;
    });
  }

  List<ChauffeurDashBoardModel> dashInfo = [];
  bool isLoading = true;
  int idRole = 0;

  fetchDataDashBoard() async {
    //passager
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    List<dynamic> dataDash = await CallApi.fetchListData(
      'passager_mobile_dashboard/${userId.toInt()}',
    );
    setState(() {
      dashInfo =
          dataDash
              .map((item) => ChauffeurDashBoardModel.fromMap(item))
              .toList();
      isLoading = false;
    });
  }

  //appel historique de courese
  void _showHistoriqueCourse(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75, // 🔥 Prend 75% de la hauteur de l'écran
          child: PassagerHistoriqueCourse(), // Appel du StatefulWidget
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    getIdentifiant();
    fetchDataDashBoard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "${l10n.porteFeuilleClient_titre}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),

        showBackButton: false, // Affiche le bouton retour
        actions: [
          IconButton(
            icon: Icon(Icons.sos, color: Colors.white),
            onPressed: () {
              showEmergencyBottomSheet(context, userId);
            },
            tooltip: "${l10n.send_sos}",
          ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              Navigator.of(
                context,
              ).push(AnimatedPageRoute(page: CorrespondentsPage()));
            },
            tooltip: "${l10n.map_client_discussion}",
          ),
          IconButton(
            icon: Icon(Icons.time_to_leave, color: Colors.white),
            onPressed: () {
              _showHistoriqueCourse(context);
            },
            tooltip: "${l10n.historiqueCourseClient_texte}",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...dashInfo.map(
                (item) => buildSummaryCard(
                  context,
                  double.parse(item.sommePaiementBonus.toString()),
                  int.parse(item.countCourseTermine.toString()),
                  double.parse(item.sumDistanceCourseTermine.toString()),
                  double.parse(item.sommeRetrait.toString()),
                ),
              ),

              SizedBox(height: 10),
              //course passager en cours
              PassagerCourseEnCourse(),

              //fin course passager

              // buildPaymentHistory(paymentHistory),
              SizedBox(height: 20),
              ColumnChartPaiementCourse(),
              SizedBox(height: 10),

              Text(
                "${l10n.porteFeuilleClient_repartition}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DynamicPieChartPaiementCourse(),
          
              SizedBox(height: 10),
              // liste de paiement de la personne
              PaiementCommission(),

              PaieCommissionChart(),

              // buildPaymentPieChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPaymentHistory(List<Map<String, dynamic>> paymentHistory) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        itemCount: paymentHistory.length,
        itemBuilder: (context, index) {
          final item = paymentHistory[index];
          final l10n = AppLocalizations.of(context)!;
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(
                8.0,
              ), // Ajout de padding pour éviter les débordements
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 30,
                  ), // Icône chauffeur
                  SizedBox(width: 8),
                  Expanded(
                    // Empêche le texte de déborder
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_taxi,
                              color: Colors.green,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              // S'adapte à la largeur dispo
                              child: Text(
                                "${item["chauffeur"]} - ${item["course"]}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: Colors.orange,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${l10n.vehicle}: ${item["vehicule"]}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.place, color: Colors.red, size: 18),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${l10n.porteFeuilleClient_de}: ${item["depart"]}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.flag, color: Colors.green, size: 18),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${l10n.porteFeuilleClient_a}: ${item["destination"]}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.payment, color: Colors.purple, size: 18),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${l10n.porteFeuilleClient_paiement}: ${item["mode"]}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.green,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "${item["montant"]} CDF",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "${item["date"]}",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPaymentBarChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: Text("Jours"),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(fromY: 0, toY: 15, color: Colors.blue)],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(toY: 80, color: Colors.orange)],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [BarChartRodData(toY: 40, color: Colors.green)],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentPieChart() {
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 40, color: Colors.blue, title: "Carte"),
            PieChartSectionData(
              value: 30,
              color: Colors.orange,
              title: "Espèces",
            ),
            PieChartSectionData(
              value: 30,
              color: Colors.green,
              title: "Mobile Money",
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryCard(
    BuildContext context,
    double totalEarnings,
    int totalRides,
    double totalDistance,
    double totalPaid,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "${l10n.porteFeuilleClient_bonus}:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              "${totalEarnings.toStringAsFixed(2)} CDF",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildStat(Icons.local_taxi, "${l10n.porteFeuilleClient_course}", totalRides.toString()),
                buildStat(
                  Icons.map,
                  "${l10n.porteFeuilleClient_distance}",
                  "${totalDistance.toStringAsFixed(1)} km",
                ),
                buildStat(
                  Icons.attach_money,
                  "${l10n.porteFeuilleClient_total_payer}",
                  "${totalPaid.toStringAsFixed(0)} CDF",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

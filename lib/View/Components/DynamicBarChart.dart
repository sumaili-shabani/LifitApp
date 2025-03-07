import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/BarData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicBarChart extends StatefulWidget {
  const DynamicBarChart({super.key});

  @override
  State<DynamicBarChart> createState() => _DynamicBarChartState();
}

class _DynamicBarChartState extends State<DynamicBarChart> {
  Future<List<BarData>>? futureData;
  List<Color> availableColors = Colors.primaries; // Couleurs dynamiques

  int refConnected = 0;
  getIdConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    int idUser = localStorage.getInt('idConnected')!;
    setState(() {
      refConnected = idUser;
    });

    // print('id connected: ${refConnected.toInt()}');

    futureData = ApiService.fetchBarData(
      "chauffeur_mobile_stat_paiement_course_mode/${idUser.toInt()}",
    ); // Récupération des données API
  }


  @override
  void initState() {
    super.initState();
    getIdConnected();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<BarData>>(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erreur : ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Aucune donnée disponible"));
                }

                List<BarData> barDataList = snapshot.data!;
                List<BarChartGroupData> barGroups = [];

                for (int i = 0; i < barDataList.length; i++) {
                  barGroups.add(
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: barDataList[i].value.toDouble(),
                          color: availableColors[i % availableColors.length],
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ Bar Chart Responsive
                    AspectRatio(
                      aspectRatio:
                          1.5, // Ajuste la taille pour éviter les espaces inutiles
                      child: BarChart(
                        BarChartData(
                          barGroups: barGroups,
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    barDataList[value.toInt()].category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ), // 🔹 Réduction de l'espace entre le graphe et la légende
                    // ✅ Légende dynamique
                    Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      alignment: WrapAlignment.center,
                      children: List.generate(barDataList.length, (index) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color:
                                    availableColors[index %
                                        availableColors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              barDataList[index].category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

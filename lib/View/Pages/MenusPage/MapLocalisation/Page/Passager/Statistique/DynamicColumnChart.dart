import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/ChartData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColumnChartPaiementCourse extends StatefulWidget {
  const ColumnChartPaiementCourse({super.key});

  @override
  State<ColumnChartPaiementCourse> createState() => _ColumnChartPaiementCourseState();
}

class _ColumnChartPaiementCourseState extends State<ColumnChartPaiementCourse> {
  Future<List<ChartData>>? futureColumnData;

  int refConnected = 0;
  getIdConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    int idUser = localStorage.getInt('idConnected')!;
    setState(() {
      refConnected = idUser;
    });

    // print('id connected: ${refConnected.toInt()}');

    futureColumnData = ApiService.fetchColumnData(
      "passager_mobile_stat_paiement_course_date/${idUser.toInt()}",
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
        child: Container(
          height: MediaQuery.of(context).size.height * 0.45,
          width: MediaQuery.of(context).size.width * 1,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: FutureBuilder<List<ChartData>>(
                future: futureColumnData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Erreur : ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Aucune donnée disponible"));
                  }
          
                  List<ChartData> columnDataList = snapshot.data!;
                  return Column(
                    children: [
                      Text(
                        "Graphique des paiements de courses",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: BarChart(
                          BarChartData(
                            barGroups:
                                columnDataList.map((data) {
                                  return BarChartGroupData(
                                    x: columnDataList.indexOf(data),
                                    barRods: [
                                      BarChartRodData(
                                        toY: data.value.toDouble(),
                                        color:
                                            Colors.primaries[columnDataList
                                                    .indexOf(data) %
                                                Colors.primaries.length],
                                        width: 16,
                                      ),
                                    ],
                                  );
                                }).toList(),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      columnDataList[value.toInt()].category,
                                      style: TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
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

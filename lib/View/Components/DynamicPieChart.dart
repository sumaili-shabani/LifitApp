import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/PieData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicPieChart extends StatefulWidget {
  const DynamicPieChart({super.key});

  @override
  State<DynamicPieChart> createState() => _DynamicPieChartState();
}

class _DynamicPieChartState extends State<DynamicPieChart> {

  Future<List<PieData>>? futureData; // ✅ Déclare sans `late`
  List<Color> availableColors =
      Colors.primaries; // Liste de couleurs dynamiques

   int refConnected = 0;
  getIdConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    int idUser = localStorage.getInt('idConnected')!;
    setState(() {
       refConnected = idUser;
    });

    // print('id connected: ${refConnected.toInt()}');

    futureData = ApiService.fetchPieData("chauffeur_mobile_stat_paiement_course_mode/${idUser.toInt()}");

    
  }

  @override
  void initState() {
    super.initState();
    getIdConnected();
    
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Card(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: FutureBuilder<List<PieData>>(
                    future: futureData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Erreur : ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Aucune donnée disponible"));
                      }
                            
                      List<PieData> pieDataList = snapshot.data!;
                      List<PieChartSectionData> sections = [];
                            
                      for (int i = 0; i < pieDataList.length; i++) {
                        sections.add(
                          PieChartSectionData(
                            title: '${pieDataList[i].value}CDF',
                            value: pieDataList[i].value,
                            color: availableColors[i % availableColors.length],
                            radius: 60,
                            titleStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                            
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          
                          // ✅ Responsive Container
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                              maxHeight: MediaQuery.of(context).size.height * 0.30,
                              
                            ),
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: 50,
                                sectionsSpace: 2,
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                            
                          SizedBox(height: 1),
                            
                          // ✅ Légende dynamique avec Wrap
                          Wrap(
                            spacing: 10,
                            runSpacing: 5,
                            alignment: WrapAlignment.center,
                            children: List.generate(pieDataList.length, (index) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color:
                                          availableColors[index %
                                              availableColors.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    pieDataList[index].category,
                                    style: TextStyle(
                                      fontSize: 14,
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
          ),
      ],
    );
  }
}

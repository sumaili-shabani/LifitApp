import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/ConducteurModel.dart';
import 'package:lifti_app/Model/RevenuChauffeurInfo.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/composants/EvolutionStatique.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoEnOrdreChauffeur extends StatefulWidget {
  final ConducteurModel user;
  final Function onClicFunction;
  const InfoEnOrdreChauffeur({
    super.key,
    required this.user,
    required this.onClicFunction,
  });

  @override
  State<InfoEnOrdreChauffeur> createState() => _InfoEnOrdreChauffeurState();
}

class _InfoEnOrdreChauffeurState extends State<InfoEnOrdreChauffeur> {
 
  List<ChauffeurInfoModel> dataList = [];
  bool isLoading = true;
  int refConnected = 0;
  getIdConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    int idUser = localStorage.getInt('idConnected')!;

    if (idUser == null) {
      throw Exception('Utilisateur non connecté');
    }
    String url =
        "getInfoPerformanceChauffeur/${widget.user.refChauffeur!.toString()}/${widget.user.idRole!.toString()}";
    List<dynamic> dataDash = await CallApi.fetchListData(url);
    // print(dataDash);

    setState(() {
      dataList =
          dataDash.map((item) => ChauffeurInfoModel.fromMap(item)).toList();
      isLoading = false;
      refConnected = idUser;
    });
  }

  @override
  void initState() {
    super.initState();
    getIdConnected();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
            
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                     
                      : Column(
                        children:
                            dataList.map((data) {
                              return Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: theme.cardColor,
                                shadowColor: theme.hoverColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.bar_chart,
                                            color: Colors.blue,
                                            size: 28,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Statistiques des courses",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_taxi,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Total des courses : ${data.nombreCourseRealise ?? ''}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            color: Colors.orange,
                                            size: 24,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Dernière activité : ${data.timeAgo ?? ''}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Exigence : attendre ${data.nombreCourse ?? '0'} Course(s)",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(), // Ajout de toList() pour éviter l'erreur de type
                      ),
            
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          "${CallApi.fileUrl}/images/${widget.user.avatar ?? 'avatar.png'}",
                        ),
                      ),
                      title: Text(
                        widget.user.name! ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone_android, size: 14),
                              SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  "N° de tel : ${widget.user.telephone! ?? ''}",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet, size: 14),
                              SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  "Wallet solde : ${widget.user.soldeCommission! ?? ''}CDF",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ),
            
                  Expanded(child: EvolutionStatique(user: widget.user)),
                  SizedBox(height: 2),
            
                 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

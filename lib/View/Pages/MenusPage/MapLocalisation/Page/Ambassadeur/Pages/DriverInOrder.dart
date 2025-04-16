import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/ChauffeurEnOrdreModel.dart';

class DriveInorderPage extends StatefulWidget {
  const DriveInorderPage({super.key});

  @override
  State<DriveInorderPage> createState() => _DriveInorderPageState();
}

class _DriveInorderPageState extends State<DriveInorderPage> {
  late List<ChauffeurListModel> chauffeurlist = [];
  late List<ChauffeurListModel> filteredList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  int idRole = 0;

  Future<void> fetchUser() async {
    int? roleId = await CallApi.getUserRole();

    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    //passager
    List<dynamic> dataDash = await CallApi.fetchListData(
      'get_info_chauffeur_en_ordre/3/${userId.toInt()}',
    );
    // print(dataDash);
    setState(() {
      idRole = roleId!;
      chauffeurlist =
          dataDash.map((item) => ChauffeurListModel.fromMap(item)).toList();
      filteredList = chauffeurlist;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void filterSearch(String query) {
    setState(() {
      filteredList =
          chauffeurlist.where((chauffeur) {
            return chauffeur.name!.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                chauffeur.telephone!.contains(query) ||
                chauffeur.sexe!.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Rechercher un chauffeur...",
                fillColor: theme.hoverColor,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      var chauffeur = filteredList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              "${CallApi.fileUrl}/images/${chauffeur.avatar?? 'avatar.png'}",
                            ),
                          ),
                          title: Text(
                            chauffeur.name ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             
                              Row(
                                children: [
                                  Icon(Icons.timer, size: 14),
                                  SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      "En ligne: ${CallApi.formatDateString(chauffeur.lastActivity!)} ",
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.call, size: 14),
                                  SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      "N° de tél: ${chauffeur.telephone!} ",
                                    ),
                                  ),
                                ],
                              ),
                              
                              Row(
                                children: [
                                  Icon(Icons.bar_chart_outlined, size: 14),
                                  SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      "Total de course réalisé: ${chauffeur.totalCountCourse??''}",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
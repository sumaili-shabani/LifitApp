import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/ConducteurModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/composants/InfoRevenuChauffeur.dart';


class MesChauffeur extends StatefulWidget {
  const MesChauffeur({super.key});

  @override
  State<MesChauffeur> createState() => _MesChauffeurState();
}

class _MesChauffeurState extends State<MesChauffeur> {
  late List<ConducteurModel> chauffeurlist = [];
  late List<ConducteurModel> filteredList = [];
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
      'list_chauffeur_ambassadeur/${userId.toInt()}',
    );
    // print(dataDash);
    setState(() {
      idRole = roleId!;
      chauffeurlist =
          dataDash.map((item) => ConducteurModel.fromMap(item)).toList();
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
                              "${CallApi.fileUrl}/images/${chauffeur.avatar ?? 'avatar.png'}",
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
                              Text(
                                "Sexe: ${chauffeur.sexe} | ${chauffeur.roleName ?? ''}\nTel: ${chauffeur.telephone ?? ''}",
                              ),
                              Row(
                                children: [
                                  Icon(Icons.account_balance_wallet, size: 14),
                                  SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      "wallet Solde: ${chauffeur.soldeCommission} CDF",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 0,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 30,
                                ),
                                onPressed: () {
                                  // Action revenu
                                  showRevenuBottomSheet(context, chauffeur);
                                },
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

  /*
  *
  *============================
  * Pour upload de l'image
  *============================
  *
  */

  // Fonction pour ouvrir le BottomSheet
  void showRevenuBottomSheet(BuildContext context, ConducteurModel user) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return InfoRevenuChauffeur(
          user: user,
          onClicFunction: () {
            Navigator.pop(context);
            fetchUser();
          },
        );
      },
    );
  }
}

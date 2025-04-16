import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/ConducteurModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/AddChauffeur.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/AvatarImage.dart';

class ChauffeurAmbassadeurPage extends StatefulWidget {
  const ChauffeurAmbassadeurPage({super.key});

  @override
  State<ChauffeurAmbassadeurPage> createState() =>
      _ChauffeurAmbassadeurPageState();
}

class _ChauffeurAmbassadeurPageState extends State<ChauffeurAmbassadeurPage> {
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
      'list_chauffeur_all_ambassadeur/${userId.toInt()}',
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
                          subtitle: Text(
                            "Sexe: ${chauffeur.sexe} | ${chauffeur.roleName ?? ''}\nTel: ${chauffeur.telephone ?? ''}",
                          ),
                          trailing: Wrap(
                            spacing: 0,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  // Action Modifier
                                  bool? result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => Addchauffeur(
                                            id:
                                                chauffeur.id ??
                                                0, // Assure que `id` ne soit jamais null
                                            name:
                                                chauffeur.name ??
                                                '', // Valeur par défaut ''
                                            email: chauffeur.email ?? '',
                                            telephone:
                                                chauffeur.telephone ?? '',
                                            adresse: chauffeur.adresse ?? '',
                                            sexe:
                                                chauffeur.sexe ??
                                                '', // Assure que `sexe` ne soit jamais null
                                            tel1: chauffeur.tel1 ?? '',
                                            tel2: chauffeur.tel2 ?? '',
                                            tel3: chauffeur.tel3 ?? '',
                                            tel4: chauffeur.tel4 ?? '',
                                            refBanque:
                                                chauffeur.refBanque ??
                                                0, // Assure que `refBanque` ne soit jamais null
                                            refMode:
                                                chauffeur.refMode ??
                                                0, // Assure que `refMode` ne soit jamais null

                                            nomBanque:
                                                chauffeur.nomBanque ?? '',
                                            nomMode: chauffeur.nomMode ?? '',
                                          ),
                                    ),
                                  );

                                  if (result == true) {
                                    // Rafraîchir la liste des chauffeurs ici
                                    fetchUser();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.image, color: Colors.green),
                                onPressed: () {
                                  // Action Changer Image
                                  showRatingBottomSheet(context, chauffeur);
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
  void showRatingBottomSheet(BuildContext context, ConducteurModel user) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AvatarImage(
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

import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Model/VehiculeModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/AddVehicule.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/composants/MenuAction.dart';

class VehiculePage extends StatefulWidget {
  const VehiculePage({super.key, onClicFunction});

  @override
  State<VehiculePage> createState() => _VehiculePageState();
}

class _VehiculePageState extends State<VehiculePage> {
  late List<VoitureModel> vehiculelist = [];
  late List<VoitureModel> filteredList = [];
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
      'fetch_vehcule_bu_partenaire/${userId.toInt()}',
    );
    // print(dataDash);
    setState(() {
      idRole = roleId!;
      vehiculelist =
          dataDash.map((item) => VoitureModel.fromMap(item)).toList();
      filteredList = vehiculelist;
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
          vehiculelist.where((voiture) {
            return voiture.nomMarque!.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                voiture.nomTypeCourse!.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                voiture.nomProprietaire!.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                voiture.contactProprietaire!.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                voiture.numPlaqueVehicule!.toLowerCase().contains(
                  query.toLowerCase(),
                );
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("Véhicules", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () async {
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddVehicule()),
              );

              if (result == true) {
                // Rafraîchir la liste des chauffeurs ici
                fetchUser();
              }
            },
            icon: Icon(Icons.add, color: Colors.white),
            tooltip: "Ajouter un véhicule",
          ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.white),
            tooltip: "Discussion instantanée",
            onPressed: () {
              Navigator.of(
                context,
              ).push(AnimatedPageRoute(page: CorrespondentsPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Rechercher un vehicule...",
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
                      var voiture = filteredList[index];
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: NetworkImage(
                                      "${CallApi.fileUrl}/taxi/${voiture.imageVehicule ?? 'taxi.png'}",
                                    ),
                                    radius: 25,
                                  ),

                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${voiture.nomCategorieVehicule!.toString()} - ${voiture.nomMarque!.toString()}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "N°Plaque: ${voiture.numPlaqueVehicule ?? ''} ",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),

                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              bool?
                                              result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => AddVehicule(
                                                        id: voiture.id,
                                                        genreVehicule:
                                                            voiture
                                                                .genreVehicule,
                                                        typeCarburant:
                                                            voiture
                                                                .typeCarburant,
                                                        adresseOrganisation:
                                                            voiture
                                                                .adresseOrganisation,
                                                        adresseProprietaire:
                                                            voiture
                                                                .adresseProprietaire,
                                                        author: voiture.author,
                                                        capo: voiture.capo,
                                                        codeAmbassadeur:
                                                            voiture
                                                                .codeAmbassadeur,
                                                        nomProprietaire:
                                                            voiture
                                                                .nomProprietaire,
                                                        contactProprietaire:
                                                            voiture
                                                                .contactProprietaire,
                                                        dateFabrication:
                                                            voiture
                                                                .dateFabrication,
                                                        createdAt:
                                                            voiture.createdAt,
                                                        detailCapo:
                                                            voiture.detailCapo,
                                                        detailsOrganisation:
                                                            voiture
                                                                .detailsOrganisation,
                                                        numChassiVehicule:
                                                            voiture
                                                                .numChassiVehicule,
                                                        numImpotVehicule:
                                                            voiture
                                                                .numImpotVehicule,
                                                        numroIdentification:
                                                            voiture
                                                                .numroIdentification,
                                                        numMoteurVehicule:
                                                            voiture
                                                                .numMoteurVehicule,
                                                        numPlaqueVehicule:
                                                            voiture
                                                                .numPlaqueVehicule,
                                                        nbrPlace:
                                                            voiture.nbrPlace,
                                                        refCategorie:
                                                            voiture
                                                                .refCategorie,
                                                        refMarque:
                                                            voiture.refMarque,
                                                        refCouleur:
                                                            voiture.refCouleur,
                                                        refOrganisation:
                                                            voiture
                                                                .refOrganisation,
                                                        refTypeCourse:
                                                            voiture.refTypeOrg,
                                                        refUser:
                                                            voiture.refUser,
                                                      ),
                                                ),
                                              );

                                              if (result == true) {
                                                // Rafraîchir la liste des chauffeurs ici
                                                fetchUser();
                                              }
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          SizedBox(width: 1),
                                          IconButton(
                                            onPressed: () {
                                              showActionMenuBottomSheet(context, voiture);
                                            },
                                            icon: Icon(
                                              Icons.file_copy,
                                              size: 20,
                                              color:
                                                  ConfigurationApp.successColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // _buildPaymentTag(course.designation!),
                                ],
                              ),
                              Divider(height: 20, thickness: 1),
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.phone_android, size: 14),
                                        SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            "Propriétaire: ${voiture.nomProprietaire!} | ${voiture.contactProprietaire!} ",
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Icon(Icons.category_outlined, size: 14),
                                        SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            "Type de course: ${voiture.nomTypeCourse ?? ''}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  ConfigurationApp.successColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.domain, size: 14),
                                        SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            "Organisation: ${voiture.nomOrganisation ?? ''}-${voiture.nomTypeOrganisation ?? ''}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            "Mise à jour: ${voiture.createdAt ?? ''}",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
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
  void showActionMenuBottomSheet(
    BuildContext context,
    VoitureModel voiture

  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context)=> MenuActionBottom(voiture: voiture, onClicIconButton: (voiture){
        // print(voiture.id!);
        fetchUser();

      }),
    );
  }

  void showEditVehicluleBottomSheet(
    BuildContext context,
    VoitureModel voiture,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Center(child: Text("Composant en attente de chargement"));
      },
    );
  }

  void showEditPhotoVehicluleBottomSheet(
    BuildContext context,
    VoitureModel voiture,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Center(child: Text("Composant image en attente de chargement"));
        // return InfoRevenuChauffeur(
        //   user: user,
        //   onClicFunction: () {
        //     Navigator.pop(context);
        //     fetchUser();
        //   },

        // );
      },
    );
  }
}

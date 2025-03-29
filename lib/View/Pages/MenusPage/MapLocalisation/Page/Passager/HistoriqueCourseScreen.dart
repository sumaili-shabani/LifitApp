import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/ChauffeurDashBoardModel.dart';
import 'package:lifti_app/Model/HistoriqueCourseModel.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/InformationMenu.dart';

class HistoriqueCourseScreen extends StatefulWidget {
  const HistoriqueCourseScreen({super.key});

  @override
  State<HistoriqueCourseScreen> createState() => _HistoriqueCourseScreenState();
}

class _HistoriqueCourseScreenState extends State<HistoriqueCourseScreen> {
  TextEditingController searchController = TextEditingController();

  List<HistoriqueCourseModel> notifications = [];
  List<ChauffeurDashBoardModel> dashInfo = [];

  String searchQuery = "";
  bool isLoading = true;

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        'passager_mobile_fetch_paiement_course/${userId.toInt()}',
      );
      List<dynamic> dataDash = await CallApi.fetchListData(
        'passager_mobile_dashboard/${userId.toInt()}',
      );

      // print(dataDash);

      setState(() {
        notifications =
            data.map((item) => HistoriqueCourseModel.fromMap(item)).toList();
        dashInfo =
            dataDash
                .map((item) => ChauffeurDashBoardModel.fromMap(item))
                .toList();

        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  /// 🔹 **Méthode DELETE**
  Future<void> checkStatutCourse(int id, String statut) async {
    try {
      final response = await CallApi.deleteData(
        "chauffeur_mobile_checkStatut_course_vehicule/${id.toInt()}/${statut.toString()}",
      );

      final Map<String, dynamic> responseData = response;
      String message = responseData['data'] ?? "Deleted!!!";
      showSnackBar(context, message, 'success');

      //appelle de la fonction demande
      fetchNotifications();
    } catch (e) {
      print('Error fetching demandes: $e');
    }
  }

  /*
  *
  *==================================
  * BottomSheet commission Info
  *==================================
  *
  */
  bool isLoadingCommission = true;
  List<dynamic> infoCommission = [
    {
      "chauffeurInfo": [
        {
          "name": "Drey Mukuka",
          "sexe": "M",
          "avatar": "1740654256.png",
          "date_paie": "2025-03-03",
          "montant_paie": 378,
          "devise": "CDF",
          "created_at": "2025-03-03 09:37:59",
          "roleName": "Chauffeur",
        },
      ],
      "liftiInfo": [
        {
          "name": "Commission lifti",
          "sexe": "",
          "avatar": "1737228898.png",
          "date_paie": "2025-03-03",
          "montant_paie": 907.2,
          "devise": "CDF",
          "created_at": "2025-03-03 09:37:59",
          "roleName": "Lifti",
        },
      ],
      "partenaireInfo": [
        {
          "name": "Gloria nehema",
          "sexe": "F",
          "avatar": "1692964850.jpg",
          "date_paie": "2025-03-03",
          "montant_paie": 151.2,
          "devise": "CDF",
          "created_at": "2025-03-03 09:37:59",
          "roleName": "Partenaire",
        },
        {
          "name": "Roger Admin",
          "sexe": "M",
          "avatar": "1737386203.png",
          "date_paie": "2025-03-03",
          "montant_paie": 75.6,
          "devise": "CDF",
          "created_at": "2025-03-03 09:37:59",
          "roleName": "Admin",
        },
      ],
    },
  ];

  // Fonction pour récupérer les données de l'API avec un ID dynamique
  Future<void> fetchCommissionData(int idPaiement) async {
    // L'URL de l'API avec l'ID dynamique
    String? token = await CallApi.getToken();
    final url =
        '${CallApi.baseUrl.toString()}/mobile_chauffeur_show_repartition_commision/${idPaiement.toString()}';

    try {
      // Effectuer la requête HTTP GET avec l'ID dynamique
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Si la requête réussit, analyser le JSON et stocker dans infoCommission
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          // Vérification de l'existence de la clé 'data' avant de l'utiliser
          if (data.containsKey('data') &&
              data['data'] is List &&
              data['data'].isNotEmpty) {
            infoCommission = data['data'];
            isLoadingCommission = false;
          } else {
            // Si 'data' est vide ou absent, on peut ajouter une gestion d'erreur ici
            infoCommission = [];
            isLoadingCommission = true;
          }
        });
      } else {
        // Gérer les erreurs si la requête échoue
        throw Exception('Échec de la récupération des données');
      }
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
      // Vérifiez également si le widget est encore monté avant de mettre à jour l'état
      if (mounted) {
        setState(() {
          infoCommission = [];
        });
      }
    }
  }

 

  Widget buildCommissionCard(String title, List<dynamic> items, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            Column(children: items.map((item) => buildUserTile(item)).toList()),
          ],
        ),
      ),
    );
  }

  Widget buildUserTile(Map<String, dynamic> item) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(
          '${CallApi.fileUrl}/images/${item['avatar']}',
        ), // Change with actual avatar URL
      ),
      title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.grey, size: 15),
              SizedBox(width: 5),
              Text(
                "Montant: ${item['montant_paie']} ${item['devise']}",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey, size: 15),
              SizedBox(width: 5),
              Text(
                "Date:${CallApi.getFormatedDate(item['date_paie'])}",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),

          Row(
            children: [
              Icon(Icons.info, color: Colors.green, size: 15),
              SizedBox(width: 5),
              Text(
                "Au compte de ${item['roleName']}",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(
        Icons.account_balance_wallet,
        color: Colors.grey,
        size: 20,
      ),
    );
  }

  //fin



  /*
  *
  *==================================
  * Fin BottomSheet commission Info
  *==================================
  *
  */
  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  void dispose() {
    super.dispose();
    // Nettoyer toute ressource si nécessaire ici
    infoCommission.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("Historique des courses", style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Recharger la liste",
            color: Colors.white,
            onPressed: () {
              fetchNotifications();
            },
          ),

          IconButton(
            icon: Icon(Icons.newspaper_outlined),
            tooltip: "Voir plus d'informations",
            color: Colors.white,
            onPressed: () {
               Navigator.of(
                context,
              ).push(AnimatedPageRoute(page: InformationMenuScreem()));
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Affiche un loader en attendant l'API
              : Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Rechercher une course",
                        hintText: "Recherche une course...",
                        fillColor: theme.cardColor,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged:
                          (value) =>
                              setState(() => searchQuery = value.toLowerCase()),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          var course = notifications[index];
                          if (!course.namePassager!.toLowerCase().contains(
                                searchQuery,
                              ) &&
                              !course.datePaie!.toLowerCase().contains(
                                searchQuery,
                              ) &&
                              !course.nameChauffeur!.toLowerCase().contains(
                                searchQuery,
                              ) &&
                              !course.nameDepart!.toLowerCase().contains(
                                searchQuery,
                              ) &&
                              !course.nameDestination!.toLowerCase().contains(
                                searchQuery,
                              ) &&
                              !course.nomTypeCourse!.toLowerCase().contains(
                                searchQuery,
                              ) &&
                              !course.nomCategorieVehicule!.toLowerCase().contains(
                                searchQuery,
                              ) &&
                              !course.montantPaie!
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchQuery)) {
                            return Container();
                          }

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          "${CallApi.fileUrl}/taxi/${course.imageTypeCourse ?? 'taxi.png'}",
                                        ),
                                        radius: 25,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.nomTypeCourse!.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "${course.calculate == 1 ?'Distance:':''}${course.distance!.toStringAsFixed(2)} ${course.calculate == 1 ? 'Km' : 'J/H'}➡️${course.timeEst!}",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),

                                          Row(
                                            children: [
                                              Icon(Icons.car_repair, color: Colors.grey, size: 15,
                                              ),
                                              Text(
                                                " ${course.nomCategorieVehicule!}",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        children: [
                                          Text(
                                            "${course.montantCourse!.toString()}CDF",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          _buildPaymentTag(course.designation!),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(height: 20, thickness: 1),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          "Départ : ${course.nameDepart!}",
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.flag, color: Colors.red),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          "Arrivée : ${course.nameDestination!}",
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: theme.hintColor,
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          "Date : ${CallApi.getFormatedDate(course.datePaie.toString())}",
                                          style: TextStyle(
                                            color: theme.hintColor,
                                          ),
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

  Widget _buildPaymentTag(String paymentMode) {
    IconData icon;
    Color color;

    switch (paymentMode) {
      case "Mobile Money":
        icon = Icons.smartphone;
        color = Colors.orange;
        break;
      case "Espèces" || "Cash":
        icon = Icons.money;
        color = Colors.green;
        break;
      case "Carte Bancaire":
        icon = Icons.credit_card;
        color = Colors.blue;
        break;
      default:
        icon = Icons.payment;
        color = Colors.grey;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 5),
        Text(
          paymentMode,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

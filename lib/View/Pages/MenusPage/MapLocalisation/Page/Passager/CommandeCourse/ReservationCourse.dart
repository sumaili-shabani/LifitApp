import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationTaxi extends StatefulWidget {
  final List<dynamic> typeCourses;
  final Map<String, dynamic> trajectoire;
  final Map<String, dynamic> datainfotarification;
  final int refCategorie;
  final Function(Map<String, dynamic>) onCategorySelected; // Callback function
  final bool isLocation;
  final String nameVehicule;
  const ReservationTaxi({
    super.key,
    required this.typeCourses,
    required this.trajectoire,
    required this.refCategorie,
    required this.datainfotarification,
    required this.onCategorySelected,
    required this.isLocation,
    required this.nameVehicule,
  });

  @override
  State<ReservationTaxi> createState() => _ReservationTaxiState();
}

class _ReservationTaxiState extends State<ReservationTaxi> {
  bool isLoading = true;
  bool isLoadingCommande = false;
  List<dynamic> categories = [];
  List<dynamic> filteredCategories = [];
  bool showSearchBar = false;
  TextEditingController searchController = TextEditingController();
  int idConnected = 0;
  String nameConnected = "";
  String token = "";

  final PusherChannelsFlutter pusher = PusherChannelsFlutter();
  Function(Map<String, dynamic>)?
  onNewTaxiRequest; // Callback pour mettre à jour l'UI

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    String? sessionName = await CallApi.getNameConnected();
    String? sessionToken = await CallApi.getToken();

    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      int refTypeCourse = widget.datainfotarification['refTypeCourse'];
      List<dynamic> listVehicule = await CallApi.fetchListData(
        'fetch_vehicule_map_on_line_bycatvehicule/${widget.refCategorie}/$refTypeCourse',
      );
      // print(listVehicule);
      setState(() {
        categories = listVehicule;
        filteredCategories = listVehicule;
        idConnected = userId;
        nameConnected = sessionName.toString();
        token = sessionToken.toString();
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCategories = categories;
      });
    } else {
      setState(() {
        filteredCategories =
            categories
                .where(
                  (category) => category['name']!.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      });
    }
  }

  Future<void> initPusher() async {
    int? userId = await CallApi.getUserId(); // Récupérer l'ID utilisateur
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? bearerToken = localStorage.getString('token');

    if (bearerToken == null || bearerToken.isEmpty) {
      print("❌ Erreur : Aucun token trouvé !");
      return;
    }

    print("🔑 Token récupéré : $bearerToken");

    try {
      await pusher.init(
        apiKey: CallApi.pusherAppKey.toString(),
        cluster: "mt1",
        // useTLS: false,
        authEndpoint: "${CallApi.baseUrl}/broadcasting/auth?token=$bearerToken",
        onEvent: (PusherEvent event) {
          print("📡 Nouvel événement : $event");
          print("📡 Nouvel événement : ${event.data}");
          // ✅ Convertir les données reçues
          Map<String, dynamic> response = jsonDecode(event.data);

          if (mounted) {
            setState(() {
              if (response['statut'] == 'accepté') {
                EasyLoading.dismiss();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("🚖 Votre taxi est en route !")),
                );
              }
            });
          }
        },
      );

      await pusher.subscribe(
        channelName: "private-commande-taxi.$userId",
        onSubscriptionSucceeded: (dynamic channelName) {
          print("✅ Abonné au canal : $channelName");
        },
        onEvent: (dynamic event) {
          // 🔥 Changer `PusherEvent` en `dynamic`
          print("🚀 Événement reçu : ${event.data}");

          // Vérifier que `event.data` est bien une chaîne JSON avant de la décoder
          if (event is PusherEvent && event.data != null) {
            try {
              Map<String, dynamic> response = jsonDecode(event.data!);

              if (mounted) {
                setState(() {
                  if (response['statut'] == '2') {
                    EasyLoading.dismiss();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Chauffeur indisponible.")),
                    );
                    print("❌ Chauffeur indisponible.");
                  } else if (response['statut'] == '3') {
                    EasyLoading.dismiss();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("✅ Taxi confirmé, en route !")),
                    );
                    print("✅ Taxi confirmé, en route !");
                  }
                });
              }
            } catch (e) {
              print("❌ Erreur lors du parsing JSON : $e");
            }
          } else {
            print("⚠️ Événement Pusher invalide : $event");
          }
        },
      );

      await pusher.connect();
    } catch (e) {
      print("❌ Erreur Pusher : $e");
    }
  }

  Timer? pusherTimer; // ✅ Timer pour recharger Pusher
  List<CourseInfoPassagerModel> listCourseEncours = [];
  Timer? _timer;
  fetchCourses() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté

    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        'passager_mobile_course_encours/${userId.toString()}',
      );
      // print("data: $data");
      setState(() {
        listCourseEncours =
            data.map((item) => CourseInfoPassagerModel.fromMap(item)).toList();

        isLoading = false;
      });

      print("listCourseEncours: $data");
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _showInputDialog(
    BuildContext context,
    String unite,
    Map<String, dynamic> category,
  ) async {
    TextEditingController daysController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Pour combien de temps voulez-vous louer cette voitre ?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          content: TextField(
            controller: daysController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Pour 5 /$unite",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  () => Navigator.pop(context), // Fermer la boîte de dialogue
              child: Text("Annuler", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                int? jours = int.tryParse(daysController.text);
                if (jours != null && jours > 0) {
                  Navigator.pop(context); // Fermer la boîte de dialogue

                  double duration = double.parse(
                    widget.trajectoire['duration']?.toString() ?? '0',
                  );

                 

                  double prix = double.parse(
                    widget.datainfotarification['prix']?.toString() ?? '0',
                  );
                  double taxeAmbouteillage = double.parse(
                    widget.datainfotarification['taxeAmbouteillage']
                            ?.toString() ??
                        '0',
                  );

                  double taxeSuplementaire = taxeAmbouteillage / 60;

                  String devise =
                      widget.datainfotarification['devise']?.toString() ?? '';

                  String placeLat =
                      widget.trajectoire['placeLat']?.toString() ?? '';
                  String placeLon =
                      widget.trajectoire['placeLon']?.toString() ?? '';
                  String placeName =
                      widget.trajectoire['placeName']?.toString() ?? '';

                  int remise = int.parse(
                    widget.datainfotarification['remise']?.toString() ?? '0',
                  );

                  int refTypeCourse = int.parse(
                    widget.datainfotarification['refTypeCourse']?.toString() ??
                        '0',
                  );

                  double durationPlus = double.parse(
                    widget.datainfotarification['durationPlus']?.toString() ??
                        '0',
                  );

                  double tempsMax = duration + durationPlus;
                  double montantNormal =
                      widget.isLocation
                          ? prix * jours - ((prix * jours * remise) / 100)
                          : prix * jours -
                              ((prix * jours * remise) / 100);

                  String dateLimiteCourse =
                      CallApi.getCurrentDateTimeWithOffset(tempsMax);

                  // traitement de l'insertion
                  envoyerCommande(
                    context,
                    idConnected: idConnected,
                    category: category,
                    refTypeCourse: refTypeCourse,
                    placeName: placeName,
                    placeLon: double.parse(placeLon),
                    placeLat: double.parse(placeLat),
                    montantNormal: montantNormal,
                    devise: devise,
                    nameConnected: nameConnected,
                    distance: double.parse(jours.toString()),
                    tempsMax: tempsMax,
                    dateLimiteCourse: dateLimiteCourse,
                    taxeSuplementaire: taxeSuplementaire,
                    calculate: 0,
                  );
                  // fin triatement insertion
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Veuillez entrer un nombre valide."),
                    ),
                  );
                }
              },
              child: Text("Valider"),
            ),
          ],
        );
      },
    );
  }

  /*
  *
  *===================================
  * FOnction d'insertion
  *===================================
  *
  */
  Future<void> envoyerCommande(
    BuildContext context, {
    required int idConnected,
    required Map<String, dynamic> category,
    required int refTypeCourse,
    required String placeName,
    required double placeLon,
    required double placeLat,
    required double montantNormal,
    required String devise,
    required String nameConnected,
    required double distance,
    required double tempsMax,
    required String dateLimiteCourse,
    required double taxeSuplementaire,
    required int calculate,
  }) async {
    try {
      // Afficher le chargement
      EasyLoading.show(
        status: 'Envoi en cours...',
        maskType: EasyLoadingMaskType.black,
      );

      // Récupérer la position actuelle
      Position? position = await ApiService.getCurrentLocation();

      if (position == null) {
        EasyLoading.showError("Impossible d'obtenir la position.");
        return;
      }

      double latitude = position.latitude;
      double longitude = position.longitude;

      // Récupérer le nom du lieu
      String namePlace = await ApiService.getPlaceName(latitude, longitude);

      // Création de la data à envoyer
      Map<String, dynamic> svData = {
        "id": "",
        "refPassager": idConnected,
        "refChauffeur": int.parse(category['refChauffeur'].toString()),
        "refConduite": category['refConduite']!.toString(),
        "refTypeCourse": refTypeCourse,
        "refAdresseDepart": namePlace,
        "refAdresseArrivee": placeName,
        "depart_longitude": longitude,
        "depart_latitude": latitude,
        "arrivee_longitude": placeLon,
        "arrivee_latitude": placeLat,
        "current_longitude": longitude,
        "current_latitude": latitude,
        "montant_course": montantNormal.toStringAsFixed(0),
        "devise": devise,
        "status": 2,
        "author": nameConnected,
        "refUser": idConnected,
        "latDepart": latitude.toString(),
        "lonDepart": longitude.toString(),
        "latDestination": placeLat.toString(),
        "lonDestination": placeLon.toString(),
        "nameDepart": namePlace,
        "nameDestination": placeName,
        "distance": distance.toStringAsFixed(2),
        "prixCourse": montantNormal.toStringAsFixed(0),
        "timeEst": "${tempsMax.toStringAsFixed(2)} Min",
        "calculate": calculate,
        "dateLimiteCourse": dateLimiteCourse,
        "taxeSuplementaire": taxeSuplementaire.toStringAsFixed(0),
        "timePlus": tempsMax.toString(),
      };

      print("🔹 Envoi de la requête avec les données : $svData");

      // Envoi des données à l'API
      final response = await CallApi.insertData(
        endpoint: "mobile_passager_store_course",
        data: svData,
      );

      String message = response['message'].toString();

      if (message.isNotEmpty) {
        print("✅ Réponse API : $response");
        EasyLoading.showSuccess("Commande envoyée avec succès !");
        showSnackBar(context, message, 'success');
      } else {
        print("⚠️ Message vide reçu !");
        EasyLoading.showSuccess("Commande envoyée avec succès !");
        // EasyLoading.showError("Erreur lors de l'envoi !");
      }
    } catch (e) {
      print("❌ Erreur API : $e");
      // EasyLoading.showError("Une erreur s'est produite !");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    fetchCourses();
    setState(() {
      searchController.text = widget.nameVehicule.toString();
     
    });
    

    

    // Déclenche fetchNotification toutes les 60 secondes
     _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchCourses();
    });


  }

  @override
  void dispose() {
    _timer?.cancel(); // Arrêter le timer pour éviter les fuites de mémoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 75% de l'écran
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 5),

          // Icône pour afficher/cacher la barre de recherche
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Taxis disponibles prochent de vous",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(showSearchBar ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    showSearchBar = !showSearchBar;
                    if (!showSearchBar) searchController.clear();
                    filterSearchResults("");
                  });

                  // print("showSearchBar: $showSearchBar");
                },
              ),
            ],
          ),

          // Barre de recherche
          if (showSearchBar)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher un taxi...",
                  fillColor: theme.hoverColor,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: filterSearchResults,
              ),
            ),

          // debit composant

          // fin composant

          // Liste des catégories en mode Grid
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Affiche un loader en attendant l'API
              : Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];

                    double duration = double.parse(
                      widget.trajectoire['duration']?.toString() ?? '0',
                    );

                    double distance = double.parse(
                      widget.trajectoire['distance']?.toString() ?? '0',
                    );

                    double prix = double.parse(
                      widget.datainfotarification['prix']?.toString() ?? '0',
                    );
                    double taxeAmbouteillage = double.parse(
                      widget.datainfotarification['taxeAmbouteillage']
                              ?.toString() ??
                          '0',
                    );

                    double taxeSuplementaire = taxeAmbouteillage / 60;

                    String devise =
                        widget.datainfotarification['devise']?.toString() ?? '';

                    String unite =
                        widget.datainfotarification['unite']?.toString() ??
                        'Km';

                    String placeLat =
                        widget.trajectoire['placeLat']?.toString() ?? '';
                    String placeLon =
                        widget.trajectoire['placeLon']?.toString() ?? '';
                    String placeName =
                        widget.trajectoire['placeName']?.toString() ?? '';

                    int remise = int.parse(
                      widget.datainfotarification['remise']?.toString() ?? '0',
                    );

                    int refTypeCourse = int.parse(
                      widget.datainfotarification['refTypeCourse']
                              ?.toString() ??
                          '0',
                    );

                    double durationPlus = double.parse(
                      widget.datainfotarification['durationPlus']?.toString() ??
                          '0',
                    );

                    double tempsMax = duration + durationPlus;
                    double montantNormal =
                        widget.isLocation
                            ? prix * 1 - ((prix * 1 * remise) / 100)
                            : prix * distance -
                                ((prix * distance * remise) / 100);

                    String dateLimiteCourse =
                        CallApi.getCurrentDateTimeWithOffset(tempsMax);

                    return GestureDetector(
                      onTap: () {
                        // Navigator.pop(
                        //   context,
                        // ); // Fermer le BottomSheet après sélection

                        // widget.onCategorySelected(
                        //   category,
                        // ); // Appel de la fonction callback

                        // print("Sélectionné : $category");

                        print(
                          "Temps: ${tempsMax.toString()} montant:${montantNormal.toString()}",
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.network(
                                  "${CallApi.fileUrl}/taxi/${category['imageVehicule'] ?? 'taxi.png'}",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  widget.isLocation
                                      ? TextButton(
                                        onPressed: () async {
                                          _showInputDialog(
                                            context,
                                            unite,
                                            category,
                                          );
                                        },
                                        child: Text(
                                          "Commander la location ${category["name"] ?? ''}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                      : TextButton(
                                        onPressed: () async {
                                          await envoyerCommande(
                                            context,
                                            idConnected: idConnected,
                                            category: category,
                                            refTypeCourse: refTypeCourse,
                                            placeName: placeName,
                                            placeLon: double.parse(placeLon),
                                            placeLat: double.parse(placeLat),
                                            montantNormal: montantNormal,
                                            devise: devise,
                                            nameConnected: nameConnected,
                                            distance: distance,
                                            tempsMax: tempsMax,
                                            dateLimiteCourse: dateLimiteCourse,
                                            taxeSuplementaire:
                                                taxeSuplementaire,
                                            calculate: 1,
                                          );
                                        },
                                        child: Text(
                                          "Commander ${category["name"] ?? ''}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                  //prix de la course
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.blueGrey,
                                        size: 10,
                                      ),
                                      SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          'Prix:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${montantNormal.toStringAsFixed(0)} CDF',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  //fin prix
                                  SizedBox(height: 4),

                                  //minute de la course
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.map,
                                        color: Colors.blueGrey,
                                        size: 12,
                                      ),
                                      SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          "${widget.isLocation ? 'Location:' : 'Distance:'} ",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      widget.isLocation
                                          ? Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  ' $unite',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          : Expanded(
                                            child: Text(
                                              '${distance.toStringAsFixed(0)} Km / pour ${tempsMax.toStringAsFixed(0)} Minutes',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                  //fin minutes

                                  // integration de detail
                                  Divider(),

                                  // Marque du véhicule
                                  _buildInfoRow(
                                    Icons.check_box,
                                    "Marque",
                                    category["nomMarque"],
                                  ),

                                  // Nombre de places
                                  _buildInfoRow(
                                    Icons.person_3_outlined,
                                    "Places",
                                    "${category["nbrPlace"]} passagers",
                                  ),

                                  // Type de carburant
                                  _buildInfoRow(
                                    Icons.category,
                                    "Carburant",
                                    category["typeCarburant"],
                                  ),

                                  // Présence de coffre (affiché seulement si capo == 1)
                                  if (category["capo"] == 1)
                                    _buildInfoRow(
                                      Icons.archive,
                                      "Coffre",
                                      category["detailCapo"],
                                    ),

                                  // Fin integration detail

                                  //prix de la course
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.person_2_sharp,
                                        color: Colors.blueGrey,
                                        size: 10,
                                      ),
                                      SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          'Voir le chauffeur:',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _showProfileDriver(
                                            context: context,
                                            driverInfo: category,
                                          );
                                        },
                                        child: Text(
                                          "${CallApi.limitText(category["nameChauffeur"], 7)}...",
                                        ),
                                      ),
                                    ],
                                  ),

                                  //fin prix
                                ],
                              ),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 10),
          SizedBox(width: 2),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  //profil du chauffeur
  Future<void> _showProfileDriver({
    required BuildContext context,
    required Map<String, dynamic> driverInfo,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height:
              MediaQuery.of(context).size.height *
              0.75, // Plus grand pour plus d'infos
          child: Column(
            children: [
              // Barre de fermeture
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 10),

              // Photo du chauffeur
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(
                  "${CallApi.fileUrl}/images/${driverInfo["avatar"] ?? 'avatar.png'}",
                ),
              ),
              SizedBox(height: 10),

              // Nom et numéro
              Text(
                driverInfo["nameChauffeur"] ?? "Nom inconnu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                driverInfo["telephoneChauffeur"] ?? "Numéro non disponible",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 10),

              // Détails supplémentaires
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoCard(
                    "🚗 Véhicule",
                    driverInfo["nomCategorieVehicule"] ?? "Inconnu",
                  ),
                  _infoCard(
                    "📋 Plaque",
                    driverInfo["numPlaqueVehicule"] ?? "Inconnue",
                  ),
                ],
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoCard(
                    "📆 Expérience",
                    "${driverInfo["experience"] ?? '+4'} ans",
                  ),
                  // Bouton d'appel
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.call, size: 15),
                    label: Text("Appeler", style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      _callDriver(driverInfo["telephoneChauffeur"]);
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Notation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color:
                        index < (driverInfo["note"] ?? 3)
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Avis clients
              Text(
                "Avis des clients :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                driverInfo["avis"] ??
                    "Chauffeur expérimenté avec une expérience averée dans la rue",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  // Fonction pour appeler le chauffeur
  void _callDriver(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      launchUrl(Uri.parse("tel:$phoneNumber"));
    } else {
      print("Numéro invalide");
    }
  }

  // Widget pour afficher une carte d'information
  Widget _infoCard(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  //fin profil du chauffeur
}

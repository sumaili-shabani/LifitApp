import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/PaymentScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/PositionChaufeurOnMap.dart';
import 'package:url_launcher/url_launcher.dart';

class Payementcourse extends StatefulWidget {
  final List<dynamic> typeCourses;
  final Map<String, dynamic> trajectoire;
  final Map<String, dynamic> datainfotarification;
  final Map<String, dynamic> categorieVehiculeInfo;
  final int refCategorie;
  final Function(CourseInfoPassagerModel)
  onCategorySelected; // Callback function

  const Payementcourse({
    super.key,
    required this.typeCourses,
    required this.trajectoire,
    required this.datainfotarification,
    required this.categorieVehiculeInfo,
    required this.refCategorie,
    required this.onCategorySelected,
  });

  @override
  State<Payementcourse> createState() => _PayementcourseState();
}

class _PayementcourseState extends State<Payementcourse> {
  bool partageWhatsapp = false;
  bool isLoading = true;
  bool showSearchBar = false;
  TextEditingController searchController = TextEditingController();
  List<CourseInfoPassagerModel> listCourseEncours = [];
  List<CourseInfoPassagerModel> filteredCategories = [];
  Timer? timer; // Timer pour exécuter la fonction périodiquement

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
        filteredCategories = listCourseEncours;

        isLoading = false;
      });

      // print("listCourseEncours: $data");
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCategories = listCourseEncours;
      });
    } else {
      setState(() {
        filteredCategories =
            listCourseEncours
                .where(
                  (category) => category.nameChauffeur!.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      });
    }
  }

  /// 🔹 **Méthode DELETE**
  Future<void> deleteData(int id, int refPassager) async {
    try {
      final response = await CallApi.deleteData(
        "passager_mobile_anullation_course/${id.toInt()}/${refPassager.toInt()}",
      );

      final Map<String, dynamic> responseData = response;
      String message = responseData['data'] ?? "Deleted!!!";
      showSnackBar(context, message, 'success');

      //appelle de la fonction demande
      fetchCourses();
    } catch (e) {
      print('Error fetching demandes: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCourses();

    // Déclenche fetchNotification toutes les 60 secondes
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchCourses();
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Arrêter le timer pour éviter les fuites de mémoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.50, // 50% de l'écran
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
                "Courses en cours",
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
                  hintText: "Rechercher une course...",
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
          SizedBox(height: 10),
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Affiche un loader en attendant l'API
              : Expanded(
                child: ListView.builder(
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    var course = filteredCategories[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 25,
                                    child: Image.network(
                                      '${CallApi.fileUrl}/taxi/${course.imageTypeCourse}',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course.nomTypeCourse!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        course.nameChauffeur!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      Text(
                                        "Prix: ${course.montantCourse} CDF",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Ajouter un bouton payer à droite du prix
                                if (course.status == '4')
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      icon: Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        showPayementBottomSheet(
                                          context,
                                          course,
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                          Colors.green,
                                        ), // Correcte utilisation de MaterialStateProperty
                                        foregroundColor: MaterialStateProperty.all(
                                          Colors.white,
                                        ), // Ajouter une couleur pour le texte/icône
                                      ),
                                      label: Text('Payer'),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text("Destination : ${course.nameDestination!}"),
                            Text(
                              "${course.calculate == 1 ? 'Distance:' : 'Location:'}${course.distance!.toStringAsFixed(2)} ${course.calculate == 1 ? 'Km ➡️${course.timeEst!}' : 'J/H'}",
                            ),
                            course.calculate == 1
                                ? Text(
                                  "Heure d'arrivage : ${CallApi.formatDateString(course.dateLimiteCourse ?? '')}",
                                )
                                : SizedBox(),
                            SizedBox(height: 10),

                            // Affichage du status avec icône
                            Row(
                              children: [
                                Icon(
                                  _getStatusIcon(course.status!),
                                  color: _getStatusColor(course.status!),
                                  size: 13,
                                ),
                                SizedBox(width: 2),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getStatusMessage(course.status!),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(course.status!),
                                      ),
                                    ),
                                     SizedBox(width: 10),

                                    course.status.toString() == '3'
                                        ? TextButton(
                                          onPressed: () {
                                            showMapBottomSheet(context, course);
                                            
                                          },
                                          child: Text("| Voir sa position"),
                                        )
                                        : SizedBox(),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 1),

                            // Boutons Annuler et Partager
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (course.status != '4')
                                  ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      deleteData(
                                        course.id!,
                                        course.refPassager!,
                                      );
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                        Colors.red,
                                      ), // Correcte utilisation de MaterialStateProperty
                                      foregroundColor: MaterialStateProperty.all(
                                        Colors.white,
                                      ), // Ajouter une couleur pour le texte/icône
                                    ),
                                    label: Text('Annuler la course'),
                                  ),
                                // Bouton Commenter
                                IconButton(
                                  onPressed: () {
                                    widget.onCategorySelected(course);
                                  },
                                  icon: Icon(
                                    Icons.comment,
                                    color: Colors.blueAccent,
                                  ),
                                  tooltip: "Commenter",
                                ),
                                // Bouton Partager sur WhatsApp
                                IconButton(
                                  onPressed:
                                      partageWhatsapp
                                          ? null
                                          : () async {
                                            setState(() {
                                              partageWhatsapp = true;
                                            });
                                            Position? position =
                                                await ApiService.getCurrentLocation();
                                            if (position != null) {
                                              setState(() {
                                                partageWhatsapp = false;
                                              });
                                              shareOnWhatsApp(
                                                position.latitude,
                                                position.longitude,
                                                course.nameDestination!,
                                              );
                                            }
                                          },
                                  icon:
                                      partageWhatsapp
                                          ? CircularProgressIndicator(
                                            color: Colors.blue,
                                          )
                                          : Icon(
                                            Icons.share,
                                            color: Colors.teal,
                                          ),
                                  tooltip: "Partager sur WhatsApp",
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
    );
  }

  // Fonction pour obtenir l'icône du status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case '0':
        return Icons.directions_car; // "Course en cours" => icône voiture
      case '1':
        return Icons.check_circle; // "Course terminée" => icône check
      case '2':
        return Icons.timer; // "En attente" => icône de temporisation
      case '3':
        return Icons.directions_car; // "Voiture en route" => icône voiture
      case '4':
        return Icons.location_on; // "Arrivée à destination" => icône arrivée
      default:
        return Icons.error; // Si le status est inconnu
    }
  }

  // Fonction pour obtenir le message du status
  String _getStatusMessage(String status) {
    switch (status) {
      case '0':
        return "Course en cours";
      case '1':
        return "Course terminée";
      case '2':
        return "En attente de réponse du chauffeur";
      case '3':
        return "Voiture en route vers vous";
      case '4':
        return "Course arrivée à destination";
      default:
        return "Status inconnu";
    }
  }

  // Fonction pour obtenir la couleur du status
  Color _getStatusColor(String status) {
    switch (status) {
      case '0':
        return Colors.orange; // "Course en cours" => couleur orange
      case '1':
        return Colors.green; // "Course terminée" => couleur verte
      case '2':
        return Colors.blue; // "En attente" => couleur bleue
      case '3':
        return Colors.amber; // "Voiture en route" => couleur ambre
      case '4':
        return Colors.green; // "Arrivée à destination" => couleur verte
      default:
        return Colors.black; // Couleur par défaut
    }
  }

  // Fonction de partage sur WhatsApp
  void shareOnWhatsApp(
    double latitude,
    double longitude,
    String destination,
  ) async {
    String message =
        "🚖 Course en cours 🚖\n\n"
        "Je suis en route vers *$destination*.\n"
        "Suivez ma position en temps réel ici :\n"
        "📍 https://www.google.com/maps/search/?api=1&query=$latitude,$longitude\n\n"
        "À bientôt !";

    String encodedMessage = Uri.encodeComponent(message);
    String whatsappUrl = "https://wa.me/?text=$encodedMessage";

    Uri uri = Uri.parse(whatsappUrl);

    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // URL ouverte avec succès
    } else {
      print("Impossible d'ouvrir WhatsApp.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "WhatsApp ne peut pas être ouvert. Vérifiez son installation.",
          ),
        ),
      );
    }
  }

  //appel de la fonction de paiement
  void showPayementBottomSheet(
    BuildContext context,
    CourseInfoPassagerModel course,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => PaymentScreen(
            course: course,
            onSubmitComment: (course) {
              // print("idcourse: ${course.id}");

              // Navigator.pop(context); // Ferme le BottomSheet
            },
          ),
    );
  }


   //position actuelle to map
  void showMapBottomSheet(
    BuildContext context,
    CourseInfoPassagerModel course,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => PositionChaufeurOnMap(
            course: course,
            onSubmitComment: (course) {
              // print("idcourse: ${course.id}");
              Navigator.pop(context); // Ferme le BottomSheet
            },
          ),
    );
  }

  //fin position actuelle to map
}

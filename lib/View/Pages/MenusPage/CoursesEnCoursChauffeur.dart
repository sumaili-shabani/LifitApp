import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/ChauffeurDashBoardModel.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/DestinationCourseOnMap.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/PositionPassagerOnMap.dart';
import 'package:lifti_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursesEnCoursChauffeur extends StatefulWidget {
  const CoursesEnCoursChauffeur({super.key});

  @override
  State<CoursesEnCoursChauffeur> createState() =>
      _CoursesEnCoursChauffeurState();
}

class _CoursesEnCoursChauffeurState extends State<CoursesEnCoursChauffeur> {
  TextEditingController searchController = TextEditingController();

  List<CourseInfoPassagerModel> notifications = [];
  List<ChauffeurDashBoardModel> dashInfo = [];

  String searchQuery = "";
  bool isLoading = true;
  bool partageWhatsapp = false;

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        'chauffeur_mobile_course_encours/${userId.toInt()}',
      );
      List<dynamic> dataDash = await CallApi.fetchListData(
        'chauffeur_mobile_dashboard/${userId.toInt()}',
      );

      // print(dataDash);

      setState(() {
        notifications =
            data.map((item) => CourseInfoPassagerModel.fromMap(item)).toList();
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

  /// 🔹 **Méthode Changement de statut**
  Future<void> checkStatutCourse(
    int id,
    String statut,
    int refPassager,
    int refChauffeur,
    String url,
  ) async {
    try {
      final response = await CallApi.deleteData(
        "$url/${id.toInt()}/${statut.toString()}/${refPassager.toString()}/${refChauffeur.toString()}",
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

  /// 🔹 **Méthode DELETE**
  Future<void> deleteData(int id, int refChauffeur) async {
    try {
      final response = await CallApi.deleteData(
        "chauffeur_mobile_anullation_course/${id.toInt()}/${refChauffeur.toInt()}",
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

  /// 🔹 **Méthode DELETE**
  Future<void> deleteDataNoDisponible(int id, int refPassager) async {
    try {
      final response = await CallApi.deleteData(
        "delete_courses_non_disponible/${id.toInt()}/${refPassager.toString()}",
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

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    fetchNotifications();

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchNotifications();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Arrêter le timer pour éviter les fuites de mémoire
    super.dispose();
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
        "🚖 Chauffeur en mission 🚖\n\n"
        "Je viens de prendre un passager et je me dirige vers *$destination*.\n"
        "Suivez ma position en temps réel ici :\n"
        "📍 https://www.google.com/maps/search/?api=1&query=$latitude,$longitude\n\n"
        "Je reste joignable en cas de besoin. À bientôt !";

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
          (context) => PositionPassagerOnMap(
            course: course,
            onSubmitComment: (course) {
              // print("idcourse: ${course.id}");

              Navigator.pop(context); // Ferme le BottomSheet
            },
          ),
    );
  }
  //fin position actuelle to map

   
  //position actuelle to map
  void showDestinationMapBottomSheet(
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
          (context) => Destinationcourseonmap(
            course: course,
            onSubmitComment: (course) {
              // print("idcourse: ${course.id}");
              Navigator.pop(context); // Ferme le BottomSheet
            },
          ),
    );
  }

  //fin destination de la course

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return isLoading
        ? Center(
          child: CircularProgressIndicator(),
        ) // Affiche un loader en attendant l'API
        : Column(
          children: [
            // 🔍 CHAMP DE RECHERCHE
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: TextField(
                controller: searchController,
                onChanged:
                    (value) =>
                        setState(() => searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Rechercher une course...",
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  filled: true,
                  // fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 📋 LISTE DES COURSES
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  var course = notifications[index];

                  if (!course.namePassager!.toLowerCase().contains(
                        searchQuery,
                      ) &&
                      !course.dateCourse!.toLowerCase().contains(searchQuery)) {
                    return Container();
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🧑 INFOS CLIENT
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "${CallApi.fileUrl}/images/${course.avatarPassager ?? 'avatar.png'}",
                                ),
                                radius: 25,
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.namePassager!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${course.calculate == 1 ? 'Distance:' : 'Location:'}${course.distance!.toStringAsFixed(2)} ${course.calculate == 1 ? 'Km ➡️${course.timeEst!}' : 'J/H'}",
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "${course.montantCourse!.toString()} CDF",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Divider(color: Colors.grey,),
                          SizedBox(height: 5),

                          // mes ajouts
                          Row(
                            children: [
                              Icon(Icons.local_taxi, size: 16),
                              SizedBox(width: 5),
                              Text(
                                "Type de course: ${course.nomTypeCourse ?? ''}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: ConfigurationApp.successColor,
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  "Départ: ${course.nameDepart ?? ''}",
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.flag,
                                size: 16,
                                color: ConfigurationApp.dangerColor,
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  "Arrivée: ${course.nameDestination ?? ''}",
                                ),
                              ),
                            ],
                          ),

                          course.calculate == 1
                              ? Row(
                                children: [
                                  Icon(Icons.timer, size: 16),
                                  SizedBox(width: 5),
                                  Text(
                                    "Heure d'arrivage : ${CallApi.formatDateString(course.dateLimiteCourse ?? '')}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                              : SizedBox(),

                          SizedBox(height: 2),
                          // fin ajouts

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
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.45,
                                    child: Text(
                                    _getStatusMessage(course.status!),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(course.status!),
                                    ),
                                  ),
                                  ),
                                  SizedBox(width: 10),

                                  course.status.toString() == '2'
                                      ? TextButton(
                                        onPressed: () {
                                          showMapBottomSheet(context, course);
                                        },
                                        child: Text("| Voir sa position"),
                                      )
                                      : course.status.toString() == '0' ||
                                          course.status.toString() == '1' ||
                                          course.status.toString() == '3' ||
                                          course.status.toString() == '4'
                                      ? TextButton(
                                        onPressed: () {
                                          showDestinationMapBottomSheet(
                                            context,
                                            course,
                                          );
                                        },
                                        child: Text(
                                          "| Voir le trajet",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      )
                                      : SizedBox(),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 1),

                          // 📍 DÉTAILS DU TRAJET
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // destination
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                color: Colors.grey,
                                                size: 18,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                CallApi.getFormatedDate(
                                                  course.dateCourse.toString(),
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10),
                                    ],
                                  ),

                                  course.status.toString() == '2'
                                      ? TextButton.icon(
                                        onPressed: () {
                                          showMapBottomSheet(context, course);
                                        },
                                        icon: Icon(Icons.map),
                                        label: Text("Voir sa position"),
                                      )
                                      : SizedBox(),
                                ],
                              ),
                            ],
                          ),
                          // menu de boutton
                          SizedBox(height: 1),

                          // Boutons Annuler et Partager
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (course.status != '4')
                                buildCourseButtons(
                                  course,
                                  course.id!,
                                  course.status!,
                                  theme,
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
                                        : Icon(Icons.share, color: Colors.teal),
                                tooltip: "Partager sur WhatsApp",
                              ),
                            ],
                          ),

                          // fin menu de boutton
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }

  Widget buildCourseButtons(
    CourseInfoPassagerModel course,
    int courseId,
    String courseStatus,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

      children: [
        if (courseStatus == '2')
          Row(
            children: [
              if (course.calculate == 1)
                ElevatedButton.icon(
                  onPressed: () {
                    checkStatutCourse(
                      courseId,
                      courseStatus,
                      course.refPassager!,
                      course.refChauffeur!,
                      "checkEtat_DemandeCourse",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size(60, 30),
                  ),
                  icon: Icon(Icons.local_taxi_outlined),
                  label: Text("Accepter", style: TextStyle(fontSize: 12)),
                ),
              if (course.calculate == 0)
                ElevatedButton.icon(
                  onPressed: () {
                    checkStatutCourse(
                      courseId,
                      courseStatus,
                      course.refPassager!,
                      course.refChauffeur!,
                      "checkEtat_DisponibiliteLocationCourse",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size(60, 30),
                  ),
                  icon: Icon(Icons.local_taxi_outlined),
                  label: Text("Disponible", style: TextStyle(fontSize: 12)),
                ),

              SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: () {
                  deleteDataNoDisponible(courseId, course.refPassager!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConfigurationApp.dangerColor,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  minimumSize: Size(60, 30),
                ),
                icon: Icon(Icons.no_backpack_rounded),
                label: Text("Non disponible", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),

        if (courseStatus == '3')
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  checkStatutCourse(
                    courseId,
                    courseStatus,
                    course.refPassager!,
                    course.refChauffeur!,
                    "checkEtat_DemarerCourse",
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  minimumSize: Size(60, 30),
                ),
                icon: Icon(Icons.on_device_training),
                label: Text(
                  "Demarer la course",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        if (courseStatus == '0')
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  checkStatutCourse(
                    courseId,
                    courseStatus,
                    course.refPassager!,
                    course.refChauffeur!,
                    "checkEtat_DestinationCompleteCourse",
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  minimumSize: Size(60, 30),
                ),
                icon: Icon(Icons.check_circle),
                label: Text("Terminé", style: TextStyle(fontSize: 12)),
              ),

              SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: () {
                  deleteData(course.id!, course.refChauffeur!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConfigurationApp.dangerColor,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  minimumSize: Size(60, 30),
                ),
                icon: Icon(Icons.close_outlined),
                label: Text(
                  "Annuler la course",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// 📊 WIDGET DE STATISTIQUE
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.darkGreen),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 14)),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

 
}

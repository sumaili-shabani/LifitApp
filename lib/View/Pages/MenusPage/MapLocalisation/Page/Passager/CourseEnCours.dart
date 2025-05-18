import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/CarteCourseSelectionPosition.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/Commentaire.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/DestinationCourseOnMap.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/PaymentScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/PositionChaufeurOnMap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PassagerCourseEnCourse extends StatefulWidget {
  const PassagerCourseEnCourse({super.key});
  @override
  State<PassagerCourseEnCourse> createState() => _PassagerCourseEnCourseState();
}

class _PassagerCourseEnCourseState extends State<PassagerCourseEnCourse> {
  List<CourseInfoPassagerModel> notifications = [];
  String searchQuery = "";
  bool isLoading = true;
  bool partageWhatsapp = false;
  Timer? _timer;

  Future<void> statutPlaceAdd(int refVehicule, String operation) async {
    try {
      int? userId =
          await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      Map<String, dynamic> svData = {
        "refVehicule": refVehicule,
        "operation": operation,
        "idUser": userId,
      };
      final response = await CallApi.insertData(
        endpoint: "updateCountPlaceOnvehicule",
        data: svData,
      );
      final Map<String, dynamic> responseData = response;
      String message = responseData['data'] ?? "";
      showSnackBar(context, message, 'success');
    } catch (e) {
      print('Error fetching demandes: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    // Déclenche fetchNotification toutes les 60 secondes
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchNotifications();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Arrêter le timer pour éviter les fuites de mémoire
    super.dispose();
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
      fetchNotifications();
    } catch (e) {
      print('Error fetching demandes: $e');
    }
  }

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        'passager_mobile_course_encours/${userId.toInt()}',
      );
      setState(() {
        notifications =
            data.map((item) => CourseInfoPassagerModel.fromMap(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
     final l10n = AppLocalizations.of(context)!;
    return isLoading
        ? Center(
          child: CircularProgressIndicator(),
        ) // Affiche un loader en attendant l'API
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.course_en_course_titre,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...notifications.map(
              (course) => Card(
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 15,
                              child: Image.network(
                                '${CallApi.fileUrl}/images/${course.avatarChauffeur}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.nomTypeCourse!,
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                  "${l10n.course_en_course_prix}: ${course.montantCourse} CDF",
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
                                  showPayementBottomSheet(context, course);
                                  statutPlaceAdd(course.refVehicule!, "Sub");
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.green,
                                  ), // Correcte utilisation de MaterialStateProperty
                                  foregroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ), // Ajouter une couleur pour le texte/icône
                                ),
                                label: Text(l10n.course_en_course_payer),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text("${l10n.course_en_course_destination} : ${course.nameDestination!}"),
                      Text(
                        "${course.calculate == 1 ? '${l10n.info_distance}:' : 'Location:'}${course.distance!.toStringAsFixed(2)} ${course.calculate == 1 ? 'Km ➡️${course.timeEst!}' : 'J/H'}",
                      ),
                      course.calculate == 1
                          ? Text(
                            "${l10n.course_en_course_heure_arrivage} : ${CallApi.formatDateString(course.dateLimiteCourse ?? '')}",
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getStatusMessage(context, course.status!),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(course.status!),
                                ),
                              ),

                              Column(
                                children: [
                                  SizedBox(width: 10),
                                  course.status.toString() == '3'
                                      ? TextButton(
                                        onPressed: () {
                                          showMapBottomSheet(context, course);
                                        },
                                        child: Text("| ${l10n.course_en_course_voirPosition}"),
                                      )
                                      : course.status.toString() == '0' ||
                                          course.status.toString() == '1' ||
                                          course.status.toString() == '4'
                                      ? TextButton(
                                        onPressed: () {
                                          showDestinationMapBottomSheet(
                                            context,
                                            course,
                                          );
                                        },
                                        child: Text(
                                          "| ${l10n.course_en_course_voir_trajet}",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      )
                                      : SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      course.status.toString() == '2'
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.amp_stories_sharp, size: 16,),
                                  SizedBox(width: 2,),
                                  Text(l10n.course_en_course_question_arret),
                                ],
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                       Navigator.of(context).push(
                                        AnimatedPageRoute(
                                          page: CarteCourseSelectionPosition(
                                            course: course,
                                          ),
                                        ),
                                      );
                                      

                                    },
                                    child: Text(
                                      "| ${l10n.course_en_course_ajout_arret}",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                          : SizedBox(),

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
                                deleteData(course.id!, course.refPassager!);
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.red,
                                ), // Correcte utilisation de MaterialStateProperty
                                foregroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ), // Ajouter une couleur pour le texte/icône
                              ),
                              label: Text(l10n.course_en_course_anuller_course),
                            ),
                          // Bouton Commenter
                          IconButton(
                            onPressed: () {
                              showRatingBottomSheet(context, course);
                            },
                            icon: Icon(Icons.comment, color: Colors.blueAccent),
                            tooltip: l10n.course_en_course_commenter,
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
                                          context,
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
                            tooltip: l10n.course_en_course_partager,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

  //destination de la course sur le map

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

  
 

  void showRatingBottomSheet(
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
          (context) => CommentaireCourse(
            course: course,
            onSubmitComment: (course) {
              // print("idcourse: ${course.id}");

              Navigator.pop(context); // Ferme le BottomSheet
            },
          ),
    );
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
  String _getStatusMessage(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case '0':
        return "${l10n.course_etat_encours}";
      case '1':
        return "${l10n.course_etat_terminee}";
      case '2':
        return "${l10n.course_etat_attente_chauffeur}";
      case '3':
        return "${l10n.course_etat_voiture_en_route}";
      case '4':
        return "${l10n.course_etat_arrivee}";
      default:
        return "${l10n.course_etat_inconnu}";
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
    BuildContext context,
    double latitude,
    double longitude,
    String destination,
  ) async {
     final l10n = AppLocalizations.of(context)!;
    String message =
        "🚖 ${l10n.course_etat_encours} 🚖\n\n"
        "${l10n.course_en_course_destination_share} Je suis en route vers *$destination*.\n"
        "${l10n.share_suivez_ma_position} :\n"
        "📍 https://www.google.com/maps/search/?api=1&query=$latitude,$longitude\n\n"
        "${l10n.share_leter}";

    String encodedMessage = Uri.encodeComponent(message);
    String whatsappUrl = "https://wa.me/?text=$encodedMessage";

    Uri uri = Uri.parse(whatsappUrl);

    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // URL ouverte avec succès
    } else {
      // print("Impossible d'ouvrir WhatsApp.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.share_error_whatsapp,
          ),
        ),
      );
    }
  }
}

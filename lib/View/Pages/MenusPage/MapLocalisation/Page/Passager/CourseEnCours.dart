import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    fetchNotifications();
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
    return isLoading
        ? Center(
          child: CircularProgressIndicator(),
        ) // Affiche un loader en attendant l'API
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Courses en cours",
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                          ],
                        ),
                        SizedBox(height: 8),
                       
                       
                        Text("Destination : ${course.nameDestination!}"),
                        Text(
                          "Distance : ${course.distance!}km/${course.timeEst!} min",
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Bouton Payer
                            IconButton(
                              onPressed: () {
                               
                              },
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              tooltip: "Payer",
                            ),
                            // Bouton Annuler
                            IconButton(
                              onPressed: () {
                                deleteData(course.id!, course.refPassager!);
                              },
                              icon: Icon(Icons.close, color: Colors.red),
                              tooltip: "Annuler la course",
                            ),
                            // Bouton Commenter
                            IconButton(
                              onPressed: () {
                                // Ajouter ici l’action pour commenter
                                // widget.onCategorySelected(course);
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
                                      : Icon(Icons.share, color: Colors.teal),

                              tooltip: "Partager sur WhatsApp",
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
}

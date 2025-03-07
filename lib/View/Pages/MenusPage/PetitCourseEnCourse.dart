import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';

import 'package:lifti_app/Model/CourseModel.dart';

class PetitCourseEnCourse extends StatefulWidget {
  const PetitCourseEnCourse({super.key});
  @override
  State<PetitCourseEnCourse> createState() => _PetitCourseEnCourseState();
}

class _PetitCourseEnCourseState extends State<PetitCourseEnCourse> {
  List<CourseModel> notifications = [];
  String searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  
  /// 🔹 **Méthode DELETE**
  Future<void> deleteData(int id, String statut) async {
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
      setState(() {
        notifications = data.map((item) => CourseModel.fromMap(item)).toList();
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    12,
                  ), // 🔥 Ajout de padding pour un meilleur design
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween, // 🔥 Sépare bien les éléments
                    children: [
                      // ✅ Icône et infos du client
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Colors.blue,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.namePassager!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: Text(
                                 course.nameDestination!,
                                    maxLines: 4,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Text(
                                '${course.distance.toString()} Km de distance',
                                maxLines: 4,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // ✅ Bonus + Bouton Accepter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Prix: ${course.montantCourse} CDF",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: Icon(Icons.check_circle_outline, color: Colors.white,),
                             onPressed: () {
                              deleteData(course.id!, course.status!);
                            },
                           
                           style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              minimumSize: Size(60, 30),
                            ),
                             label: Text(
                              "Accepter",
                              style: TextStyle(fontSize: 14),
                            ),
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
}

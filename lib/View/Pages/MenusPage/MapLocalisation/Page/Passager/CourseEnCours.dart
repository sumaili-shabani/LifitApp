import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';

class PassagerCourseEnCourse extends StatefulWidget {
  const PassagerCourseEnCourse({super.key});
  @override
  State<PassagerCourseEnCourse> createState() => _PassagerCourseEnCourseState();
}

class _PassagerCourseEnCourseState extends State<PassagerCourseEnCourse> {
  List<CourseInfoPassagerModel> notifications = [];
  String searchQuery = "";
  bool isLoading = true;

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
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ✅ Image de la voiture
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 25,
                          child: Image.network(
                            '${CallApi.fileUrl}/taxi/${course.imageTypeCourse}',
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // ✅ Infos sur la course
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.namePassager!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              course.nameDestination!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.local_taxi,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    course.nomTypeCourse!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${course.distance.toString()} Km -${course.timeEst.toString()} min',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ✅ Nom du chauffeur + Prix + Bouton
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            course.nameChauffeur!, // 🔥 Nom du chauffeur
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 4),
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
                            icon: Icon(Icons.cancel, color: Colors.white),
                            onPressed: () {
                              deleteData(course.id!, course.refPassager!);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            label: Text(
                              "Annuler",
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

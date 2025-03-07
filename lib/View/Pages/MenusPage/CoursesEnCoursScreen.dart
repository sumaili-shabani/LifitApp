import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/ChauffeurDashBoardModel.dart';
import 'package:lifti_app/Model/CourseModel.dart';
import 'package:lifti_app/core/theme/app_theme.dart';

class CoursesEnCoursScreen extends StatefulWidget {
  const CoursesEnCoursScreen({super.key});

  @override
  State<CoursesEnCoursScreen> createState() => _CoursesEnCoursScreenState();
}

class _CoursesEnCoursScreenState extends State<CoursesEnCoursScreen> {
  TextEditingController searchController = TextEditingController();

  List<CourseModel> notifications = [];
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
        'chauffeur_mobile_course_encours/${userId.toInt()}',
      );
      List<dynamic> dataDash = await CallApi.fetchListData(
        'chauffeur_mobile_dashboard/${userId.toInt()}',
      );

      // print(dataDash);

      setState(() {
        notifications = data.map((item) => CourseModel.fromMap(item)).toList();
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

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.car_crash),
        title: Text("Courses en cours"),
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchNotifications();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Affiche un loader en attendant l'API
              : Column(
                children: [
                  // 📊 STATISTIQUES GLOBALES
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatCard(
                          label: "Total Courses",
                          value: dashInfo.length.toString(),
                          icon: Icons.car_crash,
                        ),
                        StatCard(
                          label: "Moy. Distance",
                          value:
                              "${dashInfo.isNotEmpty ? dashInfo.first.sumDistanceCourseEncours.toString() : 0} Km",
                          icon: Icons.map,
                        ),
                        StatCard(
                          label: "Moy. Prix",
                          value:
                              "${dashInfo.isNotEmpty ? dashInfo.first.sumMontantCourseEncours.toString() : 0} CDF",
                          icon: Icons.bar_chart_sharp,
                        ),
                      ],
                    ),
                  ),

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
                        )) {
                          return Container();
                        }

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.namePassager!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${course.distance ?? '0'} Km",
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontSize: 14,
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

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.car_repair_sharp,
                                              size: 13,
                                            ),

                                            Text(
                                              " ${course.nomTypeCourse ?? ''}",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                                // 📍 DÉTAILS DU TRAJET
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // destination
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: theme.primaryColor,
                                                ),
                                                SizedBox(width: 5),
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    "Départ : ${course.nameDepart ?? ''}",
                                                    maxLines: 3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.flag,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 5),
                                               
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    "Arrivée : ${course.nameDestination ?? ''}",
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 10),
                                          ],
                                        ),
                                        Spacer(),

                                        //pour les bouttons
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 💰 BOUTONS ACTIONS (au-dessus du prix)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    checkStatutCourse(
                                                      course.id!,
                                                      course.status!,
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            theme.primaryColor,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5,
                                                            ),
                                                        minimumSize: Size(
                                                          60,
                                                          30,
                                                        ),
                                                      ),
                                                  child: Text(
                                                    "Accepter",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
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

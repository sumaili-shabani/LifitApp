import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Model/ChauffeurDashBoardModel.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/CoursesEnCoursChauffeur.dart';

class CoursesEnCoursScreen extends StatefulWidget {
  const CoursesEnCoursScreen({super.key});

  @override
  State<CoursesEnCoursScreen> createState() => _CoursesEnCoursScreenState();
}

class _CoursesEnCoursScreenState extends State<CoursesEnCoursScreen> {
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

  

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    fetchNotifications();

  }

  @override
  void dispose() {
    _timer?.cancel(); // Arrêter le timer pour éviter les fuites de mémoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("Courses en cours", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () {
              fetchNotifications();
            },
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
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Affiche un loader en attendant l'API
              : Column(
                children: [
                  SizedBox(height: 10),
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

                  Expanded(child: CoursesEnCoursChauffeur()),
                ],
              ),
    );
  }
}

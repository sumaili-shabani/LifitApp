import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
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

      print("listCourseEncours: $data");
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
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.5, // 60% de l'écran
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

                  print("showSearchBar: $showSearchBar");
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
                                      : Icon(Icons.share, color: Colors.teal),

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

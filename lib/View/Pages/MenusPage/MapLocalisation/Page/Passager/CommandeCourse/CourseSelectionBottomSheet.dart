import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';

class CourseSelectionBottomSheet extends StatelessWidget {
  final List<dynamic> typeCourses;
  final List<dynamic> typeCourseLocation;
  final Function(Map<String, dynamic>, bool)
  onCourseSelected; // ✅ Ajout de bool

  const CourseSelectionBottomSheet({
    super.key,
    required this.typeCourses,
    required this.onCourseSelected,
    required this.typeCourseLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.65, // 75% de l'écran
      padding: EdgeInsets.all(16),
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
          SizedBox(height: 10),

          Text(
            "🚖 Choisissez votre course en un instant !",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Profitez d'un service rapide, sécurisé et adapté à vos besoins. Réservez maintenant et arrivez à destination en toute sérénité !",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 10),
          // bouton de navigation
          Expanded(
            child: DefaultTabController(
              length: 2, // Nombre d'onglets
              child: Column(
                children: [
                  ButtonsTabBar(
                    backgroundColor:
                        Colors.green, // Couleur des onglets sélectionnés
                    unselectedBackgroundColor: Colors.grey[300],
                    unselectedLabelStyle: TextStyle(color: Colors.black),
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(
                        text: "Course taxi",
                        icon: Icon(Icons.local_taxi, size: 17),
                      ),
                      Tab(
                        text: "Location véhicule",
                        icon: Icon(Icons.directions_car, size: 17),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          itemCount: typeCourses.length,
                          itemBuilder: (context, index) {
                            final course = typeCourses[index];
                            return _buildCourseItem(course, false, onCourseSelected);
                          },
                        ),
                        // pour la location
                        ListView.builder(
                          itemCount: typeCourseLocation.length,
                          itemBuilder: (context, index) {
                            final courseLocation = typeCourseLocation[index];
                            return _buildCourseItem(
                              courseLocation, true, onCourseSelected);
                          },
                        ),
                        // Center(
                        //   child: Text("Location de véhicule en construction"),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCourseItem(
  Map<String, dynamic> course,
  bool isLocation, // ✅ Ajout du booléen
  Function(Map<String, dynamic>, bool) onCourseSelected,
) {
  return GestureDetector(
    onTap: () {
      onCourseSelected(course, isLocation); // ✅ On envoie le booléen ici
    },
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            if (course['imageTypeCourse'] != null &&
                course['imageTypeCourse'].toString().isNotEmpty)
              Image.network(
                "${CallApi.fileUrl}/taxi/${course['imageTypeCourse']}",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            else
              Icon(
                Icons.local_taxi,
                size: 60,
                color: ConfigurationApp.successColor,
              ),
            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        course["nomTypeCourse"] ?? "Nom inconnu",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, size: 14),
                      SizedBox(width: 5),
                      Text(
                        "${course['prix'] ?? 0} ${course['devise'] ?? 'N/A'} (${course['unite'] ?? 'Unité inconnue'})",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    ),
  );
}
// Widget pour afficher la remise
Widget notifcationRemiseWidget(Map<String, dynamic> course) {
  if (course['remise'] == null || course['remise'] <= 0) {
    return SizedBox.shrink();
  }

  return Chip(
    label: Text(
      "-${course['remise']}%",
      style: TextStyle(
        color: Colors.white,
        fontSize: 14, // Réduction de la taille du texte
      ),
    ),
    backgroundColor: Colors.red,
    padding: EdgeInsets.zero, // Supprime le padding interne
    materialTapTargetSize:
        MaterialTapTargetSize.shrinkWrap, // Réduit la hauteur du Chip
    visualDensity: VisualDensity.compact, // Réduit l'espace autour du Chip
  );
}

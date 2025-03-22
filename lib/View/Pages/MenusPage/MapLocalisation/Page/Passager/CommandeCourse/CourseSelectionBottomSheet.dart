import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';

class CourseSelectionBottomSheet extends StatelessWidget {
  final List<dynamic> typeCourses;
  final Function(Map<String, dynamic>) onCourseSelected; // Callback function

  const CourseSelectionBottomSheet({
    super.key,
    required this.typeCourses,
    required this.onCourseSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60, // 75% de l'écran
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Expanded(
            child: ListView.builder(
              itemCount: typeCourses.length,
              itemBuilder: (context, index) {
                final course = typeCourses[index];
                return _buildCourseItem(course, onCourseSelected);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Fonction pour construire un item de la liste
Widget _buildCourseItem(
  Map<String, dynamic> course,
  Function(Map<String, dynamic>) onCourseSelected,
) {
  return GestureDetector(
    onTap: () {
      onCourseSelected(
        course,
      ); // Appel de la fonction callback
    },
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Vérification de l'image pour éviter l'erreur de null
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
                  Column(
                    children: [
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
                ],
              ),
            ),

            Row(
              children: [
                // if (course['remise'] != null && course['remise'] > 0)
                //   notifcationRemiseWidget(course),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
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

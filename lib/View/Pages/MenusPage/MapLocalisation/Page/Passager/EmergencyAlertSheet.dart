
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:url_launcher/url_launcher.dart';



class EmergencyAlertSheet extends StatefulWidget {
  final int userId;
  const EmergencyAlertSheet({super.key, required this.userId});

  @override
  State<EmergencyAlertSheet> createState() => _EmergencyAlertSheetState();
}

class _EmergencyAlertSheetState extends State<EmergencyAlertSheet> {
  bool isLoading = false;
  String selectedAlertType = 'Kidnapping'; // Type d'alerte par défaut

  final List<Map<String, dynamic>> alertTypes = [
    {'type': 'Kidnapping', 'icon': Icons.lock_person, 'color': Colors.red},
    {
      'type': 'Enlèvement',
      'icon': Icons.directions_run,
      'color': Colors.orange,
    },
    {'type': 'Agression', 'icon': Icons.report_problem, 'color': Colors.amber},
    {'type': 'Autre menance', 'icon': Icons.help, 'color': Colors.grey},
  ];

  sendEmergencyAlert() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Obtenir la position GPS actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Données à envoyer à l'API
      Map<String, dynamic> svData = {
        'id': "", // Assurez-vous que ce champ est bien traité par l’API
        'user_id': widget.userId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'typeAlerte': selectedAlertType,
        'status': 'En attente',
      };

      // Envoyer la requête à l'API Laravel
      var response = await CallApi.insertOrUpdateData(
        'mobile_user_store_alert',
        svData,
      );

   

      print("Code de réponse : ${response.statusCode}");
      print("Réponse de l'API : ${response.body}");

      // Vérifier si la requête a réussi
      if (response.statusCode == 201 || response.statusCode == 200) {
         showSnackBar(context, "✅ Alerte envoyée avec succès !", "success");

         Navigator.pop(context);

        // Si l'alerte est de type "Kidnapping" ou "Enlèvement", partager la position
        if (selectedAlertType == "Kidnapping" ||
            selectedAlertType == "Enlèvement" ||
            selectedAlertType == 'Agression' ||
            selectedAlertType == 'Autre menance') {
          shareOnWhatsApp(
            position.latitude,
            position.longitude,
            selectedAlertType,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Erreur lors de l’envoi de l’alerte. Code: ${response.statusCode}',
            ),
          ),
        );
      }

    
    } catch (error) {
      // Gérer les erreurs (ex: absence de connexion)
      print("Erreur: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Erreur: Impossible d’envoyer l’alerte. Vérifiez votre connexion.',
          ),
        ),
      );
    } finally {
      // Toujours arrêter le chargement même en cas d'erreur
      setState(() {
        isLoading = false;
      });
    }
  }

 void shareOnWhatsApp(
    double latitude,
    double longitude,
    String alertType,
  ) async {
    String message =
        "🚨 Alerte URGENTE 🚨\n\n"
        "Je suis en danger ! Type d'alerte : *$alertType*\n"
        "Ma position : https://www.google.com/maps/search/?api=1&query=$latitude,$longitude\n\n"
        "Aide-moi au plus vite !";

    String encodedMessage = Uri.encodeComponent(message);
    String whatsappUrl =
        "https://wa.me/?text=$encodedMessage"; // URL WhatsApp correcte

    Uri uri = Uri.parse(whatsappUrl);

    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // await launchUrl(uri, mode: LaunchMode.externalApplication);
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⚠️ Alerte de Secours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Sélectionnez le type d’alerte et envoyez une notification aux secours.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),

          // Sélection du type d’alerte
          Wrap(
            spacing: 10,
            children:
                alertTypes.map((alert) {
                  return ChoiceChip(
                    label: Text(alert['type']),
                    avatar: Icon(alert['icon'], color: alert['color']),
                    selected: selectedAlertType == alert['type'],
                    onSelected: (bool selected) {
                      setState(() {
                        selectedAlertType = alert['type'];
                      });
                    },
                    selectedColor: alert['color'].withOpacity(0.3),
                    backgroundColor: theme.hoverColor,
                  );
                }).toList(),
          ),

          SizedBox(height: 20),
          isLoading
              ? CircularProgressIndicator()
              : ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: sendEmergencyAlert,
                icon: Icon(Icons.sos, color: Colors.white),
                label: Text(
                  'Envoyer une alerte',
                  style: TextStyle(color: Colors.white),
                ),
              ),
        ],
      ),
    );
  }
}

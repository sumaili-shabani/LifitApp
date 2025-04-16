import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Model/VehiculeModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/AvatarFichierVehicule.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/AvatarImageVehicule.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/composants/AssocierChauffeur.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/composants/TaxiProfileScreen.dart';

class MenuActionBottom extends StatefulWidget {
  final VoitureModel voiture;
  final Function(VoitureModel voiture) onClicIconButton;
  const MenuActionBottom({
    super.key,
    required this.voiture,
    required this.onClicIconButton,
  });

  @override
  State<MenuActionBottom> createState() => _MenuActionBottomState();
}

class _MenuActionBottomState extends State<MenuActionBottom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height:
          MediaQuery.of(context).size.height *
          0.40, // Augmenté à 75% pour plus de visibilité
      width: MediaQuery.of(context).size.width * 1,
      child: SingleChildScrollView(
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

            //boutton de recherche
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                // Bouton Éditer Photo
                Row(
                  children: [
                    _buildCard(
                      icon: Icons.image,
                      color: ConfigurationApp.successColor,
                      title: "Éditer Photo",
                      subtitle: "Modifier l'image du véhicule",
                      onTap: () {
                        showEditPhotoVehicluleBottomSheet(
                          context,
                          widget.voiture,
                        );
                      },
                    ),

                    // Bouton Éditer Document
                    _buildCard(
                      icon: Icons.picture_as_pdf,
                      color: ConfigurationApp.warningColor,
                      title: "Éditer Document",
                      subtitle: "Modifier le document du véhicule",
                      onTap: () {
                        showEditFichierVehicluleBottomSheet(
                          context,
                          widget.voiture,
                        );
                      },
                    ),
                  ],
                ),

                // Bouton Voir Profil Véhicule
                Row(
                  children: [
                    _buildCard(
                      icon: Icons.directions_car,
                      color: Colors.blue,
                      title: "Profil Véhicule",
                      subtitle: "Voir les détails des informations du véhicule",
                      onTap: () {
                        showProfilTaxiBottomSheet(context, widget.voiture);
                      },
                    ),

                    // Bouton Associer au Chauffeur
                    _buildCard(
                      icon: Icons.person_add,
                      color: Colors.green,
                      title: "Associer au Chauffeur",
                      subtitle: "Attribuer ce véhicule à un chauffeur",
                      onTap: () {
                        showAddChauffeurToTaxiBottomSheet(
                          context,
                          widget.voiture,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // Liste de revenu
            //Fin liste de revenu
          ],
        ),
      ),
    );
  }

  // Fonction pour générer une carte réutilisable
  Widget _buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 30),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //image bottom
  void showEditPhotoVehicluleBottomSheet(
    BuildContext context,
    VoitureModel voiture,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AvatarImageVehicule(
          vehicule: voiture,
          onClicFunction: (voiture) {
            // print("voiture: ${voiture.nomCategorieVehicule}");
            widget.onClicIconButton(voiture);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  //fichier
  void showEditFichierVehicluleBottomSheet(
    BuildContext context,
    VoitureModel voiture,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AvatarFichierVehicule(
          vehicule: voiture,
          onClicFunction: (voiture) {
            // print("voiture: ${voiture.nomCategorieVehicule}");
            widget.onClicIconButton(voiture);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  //menu profil
  void showProfilTaxiBottomSheet(BuildContext context, VoitureModel voiture) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TaxiProfileScreen(voiture: voiture);
      },
    );
  }

  //menu profil
  void showAddChauffeurToTaxiBottomSheet(
    BuildContext context,
    VoitureModel voiture,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AssocierVoitureChauffeur(
          vehicule: voiture,
          onClicFunction: (voiture) {
            widget.onClicIconButton(voiture);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

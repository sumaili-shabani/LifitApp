import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/TaxiAssChauffeurModel.dart';
import 'package:lifti_app/Model/VehiculeModel.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

class TaxiProfileScreen extends StatefulWidget {
  final VoitureModel voiture;
  const TaxiProfileScreen({super.key, required this.voiture});

  @override
  State<TaxiProfileScreen> createState() => _TaxiProfileScreenState();
}

class _TaxiProfileScreenState extends State<TaxiProfileScreen> {
  late List<TaxiAssChauffeurModel> TaxiList = [];
  bool isLoading = true;
  int idRole = 0;

  Future<void> fetchUser() async {
    int? roleId = await CallApi.getUserRole();

    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    //passager
    List<dynamic> dataDash = await CallApi.fetchListData(
      'get_profile_taxi_vehicule/${widget.voiture.id!.toString()}',
    );
    // print(dataDash);
    setState(() {
      idRole = roleId!;
      TaxiList =
          dataDash.map((item) => TaxiAssChauffeurModel.fromMap(item)).toList();
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height:
          MediaQuery.of(context).size.height *
          0.75, // Augmenté à 75% pour plus de visibilité
      width: MediaQuery.of(context).size.width * 1,
      child: Column(
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
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                child: ListView.builder(
                  itemCount: TaxiList.length,
                  itemBuilder: (context, index) {
                    var taxi = TaxiList[index];
                    return Column(
                      children: [
                        _buildVehicleCard(taxi),
                        SizedBox(height: 16),
                        _buildDriverCard(taxi),
                      ],
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  /*
  *
  *=============================
  * Telechargement
  *=============================
  *
  */
  bool isDownloading = false;
  double progress = 0.0;

  Future<void> downloadFile(fileName) async {
    try {
      setState(() {
        isDownloading = true;
        progress = 0.0;
      });

      // Obtenir le répertoire de stockage
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${CallApi.fileUrl}/taxi/${fileName.toString()}";
      print("url du fichier: $filePath");

      // Initialiser Dio
      Dio dio = Dio();
      await dio.download(
        fileName.toString(),
        filePath,
        onReceiveProgress: (received, total) {
          setState(() {
            progress = (received / total);
          });
        },
      );

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Téléchargement terminé : $filePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      print("Erreur: $e");
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }


  /*
  *
  *===========================
  *Fin telechargement
  *===========================
  *
  */

  Widget _buildVehicleCard(TaxiAssChauffeurModel voiture) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("Informations du véhicule", LucideIcons.car),
            SizedBox(height: 8),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "${CallApi.fileUrl}/taxi/${voiture.imageVehicule??'taxi.png'}",
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8),
            _buildInfoRow("Marque", voiture.nomMarque??''),
            _buildInfoRow("Nombre de sièges", voiture.nbrPlace.toString()),
            _buildInfoRow("Coffre", voiture.detailCapo??''),
            _buildInfoRow("Année", voiture.dateFabrication??''),
            _buildInfoRow("Couleur", voiture.nomCouleur??''),
            _buildInfoRow("Plaque", voiture.numPlaqueVehicule??''),
            _buildInfoRow("Type de carburant", voiture.typeCarburant??''),
            _buildBadge("Disponibilité", "Disponible", Colors.green),
            SizedBox(height: 8),
            voiture.fileVehicule !=null ? ElevatedButton.icon(
              onPressed: isDownloading ? null : (){
                downloadFile(voiture.fileVehicule.toString());
              }, // Désactiver le bouton en cours de téléchargement
              icon: Icon(LucideIcons.download),
              label: isDownloading
                  ? Text("Téléchargement... (${(progress * 100).toInt()}%)")
                  : Text("Télécharger les documents"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ):SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(TaxiAssChauffeurModel chauffeur) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("Informations du chauffeur", LucideIcons.user),
            _buildInfoRow("Nom", chauffeur.name??''),
            _buildInfoRow("Sexe", chauffeur.sexe??''),
            _buildInfoRow("Adresse", chauffeur.adresse??''),
            _buildInfoRow("Téléphone", chauffeur.telephone??''),
            _buildInfoRow("Expérience", "2+ ans"),
            _buildBadge("Statut", "En service", Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

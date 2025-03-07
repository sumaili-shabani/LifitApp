import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/ResponsivePadding.dart';
import 'package:lifti_app/Model/ChauffeurDashBoardModel.dart';

import 'package:lifti_app/Model/CourseModel.dart';

class InfoDashBoardPage extends StatefulWidget {
  const InfoDashBoardPage({super.key});
  @override
  State<InfoDashBoardPage> createState() => _InfoDashBoardPageState();
}

class _InfoDashBoardPageState extends State<InfoDashBoardPage> {
  List<CourseModel> notifications = [];
  List<ChauffeurDashBoardModel> dashInfo = [];
  String searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        'chauffeur_mobile_dashboard/${userId.toInt()}',
      );
      List<dynamic> dataDash = await CallApi.fetchListData(
        'chauffeur_mobile_dashboard/${userId.toInt()}',
      );

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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
          child: CircularProgressIndicator(),
        ) // Affiche un loader en attendant l'API
        : Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          "Moyenne",
          "Distance",
          "${dashInfo.isNotEmpty ? dashInfo.first.sumDistanceCourseEncours.toString() : 0} Km",
          Icons.directions_car,
          Colors.blue,
        ),
        _buildStatCard(
          "Wallet",
          "Revenus",
          "${dashInfo.isNotEmpty ? dashInfo.first.sommePaiementRecette.toString() : 0} CDF",
          Icons.wallet,
          Colors.green,
        ),
        _buildStatCard(
          "Nombre",
          "Recharge",
          "${dashInfo.isNotEmpty ? dashInfo.first.countRecharge.toString() : 0}",
          Icons.mobile_friendly_outlined,
          Colors.orange,
        ),
      ],
    );
  }

  // 🟢 1. Statistiques générales
  Widget _buildStatCard(
    String title1,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ResponsivePadding(
        percentage: 0.046,
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 5),
            Text(
              title1,
              maxLines: 2,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              maxLines: 2,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              maxLines: 4,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}

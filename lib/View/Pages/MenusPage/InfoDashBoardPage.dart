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
        ? Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallStatCard(
                "Moyenne",
                "Distance",
                "${dashInfo.isNotEmpty ? dashInfo.first.sumDistanceCourseEncours.toString() : 0} Km",
                Icons.directions_car,
                Colors.blueAccent,
              ),
              _buildSmallStatCard(
                "Total Mensuel ",
                "Wallet Revenus",
                "${dashInfo.isNotEmpty ? dashInfo.first.sommePaiementRecette.toString() : 0} CDF",
                Icons.wallet_giftcard,
                Colors.green,
              ),
              _buildSmallStatCard(
                "montant actuel",
                "Wallet solde",
                "${dashInfo.isNotEmpty ? dashInfo.first.sommePaiementCommission! : 0} CDF",
                Icons.account_balance_wallet,
                Colors.orange,
              ),
            ],
          ),
        );
  }

  

// ✅ Stat Card
 Widget _buildSmallStatCard(
    String title1,
    String title2,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 110, // 👈 taille réduite ici
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20), // 👈 icône plus petite
              SizedBox(height: 6),
              Text(
                title1,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Text(
                title2,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: theme.hintColor),
              ),
              SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

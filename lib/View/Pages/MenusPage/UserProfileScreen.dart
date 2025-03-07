import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Model/ChauffeurDashBoardModel.dart';
import 'package:lifti_app/Model/UserModel.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<List<UserModel>> futureUsers;
  List<ChauffeurDashBoardModel> dashInfo = [];

  UserModel? user;
  bool isLoading = true;

  Future<void> fetchUser() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    final response = await http.get(
      Uri.parse(
        '${CallApi.baseUrl.toString()}/user_mobile_info/${userId.toInt()}',
      ),
    );

    List<dynamic> dataDash = await CallApi.fetchListData(
      'chauffeur_mobile_dashboard/${userId.toInt()}',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      // print(data);
      setState(() {
        user = UserModel.fromMap(data);
        dashInfo =
            dataDash
                .map((item) => ChauffeurDashBoardModel.fromMap(item))
                .toList();
        isLoading = false;
      });
    } else {
      throw Exception('Erreur de chargement des données');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    "${CallApi.fileUrl}/images/${user!.avatar}",
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "${user!.name}",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Chauffeur Taxi - avec +2 ans d'expérience",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: Icon(Icons.car_crash, color: theme.primaryColor),
                    title: Text("Moy. Distance mensuel en cours"),
                    trailing: Text(
                      "${dashInfo.isNotEmpty ? dashInfo.first.sumDistanceCourseEncours.toString() : 0} Km",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: Icon(Icons.bar_chart, color: theme.primaryColor),
                    title: Text("Total de Recharge mensuel"),
                    trailing: Text(
                      "${dashInfo.isNotEmpty ? dashInfo.first.sommeRecharge.toString() : 0} CDF",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: Icon(Icons.wallet, color: theme.primaryColor),
                    title: Text("Total Retrait de paiement mensuel"),
                    trailing: Text(
                      "${dashInfo.isNotEmpty ? dashInfo.first.sommePaiement.toString() : 0} CDF",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    leading: Icon(Icons.star, color: Colors.amber),
                    title: Text("Note moyenne"),
                    trailing: Text(
                      "4.8 ⭐",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.phone, color: Colors.green),
                    title: Text("Téléphone"),
                    trailing: Text(
                      "${user!.telephone}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.email, color: Colors.red),
                    title: Text("Email"),
                    trailing: Text(
                      "${user!.email}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.male, color: Colors.blue),
                    title: Text("Sexe"),
                    trailing: Text(
                      "${user!.sexe}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.home, color: Colors.purple),
                    title: Text("Adresse Domicile"),
                    trailing: Text(
                      "${user!.adresse}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: Icon(Icons.payment, color: Colors.orange),
                    title: Text("Préférences de paiement"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${user!.designation},",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${user!.nomBanque}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

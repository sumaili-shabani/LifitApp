import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Model/ConducteurModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/AddChauffeur.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/ChauffeurPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/DriverInOrder.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Ambassadeur/Pages/MesChauffeur.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/InformationMenu.dart';

class MenuChauffeurPage extends StatefulWidget {
  const MenuChauffeurPage({super.key});

  @override
  State<MenuChauffeurPage> createState() => _MenuChauffeurPageState();
}

class _MenuChauffeurPageState extends State<MenuChauffeurPage> {
  late List<ConducteurModel> chauffeurlist = [];
  late List<ConducteurModel> filteredList = [];
  TextEditingController searchController = TextEditingController();
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
      'list_chauffeur_ambassadeur/${userId.toInt()}',
    );
    // print(dataDash);
    setState(() {
      idRole = roleId!;
      chauffeurlist =
          dataDash.map((item) => ConducteurModel.fromMap(item)).toList();
      filteredList = chauffeurlist;
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text("Chauffeurs", style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              onPressed: () async {
                bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Addchauffeur()),
                );

                if (result == true) {
                  // Rafraîchir la liste des chauffeurs ici
                  fetchUser();
                }
              },
              icon: Icon(Icons.add, color: Colors.white),
              tooltip: "Ajouter un chauffeur",
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

            IconButton(
              icon: Icon(Icons.newspaper_outlined),
              tooltip: "Voir plus d'informations",
              color: Colors.white,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(AnimatedPageRoute(page: InformationMenuScreem()));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 10),
            ButtonsTabBar(
              backgroundColor: ConfigurationApp.successColor,
              unselectedBackgroundColor: Colors.grey[300],
              unselectedLabelStyle: TextStyle(color: Colors.black),
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(text: "Mes chauffeurs", icon: Icon(Icons.group, size: 17)),
                Tab(
                  text: "Liste des chauffeurs",
                  icon: Icon(Icons.line_style, size: 17),
                ),
                Tab(
                  text: "Performance de chauffeur",
                  icon: Icon(Icons.pie_chart, size: 17),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MesChauffeur(),
                  ChauffeurAmbassadeurPage(),
                  DriveInorderPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

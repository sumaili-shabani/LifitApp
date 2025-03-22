import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';

class CategoryVehiculeScreen extends StatefulWidget {
  final List<dynamic> typeCourses;
  final Map<String, dynamic> trajectoire;
  final Map<String, dynamic> datainfotarification;
  final int refTypeCourse;
  final Function(Map<String, dynamic>) onCategorySelected; // Callback function
  const CategoryVehiculeScreen({
    super.key,
    required this.typeCourses,
    required this.trajectoire,
    required this.refTypeCourse,
    required this.datainfotarification,
    required this.onCategorySelected,
  });

  @override
  State<CategoryVehiculeScreen> createState() => _CategoryVehiculeScreenState();
}

class _CategoryVehiculeScreenState extends State<CategoryVehiculeScreen> {
  List<dynamic> categories = [
    {
      "id": 5,
      "refVehicule": 5,
      "nomCategorieVehicule": "Voiture normale",
      "imageCategorieVehicule": "1741641043.png",
      "nomMarque": "Toyota TX",
    },
    {
      "id": 7,
      "refVehicule": 7,
      "nomCategorieVehicule": "SUV de Luxe",
      "imageCategorieVehicule": "1741641043.png",
      "nomMarque": "Range Rover",
    },
  ];
  List<dynamic> filteredCategories = [];
  bool showSearchBar = false;
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> catVehicule = await CallApi.fetchListData(
        'fetch_category_vehicule_by_tye_course/${widget.refTypeCourse}',
      );

      // print(catVehicule);

      setState(() {
        categories = catVehicule;
        filteredCategories = catVehicule;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCategories = categories;
      });
    } else {
      setState(() {
        filteredCategories =
            categories
                .where(
                  (category) => category['nomCategorieVehicule']!
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 75% de l'écran
      padding: EdgeInsets.all(12),
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
          SizedBox(height: 5),
          // Slogan motivant
          messageInfo(),
          SizedBox(height: 5),

          // Icône pour afficher/cacher la barre de recherche
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Catégories disponibles",
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
                  hintText: "Rechercher une catégorie...",
                  fillColor: theme.hoverColor,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: filterSearchResults,
              ),
            ),

          // Liste des catégories en mode Grid
          isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Affiche un loader en attendant l'API
              : Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigator.pop(
                        //   context,
                        // ); // Fermer le BottomSheet après sélection

                        widget.onCategorySelected(
                          category,
                        ); // Appel de la fonction callback

                        // print("Sélectionné : $category");
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.network(
                                  "${CallApi.fileUrl}/taxi/${category['imageCategorieVehicule']}",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(
                                    category["nomCategorieVehicule"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    category["nomMarque"],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
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

  Widget messageInfo() {
    final theme = Theme.of(context);
    return Card(
      elevation: 6, // Ombre pour un effet pro
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor, // Fond blanc pour un look épuré
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Row(
          children: [
            // Icône sur le côté gauche
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1), // Léger fond coloré
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_rounded, // Icône voiture
                size: 28,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(width: 12), // Espacement entre l'icône et le texte
            // Texte principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choisissez une catégorie et partez en toute sérénité ! 🚗 ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Profitez d’un service rapide et sécurisé adapté à vos besoins.",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.check_circle, color: ConfigurationApp.successColor),
          ],
        ),
      ),
    );
  }
}

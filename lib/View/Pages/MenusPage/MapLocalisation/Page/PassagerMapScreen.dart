import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PassagerMapScreen extends StatefulWidget {
  const PassagerMapScreen({super.key});

  @override
  State<PassagerMapScreen> createState() => _PassagerMapScreenState();
}

class _PassagerMapScreenState extends State<PassagerMapScreen> {

  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = Set.from([]);
  List<dynamic> jsonPlaces = [
    {
      "id": "1-698060",
      "name": "StadeAfia",
      "latitude": -1.67994,
      "longitude": 29.22719,
      "description": "Goma Q.Les volcans, C.Goma",
    },
    {
      "id": "2-873719",
      "name": "passerelle Instigo/Goma",
      "latitude": -1.67883,
      "longitude": 29.22892,
      "description": "Goma Q.Les volcans, C.Goma",
    },
    {
      "id": "3-401992",
      "name": "DIVISION PROVINCIALE DU BUDGET NORD KIVU",
      "latitude": -1.68378,
      "longitude": 29.23273,
      "description": "Goma Q.Les volcans, C.Goma",
    },
    {
      "id": "4-890755",
      "name": "ADELARD",
      "latitude": -1.68416,
      "longitude": 29.2324,
      "description": "Goma Q.Les volcans, C.Goma",
    },
    // Ajoutez plus de lieux ici...
  ];

  List<dynamic> filteredPlaces = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPlaces = jsonPlaces;
    _createCircleAroundLocation(-1.67994, 29.22719);
  }

  void _createCircleAroundLocation(double latitude, double longitude) {
    setState(() {
      _circles.add(
        Circle(
          circleId: CircleId('1kmCircle'),
          center: LatLng(latitude, longitude),
          radius: 1000, // Rayon de 1 km (1000 mètres)
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 3,
        ),
      );
    });
  }

  void _filterPlaces(String query) {
    setState(() {
      filteredPlaces =
          jsonPlaces
              .where(
                (place) =>
                    place['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

   // Nouvelle fonction showTaxiBottomSheet avec les nouveaux paramètres
  void showTaxiBottomSheet(
    BuildContext context,
    String placeName,
    String departure,
    String arrival,
    String distance,
    String time,
    String price,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Barre de drag noire au centre
                  Container(
                    width: 50,
                    height: 5,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Titre du BottomSheet
                  Text(
                    "Commande de Taxi",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Informations du chauffeur
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          "assets/images/avatar_chauffeur.png",
                        ),
                      ),
                      title: Text(
                        "Nom du Chauffeur",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Modèle: Toyota Corolla | Plaque: 123ABC"),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Affichage des images des taxis (défilement horizontal)
                  Container(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var i = 1; i <= 5; i++)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage("assets/images/$i.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Informations de départ et arrivée
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.location_on, color: Colors.red),
                      title: Text("Départ: $departure"),
                      subtitle: Text("Arrivée: $arrival"),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Affichage de la distance, du temps et du prix dans une rangée horizontale
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard("Distance", distance),
                      _buildInfoCard("Temps", time),
                      _buildInfoCard("Prix", price),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Bouton de commande de taxi
                  ElevatedButton(
                    onPressed: () {
                      // Logique pour commander le taxi ici
                      print("Commande de taxi pour $placeName");
                    },
                    child: Text(
                      "Commander un Taxi",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      iconColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  //pour les taxi
  // Liste des types de courses
  List<String> courseTypes = ['Standard', 'VIP', 'Economy', 'Luxury'];
  String selectedCourseType = 'Standard';
  TextEditingController searchTaxiController = TextEditingController();

  // Exemple de données de taxis
  List<Map<String, dynamic>> taxis = [
    {
      'name': 'Course VIP',
      'image': '1.png', // URL de l'image
      'price': '5000 CDF',
      'category': 'VIP',
      'distance': '5 km',
      'estimatedTime': '15 mins',
    },
    {
      'name': 'Course Standard',
      'image': '2.png', // URL de l'image
      'price': '3000 CDF',
      'category': 'Standard',
      'distance': '3 km',
      'estimatedTime': '10 mins',
    },
    {
      'name': 'Course Confort',
      'image': '3.png', // URL de l'image
      'price': '3000 CDF',
      'category': 'Standard',
      'distance': '3 km',
      'estimatedTime': '10 mins',
    },
    {
      'name': 'Course Normal',
      'image': '4.png', // URL de l'image
      'price': '3000 CDF',
      'category': 'Standard',
      'distance': '3 km',
      'estimatedTime': '10 mins',
    },
    // Ajoute plus de taxis ici...
  ];

  // Filtrer les taxis par catégorie
  void _filterTaxis(String query) {
    setState(() {
      taxis =
          taxis.where((taxi) {
            return taxi['category'].toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte du Passager'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(onPressed: (){

            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    height:
                        MediaQuery.of(context).size.height *
                        0.75, // 75% de la hauteur de l'écran
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bande de recherche pour filtrer les types de courses
                        TextField(
                          controller: searchTaxiController,
                          onChanged: _filterTaxis,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: 'Rechercher par type de course...',
                            prefixIcon: Icon(Icons.search, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Affichage des taxis filtrés
                        Expanded(
                          child: ListView.builder(
                            itemCount: taxis.length,
                            itemBuilder: (context, index) {
                              var taxi = taxis[index];
                              return InkWell(
                                onTap: () {
                                  // Action à faire lorsque l'utilisateur clique sur un taxi (ex: réserver un taxi)
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(12),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        taxi['image'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      taxi['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 18,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              taxi['price'],
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.directions_car,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            Text(
                                              taxi['category'],
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            Text(
                                              taxi['distance'],
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 18,
                                              color: Colors.orange,
                                            ),
                                            Text(
                                              taxi['estimatedTime'],
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );

          }, icon: Icon(Icons.car_crash)),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    height:
                        MediaQuery.of(context).size.height *
                        0.75, // 75% de la hauteur de l'écran
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Text(
                          'Rechercher un lieu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 15),

                        // Champ de recherche
                        TextField(
                          controller: searchController,
                          onChanged: _filterPlaces,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            hintText: 'Entrez un lieu...',
                            prefixIcon: Icon(Icons.search, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Liste des lieux
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredPlaces.length,
                            itemBuilder: (context, index) {
                              var place = filteredPlaces[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(
                                    context,
                                  ); // Ferme le BottomSheet
                                  mapController.animateCamera(
                                    CameraUpdate.newLatLng(
                                      LatLng(
                                        place['latitude'],
                                        place['longitude'],
                                      ),
                                    ),
                                  );
                                  _markers.add(
                                    Marker(
                                      markerId: MarkerId(place['id']),
                                      position: LatLng(
                                        place['latitude'],
                                        place['longitude'],
                                      ),
                                      infoWindow: InfoWindow(
                                        title: place['name'],
                                        snippet: place['description'],
                                      ),
                                      onTap:
                                          () => {
                                            // Afficher le BottomSheet pour commander un taxi
                                            showTaxiBottomSheet(
                                              context,
                                              "Car Taxi vip",
                                              "Ndoyo",
                                              "Hôpital Heal Africa",
                                              "5 km", // Distance exemple
                                              "15 mins", // Temps estimé
                                              "5000 CDF", // Prix estimé
                                            ),
                                          },
                                    ),
                                  );
                                  setState(() {});
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(12),
                                    title: Text(
                                      place['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      place['description'],
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );

            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-1.67994, 29.22719),
          zoom: 15.0,
        ),
        markers: _markers,
        circles: _circles,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}
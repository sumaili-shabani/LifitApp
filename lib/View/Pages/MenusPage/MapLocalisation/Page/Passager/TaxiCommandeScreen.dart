import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'
    show rootBundle; // Ajout de l'import pour rootBundle
import 'dart:ui' as ui;
import 'dart:typed_data';

class TaxiCommandeScreen extends StatefulWidget {
  final Map<String, dynamic> categorieVehiculeInfo;
  const TaxiCommandeScreen({super.key, required this.categorieVehiculeInfo});

  @override
  State<TaxiCommandeScreen> createState() => _TaxiCommandeScreenState();
}

class _TaxiCommandeScreenState extends State<TaxiCommandeScreen> {
  // Variables simulant une API
  List<Map<String, dynamic>> chauffeurs = [
    {
      "id": 1,
      "name": "Jean Dupont",
      "phone": "+243900000000",
      "avatar": "assets/images/avatar_chauffeur.png",
      "lat": -1.6705,
      "lng": 29.2215,
      "imageVehicule": "assets/images/icon_car_120.png",
      "nomMarque": "Toyota",
      "numPlaque": "ABC-123",
      "anneeFabrication": 2018,
      "nombrePlace": 4,
      "coffre": "Grand",
      "sexeChauffeur": "Homme",
    },
    {
      "id": 2,
      "name": "Sefu fataki",
      "phone": "+243910000000",
      "avatar": "assets/images/avatar_chauffeur.png",
      "lat": -1.6710,
      "lng": 29.2220,
      "imageVehicule": "assets/images/vip__jaune.png",
      "nomMarque": "Honda",
      "numPlaque": "XYZ-456",
      "anneeFabrication": 2020,
      "nombrePlace": 4,
      "coffre": "Petit",
      "sexeChauffeur": "Homme",
    },
  ];

  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng passengerPosition = LatLng(-1.6708, 29.2218);

  //mes ajouts
  bool isLoading = false;
  bool isSearchingBottom = false;
  Set<Circle> circles = {};
  Set<Polyline> polylines =
      {}; // Pour afficher la route entre chauffeur et passager

  BitmapDescriptor? customPassagerIcon;
  BitmapDescriptor? customChauffeurIcon;
  BitmapDescriptor? customPlaceIcon;

  //initialisation des icones

  Future<BitmapDescriptor> getCustomIcon(
    String assetPath, {
    int width = 100,
  }) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> _loadIcons() async {
    customChauffeurIcon = await getCustomIcon("assets/images/taxi_icon.png");
    customPassagerIcon = await getCustomIcon("assets/images/person_icon.png");
    customPlaceIcon = await getCustomIcon("assets/images/ic_pick_48.png");
    setState(() {}); // Rafraîchir l'affichage après le chargement
  }

  // Fonction pour obtenir la position actuelle du chauffeur
  Future<void> _getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      passengerPosition = LatLng(
        position.latitude,
        position.longitude,
      ); // Met à jour la position du chauffeur
      markers.add(
        Marker(
          markerId: MarkerId('Passager'),
          position: passengerPosition,
          infoWindow: InfoWindow(title: 'Vous etes ici !!!'),
          icon:
              customPassagerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor
                    .hueRed, // Icône par défaut si le chargement échoue
              ),
        ),
      );

      //meettre à jour le circle
      circles.clear();
      polylines.clear();
      // Ajout du cercle de 1 km

      circles.add(
        Circle(
          circleId: CircleId("Vous êtes ici!"),
          center: passengerPosition,
          radius: 1000, // 1 km en mètres
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.2),
        ),
      );
    });
  }

  //changer ma position après 5 minutes
  int refConnected = 0;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifie si la localisation est activée
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    // Vérifie les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation ont été refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Les permissions de localisation sont définitivement refusées.',
      );
    }

    // Obtenir la position actuelle
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future getUserPosition() async {
    try {
      Position position = await _determinePosition();
      // print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
      return position;
    } catch (e) {
      print("Erreur: $e");
    }
  }

  Future changeMyPosition() async {
    Position position = await getUserPosition();
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    Map<String, dynamic> svData = {
      "id": userId.toInt(),
      "latUser": position.latitude,
      "lonUser": position.longitude,
    };

    await CallApi.postData("chauffeur_mobilechangePosition", svData);
  }

  @override
  void initState() {
    super.initState();

    //correction
    _loadIcons().then((_) {
      _loadMarkers();
    });

    changeMyPosition();
    // fetchNotifications();
    _getCurrentPosition();
  }

  void _loadMarkers() {
    setState(() {
      markers =
          chauffeurs.map((chauffeur) {
            return Marker(
              markerId: MarkerId(chauffeur["id"].toString()),
              position: LatLng(chauffeur["lat"], chauffeur["lng"]),
              infoWindow: InfoWindow(title: chauffeur["name"]),
              icon:
                  customChauffeurIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
              onTap: () => _showDriverProfile(chauffeur), // Déplace l'appel ici
            );
          }).toSet();
    });
  }

  List<Map<String, dynamic>> filteredChauffeurs = [];
  void filterSearch(String query) {
    setState(() {
      filteredChauffeurs =
          chauffeurs
              .where(
                (chauffeur) =>
                    chauffeur["nomMarque"].toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    chauffeur["name"].toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  void _showDriverProfile(Map<String, dynamic> chauffeur) {
    final theme = Theme.of(context);
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            height:
                MediaQuery.of(context).size.height *
                0.84, // 75% de la hauteur de l'écran
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre d'en-tête
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  color: theme.cardColor, // Couleur taxi
                  child: ListTile(
                    leading: Icon(Icons.local_taxi, size: 40),
                    title: Text(
                      "Commandez dès maintenant !",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Démarrez votre course en toute sécurité !",
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                    trailing: CircleAvatar(
                      radius: 15,
                      child: Center(
                        child: IconButton(
                          iconSize: 15,
                          icon: Icon(
                            Icons.close,
                            color: ConfigurationApp.whiteColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // les filtrage commence ici
                // 🟡 Carte d'invitation à commander
                SizedBox(height: 10),

                // 🔎 Barre de recherche
                TextField(
                  onChanged: filterSearch,
                  decoration: InputDecoration(
                    hintText: "Rechercher un taxi...",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 15),

                // 🚖 Liste horizontale des véhicules
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredChauffeurs.length,
                    itemBuilder: (context, index) {
                      final chauffeur = filteredChauffeurs[index];

                      return Container(
                        width:
                            MediaQuery.of(context).size.width *
                            0.7, // 70% de l'écran
                        margin: EdgeInsets.only(right: 16),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  chauffeur["imageVehicule"],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          chauffeur["nomMarque"],
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "N° de Plaque: ${chauffeur["numPlaque"]}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          "Nobre de siège: ${chauffeur["nombrePlace"]} Places",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          "Coffre: ${chauffeur["coffre"]} ",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: 8),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                icon: Icon(
                                                  Icons.phone,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  "Appeler",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed:
                                                    () => launchUrl(
                                                      Uri.parse(
                                                        "tel://${chauffeur["phone"]}",
                                                      ),
                                                    ),
                                              ),
                                            ),

                                            SizedBox(
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                icon: Icon(
                                                  Icons.car_crash,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  "Réserver",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () {

                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // card information chauffeur
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                      color: theme.cardColor, // Couleur taxi
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          child: Image.asset(
                                            chauffeur["avatar"],
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        title: Text(
                                          chauffeur["name"],
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Sexe: ${chauffeur['sexeChauffeur']}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: CircleAvatar(
                                          radius: 15,
                                          child: Center(
                                            child: IconButton(
                                              iconSize: 15,
                                              icon: Icon(
                                                Icons.close,
                                                color:
                                                    ConfigurationApp.whiteColor,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // fin card information
                                    
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

                // fin filtrage
                SizedBox(height: 10),
                // SingleChildScrollView(child: chauffeurInfoContainer(chauffeur)),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Erreur lors de l'affichage du profil: $e");
    }
  }

  Widget chauffeurInfoContainer(Map<String, dynamic> chauffeur) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(chauffeur["avatar"]),
                onBackgroundImageError: (_, __) => print("Image introuvable"),
              ),
              SizedBox(height: 10),
              Text(
                chauffeur["name"],
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Téléphone: ${chauffeur["phone"]}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 15),

              // Infos du véhicule
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (chauffeur["imageVehicule"] != null)
                    Image.asset(chauffeur["imageVehicule"], height: 80),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        Icons.directions_car,
                        "Marque: ${chauffeur["nomMarque"]}",
                      ),
                      _infoRow(
                        Icons.confirmation_number,
                        "Plaque: ${chauffeur["numPlaque"]}",
                      ),
                      _infoRow(
                        Icons.calendar_today,
                        "Année: ${chauffeur["anneeFabrication"]}",
                      ),
                      _infoRow(
                        Icons.event_seat,
                        "Places: ${chauffeur["nombrePlace"]}",
                      ),
                      _infoRow(
                        Icons.workspaces_filled,
                        "Coffre: ${chauffeur["coffre"]}",
                      ),
                      _infoRow(
                        Icons.person,
                        "Sexe: ${chauffeur["sexeChauffeur"]}",
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Bouton d'appel
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.phone, color: Colors.white),
                  label: Text("Appeler", style: TextStyle(color: Colors.white)),
                  onPressed:
                      () => launchUrl(Uri.parse("tel://${chauffeur["phone"]}")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text('Cat Véhicule', style: TextStyle(color: Colors.white)),
        actions: [
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
            icon: Icon(Icons.car_crash, color: Colors.white),
            tooltip: "Les véhicules en ligne selon votre catégorie",
            onPressed: () {
              // callBottomSheetSearch();
            },
          ),
          IconButton(
            icon: Icon(Icons.my_location_sharp, color: Colors.white),
            tooltip: "Charger ma position",
            onPressed: () {
              _getCurrentPosition();
              changeMyPosition();
              // fetchNotifications();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: passengerPosition,
              zoom: 14,
            ),
            markers: markers,
            polylines:
                polylines, // Affichage des polylines pour les itinéraires
            circles: circles, // Ajout des cercles
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                mapController = controller;
              });
            },
          ),
        ],
      ),
    );
  }
}

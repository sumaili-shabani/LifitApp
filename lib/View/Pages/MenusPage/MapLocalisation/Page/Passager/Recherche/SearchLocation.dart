import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/button.dart';
import 'package:lifti_app/Controller/NotificationService.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/CategoryVehicleScreen.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/CourseSelectionBottomSheet.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/TaxiCommandeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'
    show rootBundle; // Ajout de l'import pour rootBundle
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CourseEnCours.dart';

import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:lifti_app/View/Pages/MenusPage/NotificationBottom.dart';
// importation pour pusher

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key});

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  //declaration de variable
  bool isBottomSheetOpen = false;
  late GoogleMapController mapController;
  late LatLng passagerConnectedPosition; // Position actuelle du chauffeur
  Set<Marker> markers = {}; // Marqueurs de la carte
  Set<Polyline> polylines =
      {}; // Pour afficher la route entre chauffeur et passager

  // Liste des passagers déplacés dans différents coins de la ville
  List<dynamic> passagers = [];

  BitmapDescriptor? customPassagerIcon;
  BitmapDescriptor? customChauffeurIcon;
  BitmapDescriptor? customPlaceIcon;

  Map<String, dynamic> trajectoire = {};
  Map<String, dynamic> datainfotarification = {};
  Map<String, dynamic> datainfoCategoyVehicule = {};

  List<Map<String, dynamic>> categories = [
    {
      'label': 'Hôpital',
      'icon': Icons.local_hospital,
      'category_ids': [206], // Corrected ID for hospital
    },
    {
      'label': 'École',
      'icon': Icons.school,
      'category_ids': [156], // Correct ID for school
    },
    {
      'label': 'Police',
      'icon': Icons.local_police,
      'category_ids': [237], // Correct ID for police station
    },
    {
      'label': 'Pharmacie',
      'icon': Icons.local_pharmacy,
      'category_ids': [208], // Correct ID for pharmacy
    },
    {
      'label': 'Banque',
      'icon': Icons.account_balance,
      'category_ids': [419], // Correct ID for bank
    },
    {
      'label': 'Hôtel',
      'icon': Icons.hotel,
      'category_ids': [108], // Correct ID for hotel
    },
    {
      'label': 'Auberge',
      'icon': Icons.business_center,
      'category_ids': [107], // Correct ID for hostel
    },
    {
      'label': 'Station-service',
      'icon': Icons.local_gas_station,
      'category_ids': [596], // Correct ID for gas station
    },
    {
      'label': 'Cinéma',
      'icon': Icons.movie,
      'category_ids': [299], // Correct ID for cinema
    },
    {
      'label': 'Parc',
      'icon': Icons.park,
      'category_ids': [280], // Correct ID for park
    },
    {
      'label': 'Restaurant',
      'icon': Icons.restaurant,
      'category_ids': [560], // Correct ID for restaurant
    },
    {
      'label': 'Supermarché',
      'icon': Icons.store,
      'category_ids': [420], // Correct ID for supermarket
    },
    {
      'label': 'Zoo',
      'icon': Icons.pets,
      'category_ids': [310], // Correct ID for zoo
    },
    {
      'label': 'Église',
      'icon': Icons.church,
      'category_ids': [161], // Correct ID for church
    },
    {
      'label': 'Musée',
      'icon': Icons.museum,
      'category_ids': [130], // Correct ID for museum
    },
  ];

  Future<void> fetchPOIsByCategory(
    List<int> categoryIds,
    double lat,
    double lon, {
    int buffer = 2000, // Rayon en mètres (par défaut 1 km)
  }) async {
    String apikeyOpenrouteservice =
        CallApi.apikeyOpenrouteservice; // Remplacer par la clé API

    final body = jsonEncode({
      "request": "pois",
      "geometry": {
        "geojson": {
          "type": "Point",
          "coordinates": [lon, lat],
        },
        "buffer": buffer, // Rayon dynamique passé en paramètre
      },
      "filters": {"category_ids": categoryIds},
    });

    final response = await http.post(
      Uri.parse('https://api.openrouteservice.org/pois'),
      headers: {
        'Authorization': apikeyOpenrouteservice,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print("response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final features = data['features'] as List;

      setState(() {
        // markers.clear();
        for (var feature in features) {
          final coords = feature['geometry']['coordinates'];
          final properties = feature['properties'];
          final name =
              properties['osm_tags']['name'] ?? 'Lieu inconnu'; // Nom du lieu

          // Extraction du nom de la catégorie à partir de 'category_ids'
          String categoryName = '';
          if (properties['category_ids'] != null) {
            properties['category_ids'].forEach((key, value) {
              categoryName =
                  value['category_name']; // Extraire le nom de la catégorie
            });
          }

          Map<String, dynamic> place = {
            "name": name,
            "latitude": coords[1],
            "longitude": coords[0],
            "description": categoryName,
          };

          // Ajout du marqueur avec la catégorie
          markers.add(
            Marker(
              markerId: MarkerId(feature['id'].toString()),
              position: LatLng(coords[1], coords[0]),
              infoWindow: InfoWindow(
                title: name,
                snippet:
                    'Catégorie: $categoryName', // Afficher la catégorie dans l'info window
              ),
              icon:
                  customPlaceIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor
                        .hueRed, // Icône par défaut si le chargement échoue
                  ),
              onTap: () {
                _getRoutePlace(
                  passagerConnectedPosition,
                  LatLng(coords[1], coords[0]),
                  place, // Passer les informations de la places la fonction
                );
              },
            ),
          );
        }
      });
    } else {
      print('Erreur OpenRouteService: ${response.statusCode}');
    }
  }

  //debit de recherche
  /*
  *
  *=============================
  * Les scripts pour les places
  *=============================
  *
  */

  //pour les places
  List<Marker> placeMarkers = [];
  List<dynamic> placesData = [];
  List<dynamic> filteredPlaces = [];
  // JSON contenant les lieux populaires de Goma
  List<dynamic> placesJson = [
    {
      "id": 1,
      "name": "Place de l'Indépendance",
      "latitude": -1.6701,
      "longitude": 29.2215,
      'description': 'RDCongo',
    },
  ];

  void loadPlaces() {
    for (var place in placesJson) {
      final markerPlace = Marker(
        markerId: MarkerId(place['idPassager'].toString()),
        position: LatLng(place['latitude'], place['longitude']),
        infoWindow: InfoWindow(
          title: place['name'],
          snippet: 'Lat: ${place['latitude']}-${place['longitude']}',
        ),
        icon:
            customChauffeurIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor
                  .hueBlue, // Icône par défaut si le chargement échoue
            ), // Marqueur bleu pour le passager
        onTap: () {
          // _getRoute(
          //   passagerConnectedPosition,
          //   LatLng(place['latitude'], place['longitude']),
          //   place, // Passer les informations du passager à la fonction
          // );
        },
      );

      setState(() {
        placesData = placesJson;
        markers.add(markerPlace);
      });
    }
  }

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

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> clients = await CallApi.fetchListData(
        'chauffeur_mobile_map_demande_taxi/${userId.toInt()}',
      );
      List<dynamic> cities = await CallApi.fetchListData(
        'chauffeur_mobile_map_city',
      );

      List<dynamic> typeCourse = await CallApi.fetchListData(
        'fetch_tarification_to_mobile_app',
      );

      List<dynamic> typeClocation = await CallApi.fetchListData(
        'fetch_tarification_location_to_mobile_app',
      );

      // print(typeCourse);

      setState(() {
        passagers = clients;
        placesJson = cities;
        typeCourses = typeCourse;
        typeCourseLocation = typeClocation;

        isLoading = false;
      });

      // Ajouter les marqueurs pour chaque passager
      _addPassengerMarkers();
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
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

  /*
  *
  *==============================
  * Pour la recherche
  *==============================
  *
  */
  final TextEditingController searchController = TextEditingController();

  //pour la recherche

  List<Map<String, dynamic>> places = [];
  List<dynamic> listfilteredPlaces = []; // Liste filtrée pour la recherche
  bool isLoading = false;
  bool isSearchingBottom = false;
  Set<Circle> circles = {};

  void goToPlace(
    LatLng location,
    String placeName,
    Map<String, dynamic> place,
  ) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(location, 15));

    _getRoutePlace(
      passagerConnectedPosition,
      LatLng(place['latitude'], place['longitude']),
      place, // Passer les informations de la places la fonction
    );

    setState(() {
      circles.clear(); // Efface les anciens cercles
      markers.removeWhere((marker) => marker.markerId.value == 'placeName');
      markers.add(
        Marker(
          onTap: () {
            _getRoutePlace(
              passagerConnectedPosition,
              LatLng(place['latitude'], place['longitude']),
              place, // Passer les informations de la places la fonction
            );
          },
          markerId: MarkerId('placeName'),
          position: location,
          infoWindow: InfoWindow(title: placeName),
          icon:
              customPlaceIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor
                    .hueRed, // Icône par défaut si le chargement échoue
              ),
        ),
      );
    });
  }

  // Fonction pour rechercher dans la liste des lieux prédéfinis et, si nécessaire, dans l'API Nominatim
  bool searchEtat = false;
  Future<void> searchPlace2() async {
    String query = searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      searchEtat = true;
    });

    // Filtrage des lieux prédéfinis (placesJson)
    listfilteredPlaces =
        placesJson
            .where(
              (place) =>
                  place['name'].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    if (listfilteredPlaces.isEmpty) {
      // Si aucun lieu trouvé dans la liste, appeler l'API Nominatim
      try {
        const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
        final Uri url = Uri.parse(
          '$nominatimBaseUrl/search?q=$query&format=json&addressdetails=1&limit=5',
        );

        final response = await http.get(url);

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          setState(() {
            listfilteredPlaces =
                data.map((place) {
                  return {
                    "name": place["name"],
                    "latitude": double.parse(place["lat"]),
                    "longitude": double.parse(place["lon"]),
                    "description": place["display_name"],
                  };
                }).toList();
          });
        } else {
          print('Erreur: ${response.statusCode}');
        }
      } catch (error) {
        print('Erreur lors de la recherche: $error');
      }
    }

    if (searchController.text == '') {
      setState(() {
        searchEtat = false;
      });
    } else {
      setState(() {
        searchEtat = true;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  /*
  *
  *==============================
  * Fin Pour la recherche
  *==============================
  *
  */

  /*
  *
  *=========================================
  * Initialisation de la page
  *=========================================
  *
  */

  /*
  *
  *=========================================
  * Commande de taxi
  *=========================================
  *
  */
  // declaration de variable des courses
  int calculate = 1;
  double distance = 0;
  double duration = 0;
  double latDepart = 0;
  double lonDepart = 0;
  double latDestination = 0;
  double lonDestination = 0;
  String nameDepart = "";
  String nameDestination = "";
  String timeEst = "";
  String prixCourse = "";
  String author = "";
  String refUser = "";
  double montantCourse = 0;
  int refConduite = 0;
  int refTypeCourse = 0;
  int refPassager = 0;

  // Variables simulant une API
  List<dynamic> typeCourses = [
    {
      "id": 2,
      "idTarif": 2,
      "time": "15:42",
      "refTypeCourse": 1,
      "montant": 5000,
      "montant2": 10000,
      "montant3": 7000,
      "taxeAmbouteillage": 3000,
      "temps1Debut": "10:01",
      "temps1Fin": "19:00",
      "temps2Debut": "19:01",
      "temps2Fin": "06:59",
      "temps3Debut": "07:00",
      "temps3Fin": "10:00",
      "prix": 5000,
      "devise": "CDF",
      "unite": "Par Km",
      "remise": 0,
      "nomTypeCourse": "Course  VIP et VTC",
      "imageTypeCourse": "1741860047.png",
    },
  ];

  List<dynamic> typeCourseLocation = [
    {
      "id": 2,
      "idTarif": 2,
      "time": "15:42",
      "refTypeCourse": 1,
      "montant": 5000,
      "montant2": 10000,
      "montant3": 7000,
      "taxeAmbouteillage": 3000,
      "temps1Debut": "10:01",
      "temps1Fin": "19:00",
      "temps2Debut": "19:01",
      "temps2Fin": "06:59",
      "temps3Debut": "07:00",
      "temps3Fin": "10:00",
      "prix": 5000,
      "devise": "CDF",
      "unite": "Par Km",
      "remise": 0,
      "nomTypeCourse": "Course  VIP et VTC",
      "imageTypeCourse": "1741860047.png",
    },
  ];

  List<Map<String, dynamic>> tarifications = [
    {
      "id": 1,
      "category": "Économique",
      "image": "assets/images/4.png",
      "price": 1500,
    },
    {
      "id": 2,
      "category": "Confort",
      "image": "assets/images/5.png",
      "price": 3000,
    },
    {
      "id": 3,
      "category": "Luxueux",
      "image": "assets/images/6.png",
      "price": 6000,
    },
  ];

  List<Map<String, dynamic>> vehicules = [
    {
      "id": 1,
      "name": "Toyota Prius",
      "image": "assets/images/hiace.png",
      "plate": "AA-123-BB",
      "driver": "Jean Dupont",
      "phone": "+243900000000",
    },
    {
      "id": 2,
      "name": "BMW Série 3",
      "image": "assets/images/car.png",
      "plate": "CC-456-DD",
      "driver": "Paul Kagame",
      "phone": "+243910000000",
    },
  ];

  void showCourseSelectionBottomSheet(
    BuildContext context,
    List<dynamic> typeCourses,
    List<dynamic> typeCourseLocation,
    Map<String, dynamic> trajectoire,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => CourseSelectionBottomSheet(
            typeCourses: typeCourses, // Liste des types de courses
            typeCourseLocation: typeCourseLocation,
            trajectoire: trajectoire,
            onCourseSelected: (
              Map<String, dynamic> selectedCourse,
              bool isLocation,
            ) {
              Map<String, dynamic> datainfotarif = {
                'refTypeCourse': selectedCourse['refTypeCourse'],
                'prix': selectedCourse['prix'],
                'taxeAmbouteillage': selectedCourse['taxeAmbouteillage'],
                'devise': selectedCourse['devise'],
                'unite': selectedCourse['unite'],
                'remise': selectedCourse['remise'],
                'durationPlus': selectedCourse['durationPlus'],
              };

              // Gérer la sélection ici (ex: mise à jour de l'état)
              // print("isLocation: $isLocation");
              setState(() {
                datainfotarification = datainfotarif;
              });
              int idTypeCourse = selectedCourse['refTypeCourse'];
              showCategoryVehiculeBottomSheet(
                context,
                typeCourses,
                trajectoire,
                datainfotarification,
                idTypeCourse,
                isLocation,
              );

              // print("Course sélectionnée : $datainfotarification");
              // print("trajectoire: $trajectoire");
            },
          ),
    );
  }

  // voir la liste de categorie de véhicule
  void showCategoryVehiculeBottomSheet(
    BuildContext context,
    List<dynamic> typeCourses,
    Map<String, dynamic> trajectoire,
    Map<String, dynamic> datainfotarification,
    int refTypeCourse,
    bool isLocation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => CategoryVehiculeScreen(
            typeCourses: typeCourses,
            trajectoire: trajectoire,
            refTypeCourse: refTypeCourse,
            datainfotarification: datainfotarification,
            onCategorySelected: (Map<String, dynamic> selectedCategory) {
              Map<String, dynamic> datainfoCategoy = {
                'refCategorie': selectedCategory['refCategorie'],
                'nomCategorieVehicule':
                    selectedCategory['nomCategorieVehicule'],
                'imageCategorieVehicule':
                    selectedCategory['imageCategorieVehicule'],
                'nomMarque': selectedCategory['nomMarque'],
              };
              setState(() {
                datainfoCategoyVehicule = datainfoCategoy;
              });
              int refCategorie = selectedCategory['refCategorie'];
              Navigator.of(context).push(
                AnimatedPageRoute(
                  page: TaxiCommandeScreen(
                    typeCourses: typeCourses,
                    trajectoire: trajectoire,
                    datainfotarification: datainfotarification,
                    categorieVehiculeInfo: datainfoCategoyVehicule,
                    refCategorie: refCategorie,
                    isLocation: isLocation,
                  ),
                ),
              );

              // print("datainfoCategoyVehicule: $datainfoCategoyVehicule");
            },
          ),
    );
  }

  /*
  *
  *==========================
  * Tarification
  *==========================
  *
  */

  // Fonction pour obtenir la position actuelle du chauffeur
  Future<void> _getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      passagerConnectedPosition = LatLng(
        position.latitude,
        position.longitude,
      ); // Met à jour la position du chauffeur
      markers.add(
        Marker(
          markerId: MarkerId('Passager'),
          position: passagerConnectedPosition,
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
          circleId: CircleId("chauffeur-placeName"),
          center: passagerConnectedPosition,
          radius: 1000, // 1 km en mètres
          strokeWidth: 2,
          strokeColor: Colors.green,
          fillColor: Colors.green.withOpacity(0.2),
        ),
      );
    });
  }

  // Fonction pour ajouter les marqueurs des passagers sur la carte
  void _addPassengerMarkers() {
    for (var passager in passagers) {
      final marker = Marker(
        markerId: MarkerId(passager['code'].toString()),
        position: LatLng(passager['latitude'], passager['longitude']),
        infoWindow: InfoWindow(
          title: passager['name'],
          snippet: 'Tel: ${passager['telephone']}',
        ),
        icon:
            customPassagerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor
                  .hueGreen, // Icône par défaut si le chargement échoue
            ), // Marqueur vert pour le passager
        onTap: () {
          _getRoute(
            passagerConnectedPosition,
            LatLng(passager['latitude'], passager['longitude']),
            passager, // Passer les informations du passager à la fonction
          );
        },
      );

      setState(() {
        markers.add(marker);
      });
    }
  }
  // Fonction pour récupérer l'itinéraire entre chauffeur et passager via l'API Google Directions

  // Fonction pour obtenir et tracer l'itinéraire
  Future<void> _getRoute(
    LatLng start,
    LatLng end,
    Map<String, dynamic> passager,
  ) async {
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=${CallApi.apikeyOpenrouteservice}&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';
    print("Url: $url");
    try {
      // Appel à l'API OpenRouteService
      final response = await http.get(Uri.parse(url));

      // Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Vérifier si des routes ont été trouvées
        if (data['features'] != null && data['features'].isNotEmpty) {
          // Liste des coordonnées de la route
          List<LatLng> routeCoords = [];
          var coordinates = data['features'][0]['geometry']['coordinates'];

          // Extraire les coordonnées et les convertir en LatLng
          for (var coordinate in coordinates) {
            routeCoords.add(
              LatLng(
                coordinate[1], // Latitude
                coordinate[0], // Longitude
              ),
            );
          }

          // Calculer la distance et la durée du trajet
          double distance =
              data['features'][0]['properties']['segments'][0]['distance'] /
              1000; // en kilomètres
          double duration =
              data['features'][0]['properties']['segments'][0]['duration'] /
              60; // en minutes

          // Ajout de la polyline à la carte pour afficher l'itinéraire
          setState(() {
            polylines.clear();
            polylines.add(
              Polyline(
                polylineId: PolylineId('route'),
                visible: true,
                points: routeCoords,
                color: Colors.green,
                width: 5,
              ),
            );
          });

          // Afficher le BottomSheet avec les informations du passager
          // ignore: unnecessary_null_comparison
          if (distance != null || distance != "") {
            _showPassengerInfo(passager, distance, duration);
            setState(() {
              isSearchingBottom = false;
            });
          } else {}
        } else {
          print("Aucun itinéraire trouvé.");
        }
      } else {
        print("Erreur lors de l'appel de l'API: ${response.statusCode}");
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'itinéraire: $e');
    }
  }

  // Fonction pour obtenir et tracer l'itinéraire
  Future<void> _getRoutePlace(
    LatLng start,
    LatLng end,
    Map<String, dynamic> place,
  ) async {
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=${CallApi.apikeyOpenrouteservice}&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';
    print("Url: $url");
    try {
      // Appel à l'API OpenRouteService
      final response = await http.get(Uri.parse(url));

      // Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Vérifier si des routes ont été trouvées
        if (data['features'] != null && data['features'].isNotEmpty) {
          // Liste des coordonnées de la route
          List<LatLng> routeCoords = [];
          var coordinates = data['features'][0]['geometry']['coordinates'];

          // Extraire les coordonnées et les convertir en LatLng
          for (var coordinate in coordinates) {
            routeCoords.add(
              LatLng(
                coordinate[1], // Latitude
                coordinate[0], // Longitude
              ),
            );
          }

          // Calculer la distance et la durée du trajet
          double distance =
              data['features'][0]['properties']['segments'][0]['distance'] /
              1000; // en kilomètres
          double durationEstimation =
              data['features'][0]['properties']['segments'][0]['duration'] /
              60; // en minutes

          double duration = durationEstimation;

          // Ajout de la polyline à la carte pour afficher l'itinéraire
          setState(() {
            polylines.clear();
            polylines.add(
              Polyline(
                polylineId: PolylineId('route'),
                visible: true,
                points: routeCoords,
                color: Colors.green,
                width: 5,
              ),
            );

            distance = distance;
            duration = duration;
          });

          // Afficher le BottomSheet avec les informations du passager
          // ignore: unnecessary_null_comparison
          if (distance != null || distance != "") {
            setState(() {
              searchEtat = false;
            });
            _showPlaceInfo(place, distance, duration);
          } else {}
        } else {
          print("Aucun itinéraire trouvé.");
        }
      } else {
        print("Erreur lors de l'appel de l'API: ${response.statusCode}");
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'itinéraire: $e');
    }
  }

  void _showPassengerInfo(
    Map<String, dynamic> passager,
    double distance,
    double duration,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Informations du passager",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          isBottomSheetOpen = false;
                        });
                      },
                    ),
                  ],
                ),
                Divider(color: Colors.grey[400]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue),
                        SizedBox(width: 5),
                        Text("Nom: ${passager["name"]}"),
                      ],
                    ),
                    Divider(color: Colors.grey[400]),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.orange),
                        SizedBox(width: 5),
                        Text("Téléphone: ${passager["telephone"]}"),
                      ],
                    ),
                    Divider(color: Colors.grey[400]),
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: Colors.red),
                        SizedBox(width: 5),
                        Text("Distance: ${distance.toStringAsFixed(2)} km"),
                      ],
                    ),
                    Divider(color: Colors.grey[400]),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.purple),
                        SizedBox(width: 5),
                        Text(
                          "Temps estimé: ${duration.toStringAsFixed(2)} min",
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlaceInfo(
    Map<String, dynamic> place,
    double distance,
    double duration,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.map, size: 18),
                              SizedBox(width: 3),

                              Text(
                                "Informations du lieu",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: ConfigurationApp.dangerColor,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                isBottomSheetOpen = false;
                              });
                            },
                          ),
                        ],
                      ),

                      Divider(color: Colors.grey[400]),

                      // Contenu
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            icon: Icons.map,
                            iconColor: Colors.blue,
                            label: "Adresse",
                            value: place["name"],
                            maxWidth: constraints.maxWidth,
                          ),
                          Divider(color: Colors.grey[400]),

                          _infoRow(
                            icon: Icons.info_outline_rounded,
                            iconColor: ConfigurationApp.warningColor,
                            label: "Description",
                            value: place["description"],
                            maxWidth: constraints.maxWidth,
                          ),
                          Divider(color: Colors.grey[400]),

                          _infoRow(
                            icon: Icons.pin_drop_outlined,
                            iconColor: ConfigurationApp.dangerColor,
                            label: "Lat-Lon",
                            value:
                                "${place['latitude'].toStringAsFixed(4)} - ${place['longitude'].toStringAsFixed(4)}",
                            maxWidth: constraints.maxWidth,
                          ),
                          Divider(color: Colors.grey[400]),

                          _infoRow(
                            icon: Icons.directions_car,
                            iconColor: ConfigurationApp.dangerColor,
                            label: "Distance",
                            value: "${distance.toStringAsFixed(2)} km",
                            maxWidth: constraints.maxWidth,
                          ),
                          Divider(color: Colors.grey[400]),

                          _infoRow(
                            icon: Icons.timer,
                            iconColor: Colors.purple,
                            label: "Temps estimé",
                            value: "${duration.toStringAsFixed(2)} min",
                            maxWidth: constraints.maxWidth,
                          ),

                          SizedBox(height: 20),
                          Divider(color: Colors.grey[400]),

                          // Bouton de commande
                          Align(
                            alignment: Alignment.center,
                            child: Button(
                              icon: Icons.local_taxi,
                              label: "Commander une course",
                              press: () {
                                Map<String, dynamic> myTrajectoire = {
                                  'distance': distance.toStringAsFixed(2),
                                  'durationMormale': duration.toStringAsFixed(
                                    2,
                                  ),
                                  'duration': duration.toStringAsFixed(2),
                                  'placeLat': place['latitude'].toStringAsFixed(
                                    7,
                                  ),
                                  'placeLon': place['longitude']
                                      .toStringAsFixed(7),
                                  'placeName': place["name"].toString(),
                                  'placeDescription':
                                      place["description"].toString(),
                                };

                                setState(() {
                                  trajectoire = myTrajectoire;
                                });

                                showCourseSelectionBottomSheet(
                                  context,
                                  typeCourses,
                                  typeCourseLocation,
                                  trajectoire,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required double maxWidth,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  *
  *=============================
  * Les scripts pour les places
  *=============================
  *
  */

  /*
  *
  *=========================================
  * Fin Commande de taxi
  *=========================================
  *
  */

  int userId = 0;
  //voir l'id de la personne connecté
  getIdentifiant() async {
    int? idConnected = await CallApi.getUserId();
    setState(() {
      userId = idConnected!;
    });
  }

  /*
  *
  *==========================
  *utilisation de push
  *==========================
  */
  // Dans votre StatefulWidget
  /*
  PusherChannelsFlutter? _pusher;
  int? currentUserId;

  Future<void> _initPusher() async {
    try {
      currentUserId = await CallApi.getUserId();
      final token = await CallApi.getToken();

      _pusher = PusherChannelsFlutter.getInstance();

      await _pusher!.init(
        apiKey: CallApi.pusherAppKey,
        cluster: 'mt1',
        authEndpoint: '${CallApi.baseUrl}/broadcasting/auth',
        authParams: {
          'headers': {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        },
        onConnectionStateChange: (String currentState, String previousState) {
          debugPrint('État: $previousState -> $currentState');
          if (currentState == 'CONNECTED') {
            debugPrint('✅ Connexion établie');
          }
        },
        onError: (String message, int? code, dynamic error) {
          debugPrint('❌ Erreur: $message (Code: $code)');
          Future.delayed(const Duration(seconds: 3), _initPusher);
        },
      );

      // Connexion simple
      await _pusher!.connect();

      final channelName = 'private-commande-taxi.$currentUserId';
      await _pusher!.subscribe(
        channelName: channelName,
        onEvent: (PusherEvent event) {
          if (event.eventName == 'chauffeur.response') {
            debugPrint('📩 Données reçues: ${event.data}');
            _handleDriverResponse(event);
          }
        },
      );
    } catch (e) {
      debugPrint('⚠️ Erreur initialisation: $e');
      Future.delayed(const Duration(seconds: 5), _initPusher);
    }
  }

  void _handleDriverResponse(PusherEvent event) {
    try {
      final data = jsonDecode(event.data ?? '{}');
      if (data['statut'] == '3') {
        NotificationService.acceptingRideSaundNotification();
        NotificationService.showRideAcceptedNotification(
          rideId: data['ride_id'].toString(),
          driverName: data['driver_name'] ?? 'Chauffeur',
          carDetails: data['car_details'] ?? 'Véhicule',
        );

        if (mounted) {
          Navigator.pushNamed(
            context,
            '/suivi-course',
            arguments: {
              'rideId': data['ride_id'],
              'driver': data['driver_name'],
            },
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur traitement: $e');
    }
  }
  */

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) _initPusher();
    // });

    changeMyPosition();
    fetchNotifications();

    passagerConnectedPosition = LatLng(
      -1.6708,
      29.2218,
    ); // Position par défaut du chauffeur (ex: Goma)
    _getCurrentPosition(); // Récupère la position actuelle du chauffeur

    //ajout des places
    // loadPlaces();

    getIdentifiant();

    _loadIcons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text(
          'Planifier votre course',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:
          // ignore: unnecessary_null_comparison
          passagerConnectedPosition == null
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // ✅ 1. CARTE EN ARRIÈRE-PLAN
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          passagerConnectedPosition, // Position initiale de la caméra (chauffeur)
                      zoom: 14,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    markers:
                        markers, // Affichage des marqueurs (chauffeur et passagers)
                    polylines:
                        polylines, // Affichage des polylines pour les itinéraires
                    circles: circles, // Ajout des cercles

                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),

                  // ✅ 2. BARRE DE RECHERCHE + SUGGESTIONS (en haut)
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  print("clic recherche");
                                  searchPlace2();
                                },
                                icon: Icon(Icons.search, color: Colors.white),
                                iconSize: 24.0,
                                splashRadius: 24.0,
                                padding: EdgeInsets.all(8),
                                constraints: BoxConstraints(),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    ConfigurationApp.successColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Où allez-vous?',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.grey,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.calendar_month,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  // searchPlace2();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => SizedBox(width: 4),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              return ActionChip(
                                avatar: Icon(cat['icon'], size: 20),
                                label: Text(cat['label']),
                                onPressed: () {
                                  fetchPOIsByCategory(
                                    List<int>.from(cat['category_ids']),
                                    passagerConnectedPosition.latitude,
                                    passagerConnectedPosition.longitude,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 5),

                        if (searchEtat)
                          Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Résultats de recherche (liste verticale)
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child:
                                        isLoading
                                            ? Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                            : listfilteredPlaces.isEmpty
                                            ? Center(
                                              child: Text(
                                                "Aucun résultat trouvé",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            )
                                            : ListView.builder(
                                              itemCount:
                                                  listfilteredPlaces.length,
                                              itemBuilder: (context, index) {
                                                var place =
                                                    listfilteredPlaces[index];
                                                return Card(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  elevation: 3,
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.location_on,
                                                      color: Colors.redAccent,
                                                    ),
                                                    title: Text(
                                                      place['name'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      place['description'],
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    trailing: Icon(
                                                      Icons.chevron_right,
                                                      size: 20,
                                                      color: Colors.grey,
                                                    ),
                                                    onTap: () {
                                                      goToPlace(
                                                        LatLng(
                                                          place['latitude'],
                                                          place['longitude'],
                                                        ),
                                                        place['name'],
                                                        place,
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Liste horizontale des lieux favoris ou suggérés
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Suggestions de lieux",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            searchEtat = false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // liste des lieux suggerés
                                SizedBox(
                                  height: 40,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    itemCount: placesJson.length,
                                    separatorBuilder:
                                        (_, __) => SizedBox(width: 4),
                                    itemBuilder: (context, index) {
                                      var place = placesJson[index];
                                      return ActionChip(
                                        avatar: Icon(
                                          Icons.location_on,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        label: Text(place['name']),
                                        onPressed: () {
                                          goToPlace(
                                            LatLng(
                                              place['latitude'],
                                              place['longitude'],
                                            ),
                                            place['name'],
                                            place,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                // fin liste
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  //les bouttons
                  Positioned(
                    bottom: 100,
                    right: 7,
                    child: Column(
                      children: [
                        // 🔔 Bouton notification
                        FloatingActionButton(
                          heroTag: "btn1",
                          mini: true,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            // naviguer vers notifications
                            showNotificationBottomSheet(context);
                          },
                          child: Icon(Icons.notifications, color: Colors.black),
                        ),
                        SizedBox(height: 5),

                        // 📜 Bouton historique
                        FloatingActionButton(
                          heroTag: "btn2",
                          mini: true,
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            //naviguer vers l'historique
                            NotificationService.paddingRideSaundNotification();

                            // test de notification push
                            //  await NotificationService.showSimpleNotification(
                            //     title: 'Notification de test 🚀',
                            //     body: 'Félicitations, tout fonctionne !',
                            //   );

                            // NotificationService.showDriverNotification(
                            //   passengerName: 'Jean Dupont',
                            //   pickupAddress: '12 Rue de Paris',
                            //   rideId: '12345',
                            // );
                            // print("Notification envoyée !");
                            // fin test notification

                            showCourseBottomSheet(context);
                          },
                          child: Icon(Icons.history, color: Colors.black),
                        ),
                        SizedBox(height: 5),

                        // 📍 Bouton position actuelle
                        FloatingActionButton(
                          heroTag: "btn3",
                          mini: true,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            _getCurrentPosition();
                            changeMyPosition();
                            fetchNotifications();
                            mapController.animateCamera(
                              CameraUpdate.newLatLng(passagerConnectedPosition),
                            );
                          },
                          child: Icon(Icons.my_location, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  //fin boutton
                ],
              ),
    );
  }

  // Fonction pour afficher le BottomSheet
  void showCourseBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Plein écran
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.50, // 75% de l'écran
          width: MediaQuery.of(context).size.width * 1,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
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

                  SizedBox(height: 10),

                  //course passager en cours
                  PassagerCourseEnCourse(),

                  // fin qffichage course
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Fonction pour afficher le BottomSheet
  void showNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Plein écran
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return NotificationBottom();
      },
    );
  }
}

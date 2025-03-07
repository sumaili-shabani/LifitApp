import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart'
    show rootBundle; // Ajout de l'import pour rootBundle

import 'package:http/http.dart' as http;
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'dart:convert';

import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:lifti_app/Api/my_api.dart';

class MapScreemExercerci extends StatefulWidget {
  const MapScreemExercerci({super.key});

  @override
  State<MapScreemExercerci> createState() => _MapScreemExercerciState();
}

class _MapScreemExercerciState extends State<MapScreemExercerci> {
  static const String apikeyOpenrouteservice =
      "5b3ce3597851110001cf62484e660c3aa019470d8ac388d12b974480";
  bool isBottomSheetOpen = false;
  late GoogleMapController mapController;
  late LatLng chauffeurPosition; // Position actuelle du chauffeur
  Set<Marker> markers = {}; // Marqueurs de la carte
  Set<Polyline> polylines =
      {}; // Pour afficher la route entre chauffeur et passager

  // Liste des passagers déplacés dans différents coins de la ville
  List<dynamic> passagers = [];

  BitmapDescriptor? customPassagerIcon;
  BitmapDescriptor? customChauffeurIcon;
  BitmapDescriptor? customPlaceIcon;

  // Fonction pour obtenir la position actuelle du chauffeur
  Future<void> _getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      chauffeurPosition = LatLng(
        position.latitude,
        position.longitude,
      ); // Met à jour la position du chauffeur
      markers.add(
        Marker(
          markerId: MarkerId('chauffeur'),
          position: chauffeurPosition,
          infoWindow: InfoWindow(title: 'Chauffeur'),
          icon:
              customChauffeurIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor
                    .hueRed, // Icône par défaut si le chargement échoue
              ),
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
            chauffeurPosition,
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
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apikeyOpenrouteservice&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

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
                color: Colors.blue,
                width: 5,
              ),
            );
          });

          // Afficher le BottomSheet avec les informations du passager
          // ignore: unnecessary_null_comparison
          if (distance != null || distance != "") {
            _showPassengerInfo(passager, distance, duration);
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
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apikeyOpenrouteservice&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

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
                color: Colors.blue,
                width: 5,
              ),
            );
          });

          // Afficher le BottomSheet avec les informations du passager
          // ignore: unnecessary_null_comparison
          if (distance != null || distance != "") {
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
                Divider(),
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
                    Divider(),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.orange),
                        SizedBox(width: 5),
                        Text("Téléphone: ${passager["telephone"]}"),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: Colors.red),
                        SizedBox(width: 5),
                        Text("Distance: ${distance.toStringAsFixed(2)} km"),
                      ],
                    ),
                    Divider(),
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
                      "Informations du lieu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.map, color: Colors.blue),
                        SizedBox(width: 5),

                        SizedBox(
                          width: 300,
                          child: Text("Adresse: ${place["name"]}", maxLines: 4),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: ConfigurationApp.warningColor,
                        ),
                        SizedBox(width: 5),
                        SizedBox(
                          width: 300,
                          child: Text(
                            "Description: ${place["description"]}",
                            maxLines: 4,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.pin_drop_outlined,
                          color: ConfigurationApp.dangerColor,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Lat-Lon: ${place['latitude'].toStringAsFixed(4)} - ${place['longitude'].toStringAsFixed(4)} km",
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: ConfigurationApp.dangerColor,
                        ),
                        SizedBox(width: 5),
                        Text("Distance: ${distance.toStringAsFixed(2)} km"),
                      ],
                    ),

                    Divider(),
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
    {
      "id": 2,
      "name": "Hôpital Heal Africa",
      "latitude": -1.6750,
      "longitude": 29.2250,
      'description': 'RDCongo',
    },
    {
      "id": 3,
      "name": "Université de Goma",
      "latitude": -1.6780,
      "longitude": 29.2202,
      'description': 'RDCongo',
    },
    {
      "id": 4,
      "name": "Aéroport de Goma",
      "latitude": -1.6773,
      "longitude": 29.2425,
      'description': 'RDCongo',
    },
    {
      "id": 5,
      "name": "Ndoyo",
      "latitude": -1.6698,
      "longitude": 29.2312,
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
          //   chauffeurPosition,
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
    customPlaceIcon = await getCustomIcon("assets/images/center-pin.png");
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

      print(cities);

      setState(() {
        passagers = clients;
        placesJson = cities;
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

  @override
  void initState() {
    super.initState();

    changeMyPosition();
    fetchNotifications();

    chauffeurPosition = LatLng(
      -1.6708,
      29.2218,
    ); // Position par défaut du chauffeur (ex: Goma)
    _getCurrentPosition(); // Récupère la position actuelle du chauffeur

    //ajout des places
    // loadPlaces();

    _loadIcons();
  }

  //pour la recherche
  TextEditingController searchController = TextEditingController();
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

    setState(() {
      circles.clear(); // Efface les anciens cercles
      markers.add(
        Marker(
          onTap: () {
            _getRoutePlace(
              chauffeurPosition,
              LatLng(place['latitude'], place['longitude']),
              place, // Passer les informations de la places la fonction
            );
          },
          markerId: MarkerId(placeName),
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
      // Ajout du cercle de 1 km
      circles.add(
        Circle(
          circleId: CircleId(placeName),
          center: location,
          radius: 1000, // 1 km en mètres
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.2),
        ),
      );
    });
  }

  // Fonction pour rechercher dans la liste des lieux prédéfinis et, si nécessaire, dans l'API Nominatim
  Future<void> searchPlace2() async {
    String query = searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
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

    setState(() {
      isLoading = false;
    });
  }

  callBottomSheetSearch() {
    setState(() {
      isSearchingBottom = !isSearchingBottom;
    });
    // if (isSearchingBottom) {
    //   return showSearchBottomShhet(context);
    // }
    // else{
    //   return;
    // }
  }

  Widget showSearchBottomShhet(context) {
    final theme = Theme.of(context);
    return
    // BottomSheet pour la recherche
    DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          padding: EdgeInsets.all(16),
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

              // Barre de recherche
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        label: Text("Où voulez-vous partir?"),
                        hintText: "Entrez un lieu...",
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: theme.cardColor,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Bouton de recherche
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: searchPlace2,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConfigurationApp.successColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        child: Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Affichage des résultats
              Expanded(
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : listfilteredPlaces.isEmpty
                        ? Center(
                          child: Text(
                            "Aucun résultat trouvé",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          controller: scrollController,
                          itemCount: listfilteredPlaces.length,
                          itemBuilder: (context, index) {
                            var place = listfilteredPlaces[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.place, color: Colors.red),
                                title: Text(
                                  place['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("${place['description']}"),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  // print(
                                  //   "Lieu sélectionné: ${place['name']} (latitude: ${place['latitude']}, longitude: ${place['longitude']})",
                                  // );
                                  // Navigator.pop(context);

                                  goToPlace(
                                    LatLng(
                                      place['latitude'],
                                      place['longitude'],
                                    ),
                                    place['name'],
                                    place,
                                  );

                                  // Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
              ),

              SizedBox(height: 20),
              // liste horizontale
              // Liste horizontale des lieux
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: placesJson.length,
                  itemBuilder: (context, index) {
                    var place = placesJson[index];
                    return GestureDetector(
                      onTap: () {
                        goToPlace(
                          LatLng(place['latitude'], place['longitude']),
                          place['name'],
                          place,
                        );
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 100,
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,

                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.place, color: Colors.blue),
                                SizedBox(height: 5),
                                Text(
                                  place['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Fin de la liste horizontale des lieux
            ],
          ),
        );
      },
    );

    // Fin de la zone BottomShee
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.car_crash),
        title: Text('Lifti App - Chauffeur'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              callBottomSheetSearch();
            },
          ),
          IconButton(
            icon: Icon(Icons.my_location_sharp),
            onPressed: () {
              _getCurrentPosition();
              changeMyPosition();
              fetchNotifications();
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          //la carte ici
          SizedBox(
            height:
                double.infinity, // La carte prendra toute la hauteur de l'écran
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    chauffeurPosition, // Position initiale de la caméra (chauffeur)
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
            ),
          ),
          //fin integration map

          // Center(child: Text(passagers.toString())),

          // BottomSheet pour la recherche
          isSearchingBottom
              ? showSearchBottomShhet(context)
              : Column(children: []),
          // Fin de la zone BottomSheet
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';

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
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:lifti_app/View/Pages/MenusPage/CoursesEnCoursChauffeur.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/CarteSelectionPosition.dart';
import 'package:lifti_app/View/Pages/MenusPage/NotificationBottom.dart';

class MapScreemChauffeur extends StatefulWidget {
  const MapScreemChauffeur({super.key});

  @override
  State<MapScreemChauffeur> createState() => _MapScreemChauffeurState();
}

class _MapScreemChauffeurState extends State<MapScreemChauffeur> {
  static String apikeyOpenrouteservice = CallApi.apikeyOpenrouteservice;
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

      //meettre à jour le circle
      circles.clear();
      polylines.clear();
      // Ajout du cercle de 1 km

      circles.add(
        Circle(
          circleId: CircleId("chauffeur-placeName"),
          center: chauffeurPosition,
          radius: 1000, // 1 km en mètres
          strokeWidth: 2,
          strokeColor: Colors.green,
          fillColor: Colors.green.withOpacity(0.2),
        ),
      );
    });
  }

  // Fonction pour récupérer l'itinéraire entre chauffeur et passager via l'API Google Directions

  _getMarkers() async {
    // Ajoute les markers des passagers
    for (var passager in passagers) {
      setState(() {
        circles.clear();
        filteredPlaces.clear();

        // markers.removeWhere(
        //   (marker) => marker.markerId.value == "demandeurPassager",
        // );
      });
      // print(passager);
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId("${passager['code']}"),
            position: LatLng(passager['latitude'], passager['longitude']),
            infoWindow: InfoWindow(title: passager['name']),
            icon:
                customPassagerIcon ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () async {
              // Dessiner la route ici avant de lancer l'animation
              // _getRoute(
              //   chauffeurPosition,
              //   LatLng(passager['latitude'], passager['longitude']),
              //   passager,
              // );

              LatLng passagerPosition = LatLng(
                passager['latitude'],
                passager['longitude'],
              );

              // 🔹 Obtenir la route et animer le chauffeur en suivant la route
              await _getRoute(chauffeurPosition, passagerPosition, passager);
            },
          ),
        );
      });
    }

    // Ajoute les markers des lieux prédéfinis de placesJson
    for (var place in listfilteredPlaces) {
      markers.add(
        Marker(
          markerId: MarkerId(place['id'].toString()),
          position: LatLng(place['latitude'], place['longitude']),
          infoWindow: InfoWindow(title: place['name']),
          icon:
              customPlaceIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () {
            goToPlace(
              LatLng(place['latitude'], place['longitude']),
              place['name'],
              place,
            );

            _getRoutePlace(
              chauffeurPosition,
              LatLng(place['latitude'], place['longitude']),
              place, // Passer les informations de la places la fonction
            );
          },
        ),
      );
    }

    // Ajoute le marker du chauffeur

    markers.add(
      Marker(
        markerId: MarkerId("chauffeur"),
        infoWindow: InfoWindow(title: "chauffeur"),
        position: chauffeurPosition!,
        icon:
            customChauffeurIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    setState(() {
      markers = markers;
    });

    return markers;
  }

  Future<List<LatLng>> _getRoute(
    LatLng start,
    LatLng end,
    Map<String, dynamic> passager,
  ) async {
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apikeyOpenrouteservice&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      // 🔹 Appel à l'API OpenRouteService
      final response = await http.get(Uri.parse(url));

      // 🔹 Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          List<LatLng> routeCoords = [];
          var coordinates = data['features'][0]['geometry']['coordinates'];

          // 🔹 Extraire les coordonnées et les convertir en LatLng
          for (var coordinate in coordinates) {
            routeCoords.add(LatLng(coordinate[1], coordinate[0]));
          }

          // 🔹 Calcul de la distance et de la durée
          double distance =
              data['features'][0]['properties']['segments'][0]['distance'] /
              1000;
          double duration =
              data['features'][0]['properties']['segments'][0]['duration'] / 60;

          // 🔹 Ajout de la polyline à la carte
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

          // 🔹 Affichage du BottomSheet avec les infos du passager
          _showPassengerInfo(passager, distance, duration, routeCoords);

          return routeCoords; // 🔥 Retourne la liste des coordonnées
        } else {
          print("Aucun itinéraire trouvé.");
        }
      } else {
        print("Erreur API: ${response.statusCode}");
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'itinéraire: $e');
    }

    return []; // 🔥 Retourne une liste vide en cas d'échec
  }

  // Fonction pour obtenir et tracer l'itinéraire
  Future<List<LatLng>> _getRoutePlace(
    LatLng start,
    LatLng end,
    Map<String, dynamic> place,
  ) async {
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apikeyOpenrouteservice&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    try {
      // 🔹 Appel à l'API OpenRouteService
      final response = await http.get(Uri.parse(url));

      // 🔹 Vérifier le statut de la réponse
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          List<LatLng> routeCoords = [];
          var coordinates = data['features'][0]['geometry']['coordinates'];

          // 🔹 Extraire les coordonnées et les convertir en LatLng
          for (var coordinate in coordinates) {
            routeCoords.add(LatLng(coordinate[1], coordinate[0]));
          }

          // 🔹 Calcul de la distance et de la durée
          double distance =
              data['features'][0]['properties']['segments'][0]['distance'] /
              1000;
          double duration =
              data['features'][0]['properties']['segments'][0]['duration'] / 60;

          // 🔹 Ajout de la polyline à la carte
          setState(() {
            polylines.clear();
            polylines.add(
              Polyline(
                polylineId: PolylineId('route_place'),
                visible: true,
                points: routeCoords,
                color: Colors.green, // Couleur différente pour distinguer
                width: 5,
              ),
            );
          });

          // 🔹 Affichage du BottomSheet avec les infos du lieu
          _showPlaceInfo(place, distance, duration);

          return routeCoords; // 🔥 Retourne la liste des coordonnées
        } else {
          print("Aucun itinéraire trouvé.");
        }
      } else {
        print("Erreur API: ${response.statusCode}");
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'itinéraire: $e');
    }

    return []; // 🔥 Retourne une liste vide en cas d'échec
  }

  Future reponseDemande(int id, int statut, int refPassager) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await CallApi.fetchData(
        "checkEtat_chauffeur_mobile_demande_taxi/${id.toInt()}/${statut.toInt()}/${refPassager.toInt()}",
      );

      final Map<String, dynamic> responseData = response;
      String message = responseData['data'] ?? "J'arrive!!!";
      showSnackBar(context, message, 'success');

      //appelle de la fonction demande
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      showSnackBar(context, e.toString(), 'danger');
    }
  }

  void _showPassengerInfo(
    Map<String, dynamic> passager,
    double distance,
    double duration,
    List<LatLng> routeCoords,
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
                    // Divider(),
                    // Row(
                    //   children: [
                    //     Icon(Icons.phone, color: Colors.orange),
                    //     SizedBox(width: 5),
                    //     Text("Téléphone: ${passager["telephone"]}"),
                    //   ],
                    // ),
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
                    Divider(),
                    Row(
                      children: [
                        Icon(
                          Icons.playlist_add_check_circle_outlined,
                          color: ConfigurationApp.successColor,
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);

                            if (routeCoords.isNotEmpty) {
                              animateChauffeur(
                                routeCoords,
                              ); // 🔥 Lancer l'animation du chauffeur avec rotation
                            }

                            // reponseDemande(
                            //   passager['id'],
                            //   passager['statut'],
                            //   passager['idPassager'],
                            // );
                          },
                          child: Text("Allez vers le passager"),
                        ),
                      ],
                    ),
                    Divider(),
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
        return SizedBox(
          child: Padding(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.map, color: Colors.blue),
                          SizedBox(width: 5),

                          SizedBox(
                            width: 300,
                            child: Text(
                              "Adresse: ${place["name"]}",
                              maxLines: 4,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey[400]),
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
                      Divider(color: Colors.grey[400]),
                      Row(
                        children: [
                          Icon(
                            Icons.pin_drop_outlined,
                            color: ConfigurationApp.dangerColor,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Lat-Lon: ${place['latitude'].toStringAsFixed(4)} - ${place['longitude'].toStringAsFixed(4)} ",
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey[400]),
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
    customChauffeurIcon = await getCustomIcon("assets/images/taxi_icon2.png");
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

      // print(cities);

      setState(() {
        passagers = clients;
        placesJson = cities;
        isLoading = false;
      });
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
      markers.removeWhere((m) => m.markerId.value == "placeName");

      markers.add(
        Marker(
          onTap: () {
            _getRoutePlace(
              chauffeurPosition,
              LatLng(place['latitude'], place['longitude']),
              place, // Passer les informations de la places la fonction
            );
          },
          markerId: MarkerId("placeName"),
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
          strokeColor: Colors.green,
          fillColor: Colors.green.withOpacity(0.2),
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
      setState(() {
        listfilteredPlaces.clear();
      });
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
  }

  //Étapes pour animer l'icône du chauffeur
  Marker? chauffeurMarker; // Marqueur du chauffeur

  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double deltaLon = (end.longitude - start.longitude) * pi / 180;

    double y = sin(deltaLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);
    double bearing = atan2(y, x) * 180 / pi;

    return (bearing + 360) %
        360; // Assure que l'angle est compris entre 0 et 360°
  }

  void animateChauffeur(List<LatLng> route) async {
    for (int i = 0; i < route.length - 1; i++) {
      LatLng current = route[i];
      LatLng next = route[i + 1];

      // 🔥 Calcul de l'angle entre deux points
      double angle = _calculateBearing(current, next);

      // 🔹 Mettre à jour la position et la rotation du chauffeur
      setState(() {
        chauffeurPosition = current;
        markers.removeWhere((m) => m.markerId.value == "chauffeur");
        markers.add(
          Marker(
            markerId: MarkerId("chauffeur"),
            infoWindow: InfoWindow(title: 'Chauffeur en deplacement'),
            position: current,
            icon:
                customChauffeurIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ), // Icône personnalisée de la voiture
            rotation: angle, // 🔥 Appliquer l'angle ici
            anchor: Offset(0.5, 0.5), // Ajuste l'ancrage de l'icône
          ),
        );
      });

      await Future.delayed(
        Duration(milliseconds: 1000),
      ); // Pause entre chaque déplacement
    }
  }

  /// Fonction pour interpoler entre deux valeurs
  double lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  /*
  *
  *===========================================
  * recherche automatique
  *===========================================
  */
  bool searchEtat = false;
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
                  chauffeurPosition,
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

  /*
  *
  *===========================================
  * Bloc archavage de demandeur de taxi
  *===========================================
  *
  */
  LatLng? hotspot; // Point central de forte demande
  LatLng? positionChauffeur; // Position actuelle du chauffeur
  double? distanceKm;
  double? estimatedTime;
  bool showHotspotCard = false;
  //bon maintenant là, je veux  l'archivage de cercle pour voir là où il y'a beaucoup de demainde
  LatLng findClusterHotspot(List<dynamic> passagers) {
    List<List<dynamic>> clusters = [];

    for (var p in passagers) {
      bool added = false;
      for (var cluster in clusters) {
        for (var q in cluster) {
          double dist = Geolocator.distanceBetween(
            p["latitude"],
            p["longitude"],
            q["latitude"],
            q["longitude"],
          );
          if (dist < 1000) {
            // Moins de 1 km
            cluster.add(p);
            added = true;
            break;
          }
        }
        if (added) break;
      }
      if (!added) {
        clusters.add([p]);
      }
    }

    // Trouver le plus grand groupe
    clusters.sort((a, b) => b.length.compareTo(a.length));
    var bestCluster = clusters.first;

    // Calculer le centroïde de ce groupe
    double avgLat =
        bestCluster.map((p) => p["latitude"]).reduce((a, b) => a + b) /
        bestCluster.length;
    double avgLng =
        bestCluster.map((p) => p["longitude"]).reduce((a, b) => a + b) /
        bestCluster.length;

    return LatLng(avgLat, avgLng);
  }

  void analyserPassagers() async {
    // print(chauffeurPosition);
    if (passagers.isEmpty || chauffeurPosition == LatLng(-1.6708, 29.2218))
      return;
    await _getMarkers();
    hotspot = findClusterHotspot(passagers);

    print("hotspot:$hotspot");

    circles = {
      Circle(
        circleId: CircleId('zone_hotspot'),
        center: hotspot!,
        radius: 1000,
        fillColor: Colors.orangeAccent.withOpacity(0.3),
        strokeColor: Colors.orangeAccent,
        strokeWidth: 2,
      ),
    };

    double distance = Geolocator.distanceBetween(
      chauffeurPosition.latitude,
      chauffeurPosition.longitude,
      hotspot!.latitude,
      hotspot!.longitude,
    );

    distanceKm = distance / 1000;
    estimatedTime = (distanceKm! / 40) * 60;

    setState(() {
      showHotspotCard = true;
    });
  }

  /*
  *
  *============================================================================================
  * vérification de la position si le chauffeurest dans la ville que l'application fonctionne
  *============================================================================================
  *
  */
  bool estDansKinshasa(LatLng position) {
    const kinshasaCenter = LatLng(-4.325, 15.3222);
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      kinshasaCenter.latitude,
      kinshasaCenter.longitude,
    );
    return distance <= 20000; // 20 km
  }

  void verifierPositionChauffeur() async {
    // Suppose que chauffeurPosition est déjà défini
    if (!estDansKinshasa(chauffeurPosition)) {
      // Affiche une boîte de dialogue ou un snack
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text("Hors de Kinshasa"),
              content: Text(
                "Vous êtes en dehors de Kinshasa. Veuillez choisir un lieu manuellement.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _selectLocationManually();
                  },
                  child: Text("Choisir sur carte"),
                ),
              ],
            ),
      );
    }
  }

  void _selectLocationManually() async {
    LatLng? positionSelectionnee = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarteSelectionPosition()),
    );

    if (positionSelectionnee != null) {
      setState(() {
        chauffeurPosition = positionSelectionnee;
      });

      print("positionSelectionnee: $positionSelectionnee");

      // 🔁 Envoi vers l'API
      await envoyerPositionServeur(positionSelectionnee);

      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId('chauffeur'),
            position: positionSelectionnee,
            infoWindow: InfoWindow(title: 'Chauffeur'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor
                  .hueGreen, // Icône par défaut si le chargement échoue
            ),
          ),
        );
      });
    }
  }

  Future<void> envoyerPositionServeur(LatLng pos) async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    Map<String, dynamic> svData = {
      "latUser": pos.latitude.toString(),
      "lonUser": pos.longitude.toString(),
      "id": userId.toString(),
    };
    await CallApi.postData("chauffeur_mobilechangePosition", svData);

    setState(() {
      markers.clear();
      circles.clear();
      polylines.clear();
      passagers.clear();
      showHotspotCard = false;
    });

    fetchNotifications();
  }

  LatLng centerGoma = LatLng(-1.6708, 29.2218);
  LatLng centerKinshasa = LatLng(-4.325, 15.3222);
  bool estDansZoneKinshasa(LatLng positionActuelle) {
    double distance = Geolocator.distanceBetween(
      positionActuelle.latitude,
      positionActuelle.longitude,
      centerGoma.latitude,
      centerGoma.longitude,
    );

    return distance <= 20000; // 20 km autour du centre
  }

  /*
  *
  *============================================================
  * Fin vérification de la position si 
  * le chauffeurest dans la ville que l'application fonctionne
  *============================================================
  *
  */

  bool isNotify = false;

  /*
  *
  *==========================================
  * Fin de la recherche automatique
  *==========================================
  */

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

    //chargement des icons
    _loadIcons();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text("Map-Chauffeur", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location_sharp, color: Colors.white),
            tooltip: "Voir ma position",
            onPressed: () {
              _getCurrentPosition();
              changeMyPosition();
              fetchNotifications();
            },
          ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.white),
            tooltip: "Discussion instantanée",
            onPressed: () {
              // Naviguer vers la page de détails de la conversation
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CorrespondentsPage()),
              );
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          SizedBox(height: 10),
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

          // bare de recherche
          // ✅ 2. BARRE DE RECHERCHE + SUGGESTIONS (en haut)
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.canvasColor,
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
                      Container(width: 1, height: 30, color: Colors.grey),
                      IconButton(
                        icon: Icon(Icons.front_hand, color: Colors.green),
                        onPressed: () {
                          // Ici, appelle après que les passagers soient bien chargés
                          analyserPassagers();
                        },
                        tooltip: "Voir les demandeurs de taxi",
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
                            chauffeurPosition.latitude,
                            chauffeurPosition.longitude,
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
                      color: theme.canvasColor,
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child:
                                isLoading
                                    ? Center(child: CircularProgressIndicator())
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
                                      itemCount: listfilteredPlaces.length,
                                      itemBuilder: (context, index) {
                                        var place = listfilteredPlaces[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
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
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            subtitle: Text(
                                              place['description'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            trailing: Icon(
                                              Icons.chevron_right,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                searchEtat = false;
                                              });
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
                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                icon: Icon(Icons.close, color: Colors.red),
                              ),
                            ],
                          ),
                        ),

                        // liste des lieux suggerés
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            itemCount: placesJson.length,
                            separatorBuilder: (_, __) => SizedBox(width: 4),
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
                                  setState(() {
                                    searchEtat = false;
                                  });
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
          //fin bare de recherche

          //information du lieu
          if (hotspot != null && distanceKm != null && estimatedTime != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: showHotspotCard ? 1.0 : 0.0,
                child:
                    showHotspotCard
                        ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                          color: Colors.white,
                          shadowColor: Colors.black54,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.place, color: Colors.green),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Zone de forte demande",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showHotspotCard = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  children: [
                                    Icon(Icons.people, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text("Passagers : ${passagers.length}"),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Distance : ${distanceKm!.toStringAsFixed(2)} km",
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.purple,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Temps estimé : ${estimatedTime!.toStringAsFixed(0)} min",
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                !estDansZoneKinshasa(chauffeurPosition!)
                                    ? ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        // Fonction pour que le chauffeur sélectionne un lieu s’il n’est pas à Goma
                                        _selectLocationManually();
                                      },
                                      icon: Icon(
                                        Icons.my_location,
                                        color: Colors.white,
                                      ),
                                      label: Text("Sélectionner ma position"),
                                    )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
              ),
            ),
          // fin information du lieu

          // Center(child: Text(passagers.toString())),

          // Tester le message du lieu
          Positioned(
            bottom: 20,
            left: 55,
            right: 55,
            child:
                chauffeurPosition == null
                    ? CircularProgressIndicator()
                    : !estDansZoneKinshasa(chauffeurPosition!)
                    ? Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "🚫 L’application Lifti ne supporte pas votre localisation actuelle.",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : searchEtat || showHotspotCard
                    ? SizedBox()
                    : ElevatedButton.icon(
                      onPressed: () {
                        // Naviguer vers sélection destination
                        setState(() {
                          searchEtat = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: Icon(Icons.location_on),
                      label: Text("Où allez-vous ?"),
                    ),
          ),
          // fin test du message du lieu

          // Les bouttons d'actions
          // 🔘 Les boutons avec badges
          Positioned(
            bottom: 100,
            right: 7,
            child: Column(
              children: [
                // 🔔 Bouton notification avec badge
                Stack(
                  children: [
                    FloatingActionButton(
                      heroTag: "btn1",
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          isNotify = false;
                        });
                        showNotificationBottomSheet(context);
                      },
                      child: Icon(Icons.notifications, color: Colors.black),
                    ),
                    if (isNotify)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1.0, end: 1.2),
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          onEnd: () {
                            // Boucle l'animation
                            if (mounted && isNotify) setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 5),

                // 📜 Bouton historique avec badge aussi (optionnel)
                Stack(
                  children: [
                    FloatingActionButton(
                      heroTag: "btn2",
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          isNotify = false;
                        });

                        showCourseBottomSheet(context);
                      },
                      child: Icon(Icons.history, color: Colors.black),
                    ),
                    if (isNotify)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                

               
              ],
            ),
          ),
          //fin boutton

          // Fin de boutton action
        ],
      ),
    );
  }

  /*
*
*===============================
*Affichage de notification
*===============================
*/

  // Fonction pour afficher le BottomSheet
  void showCourseBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight * 0.65, // 50% de l'écran
          width: double.infinity,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
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

              // Course en cours dans une hauteur dynamique
              SizedBox(
                height: screenHeight * 0.57, // ajustable selon ton contenu
                child: CoursesEnCoursChauffeur(),
              ),

              SizedBox(height: 10),
            ],
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

  /*
*
*===============================
* Fin Affichage de notification
*===============================
*/
}

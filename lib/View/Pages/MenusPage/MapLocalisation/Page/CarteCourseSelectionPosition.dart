import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';

import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/button.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/ArretCourseModel.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/services.dart'
    show rootBundle; // Ajout de l'import pour rootBundle
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/ArretListWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CarteCourseSelectionPosition extends StatefulWidget {
  final CourseInfoPassagerModel course;
  const CarteCourseSelectionPosition({super.key, required this.course});

  @override
  State<CarteCourseSelectionPosition> createState() =>
      _CarteCourseSelectionPositionState();
}

class _CarteCourseSelectionPositionState
    extends State<CarteCourseSelectionPosition> {
  LatLng? _selectedLatLng;
  LatLng centerGoma = LatLng(-1.6708, 29.2218);
  LatLng centerKinshasa = LatLng(-4.325, 15.3222);
  late GoogleMapController mapController;

  late LatLng passagerConnectedPosition; // Position actuelle du chauffeur
  Set<Marker> markers = {}; // Marqueurs de la carte
  Set<Polyline> polylines = {}; // Pour afficher la route entre lieu et passager
  bool isLoading = false;
  Set<Circle> circles = {};

  //initialisation des icones
  BitmapDescriptor? customPassagerIcon;
  BitmapDescriptor? customChauffeurIcon;
  BitmapDescriptor? customPlaceIcon;

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
          circleId: CircleId("passager-placeName"),
          center: passagerConnectedPosition,
          radius: 1000, // 1 km en mètres
          strokeWidth: 2,
          strokeColor: Colors.green,
          fillColor: Colors.green.withOpacity(0.2),
        ),
      );
    });
  }

  //retourner le nom
  Future<String> reverseGeocoding(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent':
            'ElimuApp/1.0 contact@dreamofdrc.com', // Remplace par ton email réel
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data['display_name']);
      return data['display_name']; // Adresse complète
    } else {
      print('Erreur Reverse: ${response.statusCode}');
      return "";
    }
  }

  /*
  *
  *============================
  * Visualisation des lieux
  *============================
  *
  */
  bool isBottomSheetOpen = true;

  // Fonction pour obtenir et tracer l'itinéraire
  Future<void> _getRoutePlace(LatLng start, LatLng end) async {
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
            String name = await reverseGeocoding(
              start.latitude,
              start.longitude,
            );
            double latitude = start.latitude;
            double longitude = start.longitude;
            Map<String, dynamic> place = {
              "name": name,
              "latitude": latitude,
              "longitude": longitude,
              "idCourse": widget.course.id!,
            };
            if (name != "") {
              _showPlaceInfo(place, distance, duration);
            }
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
        final l10n = AppLocalizations.of(context)!;
        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.60,
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
                                l10n.info_lieu,
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
                            label: l10n.info_adresse,
                            value: place["name"],
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
                            label: l10n.info_distance,
                            value: "${distance.toStringAsFixed(2)} km",
                            maxWidth: constraints.maxWidth,
                          ),
                          Divider(color: Colors.grey[400]),

                          _infoRow(
                            icon: Icons.timer,
                            iconColor: Colors.purple,
                            label: l10n.info_temps,
                            value: "${duration.toStringAsFixed(2)} min",
                            maxWidth: constraints.maxWidth,
                          ),

                          SizedBox(height: 20),
                          Divider(color: Colors.grey[400]),

                          // Bouton de commande
                          Align(
                            alignment: Alignment.center,
                            child: Button(
                              icon: Icons.place,
                              label: l10n.ui_global_ajout,
                              press: () {
                                // print("place: $place");
                                insertionArret(
                                  place['idCourse'],
                                  place['latitude'],
                                  place['longitude'],
                                  place['name'],
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

  insertionArret(
    int idCourse,
    double latArret,
    double lonArret,
    String nameLieu,
  ) async {
    try {
      Map<String, dynamic> svData = {
        "id": "",
        "idCourse": idCourse,
        "latArret": latArret,
        "lonArret": lonArret,
        "nameLieu": nameLieu,
      };

      final response = await CallApi.insertData(
        endpoint: "insert_arret_vehicule",
        data: svData,
      );
      if (response['data'] != "") {
        // print(response['data']);
        Navigator.pop(context);
        showSnackBar(context, response['data'].toString(), "success");
      }
    } catch (e) {
      showSnackBar(context, e.toString(), "danger");
      print(e.toString());
    }
  }

  updateStatutArretCourse(int idCourse) async {
    try {
      Map<String, dynamic> svData = {"idCourse": idCourse};

      final response = await CallApi.insertData(
        endpoint: "updateStatutArretCourse",
        data: svData,
      );
      if (response['data'] != "") {
        showSnackBar(context, response['data'].toString(), "success");
      }
    } catch (e) {
      showSnackBar(context, e.toString(), "danger");
      print(e.toString());
    }
  }

  /*
  *
  *==================================
  * Determination de la position
  *==================================
  *
  */

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
  *============================
  * Fin Visualisation des lieux
  *============================
  *
  */
  List<ArretCourseModel> arretList = [];

  Future<void> fetchArret() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> data = await CallApi.fetchListData(
        "get_arret_course/${widget.course.id}",
      );
      // print("data: $data");
      setState(() {
        arretList = data.map((item) => ArretCourseModel.fromMap(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  void showArretBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.95,
            minChildSize: 0.3,
            builder:
                (_, __) => ArretListWidget(
                  course: widget.course,
                  etatSuppression: true,
                ),
          ),
    );
  }

  /*
  *
  *==============================
  * Pour la recherche
  *==============================
  *
  */
  final TextEditingController searchController = TextEditingController();
  
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

  //pour la recherche

  List<Map<String, dynamic>> places = [];
  List<dynamic> listfilteredPlaces = []; // Liste filtrée pour la recherche

  bool isSearchingBottom = false;

  void goToPlace(
    LatLng location,
    String placeName,
    Map<String, dynamic> place,
  ) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(location, 15));

    _getRoutePlace(
      passagerConnectedPosition,
      LatLng(place['latitude'], place['longitude']),
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

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> cities = await CallApi.fetchListData(
        'chauffeur_mobile_map_city',
      );

      // print(typeCourse);
      setState(() {
        placesJson = cities;

        isLoading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  /*
  *
  *==============================
  * Fin Pour la recherche
  *==============================
  *
  */

  @override
  void initState() {
    super.initState();
    fetchArret();
    changeMyPosition();

    passagerConnectedPosition = LatLng(
      // -1.6708,
      // 29.2218,
      -4.325,
      15.3222
    ); // Position par défaut du chauffeur (ex: Goma)
    _getCurrentPosition(); // Récupère la position actuelle du chauffeur
    fetchNotifications();

    //ajout des places
    _loadIcons();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text(
          l10n.carteArretTitre,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            tooltip: l10n.carteArretConfirmer,
            color: Colors.white,
            onPressed: () {
              if (_selectedLatLng != null || arretList.isNotEmpty) {
                updateStatutArretCourse(widget.course.id!);

                Navigator.pop(context);
                // Navigator.pop(context, _selectedLatLng);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.list_rounded, color: Colors.white),
            tooltip: "Liste des arrets",
            onPressed: () async {
              showArretBottomSheet(context);
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.chat, color: Colors.white),
          //   tooltip: "Discussion instantanée",
          //   onPressed: () {
          //     Navigator.of(
          //       context,
          //     ).push(AnimatedPageRoute(page: CorrespondentsPage()));
          //   },
          // ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: centerKinshasa, // Kinshasa centre
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: (LatLng latLng) {
              setState(() {
                _selectedLatLng = latLng;
              });
            },
            polylines:
                polylines, // Affichage des polylines pour les itinéraires
            circles: circles, // Ajout des cercles

            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers:
                _selectedLatLng != null
                    ? {
                      Marker(
                        markerId: MarkerId("selected"),
                        position: _selectedLatLng!,
                        onTap: () {
                          LatLng latlonPosition = _selectedLatLng!;
                          _getRoutePlace(
                            passagerConnectedPosition,
                            LatLng(
                              latlonPosition.latitude,
                              latlonPosition.longitude,
                            ),
                          );
                        },
                      ),
                    }
                    : {},
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
                            hintText: l10n.search,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(width: 1, height: 30, color: Colors.grey),
                      IconButton(
                        icon: Icon(Icons.calendar_month, color: Colors.green),
                        onPressed: () {
                          // searchPlace2();
                        },
                      ),
                    ],
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
                                        l10n.nosearchData,
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
                                              // goToPlace(
                                              //   LatLng(
                                              //     place['latitude'],
                                              //     place['longitude'],
                                              //   ),
                                              //   place['name'],
                                              //   place,
                                              // );
                                              setState(() {
                                                _selectedLatLng = LatLng(
                                                  place['latitude'],
                                                  place['longitude'],
                                                );
                                                searchEtat = false;
                                              });
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
                                l10n.carteArret_suggestion,
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
                                  // goToPlace(
                                  //   LatLng(
                                  //     place['latitude'],
                                  //     place['longitude'],
                                  //   ),
                                  //   place['name'],
                                  //   place,
                                  // );

                                  setState(() {
                                    _selectedLatLng = LatLng(
                                      place['latitude'],
                                      place['longitude'],
                                    );
                                    searchEtat = false;
                                  });
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
        ],
      ),
    );
  }
}

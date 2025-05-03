import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/Components/button.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Model/ArretCourseModel.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart'
    show rootBundle; // Ajout de l'import pour rootBundle
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/ArretListWidget.dart';

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
                              icon: Icons.place,
                              label: "Ajouter",
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

  @override
  void initState() {
    super.initState();
    fetchArret();
    changeMyPosition();

    passagerConnectedPosition = LatLng(
      -1.6708,
      29.2218,
    ); // Position par défaut du chauffeur (ex: Goma)
    _getCurrentPosition(); // Récupère la position actuelle du chauffeur

    //ajout des places
    _loadIcons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text(
          "Ajouter les arrets",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            tooltip: "Confirmer les ajouts des arrets de ce course",
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
              target: centerGoma, // Kinshasa centre
              zoom: 14,
            ),
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
        ],
      ),
    );
  }
}

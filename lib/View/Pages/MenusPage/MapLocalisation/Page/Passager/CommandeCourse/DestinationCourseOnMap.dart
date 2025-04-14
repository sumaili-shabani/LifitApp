import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';

import 'package:lifti_app/Api/my_api.dart';

import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Controller/NotificationService.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart'
    show rootBundle; // Ajout de l'import pour rootBundle
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:lifti_app/Model/UserPositionModel.dart';

class Destinationcourseonmap extends StatefulWidget {
  final CourseInfoPassagerModel course;
  final Function(CourseInfoPassagerModel) onSubmitComment; // Callback function
  const Destinationcourseonmap({
    super.key,
    required this.course,
    required this.onSubmitComment,
  });

  @override
  State<Destinationcourseonmap> createState() => _DestinationcourseonmapState();
}

class _DestinationcourseonmapState extends State<Destinationcourseonmap> {
  static const String apikeyOpenrouteservice =
      "5b3ce3597851110001cf62484e660c3aa019470d8ac388d12b974480";
  bool isBottomSheetOpen = false;
  bool isNotify = true;

  late GoogleMapController mapController;
  late LatLng passagerConnectedPosition; // Position actuelle du chauffeur
  Set<Marker> markers = {}; // Marqueurs de la carte
  Set<Circle> circles = {}; //rayon de 1 km
  Set<Polyline> polylines =
      {}; // Pour afficher la route entre chauffeur et passager

  bool isLoading = false;

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

  List<UserPositionModel> userInfo = [];
  UserPositionModel? userToFetch;
  getPositionUser() async {
    int refChauffeur = widget.course.refChauffeur ?? 0;
    print("refChauffeur: $refChauffeur");

    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> positionMap = await CallApi.fetchListData(
        'get_location_user/${refChauffeur.toInt()}',
      );

      print(positionMap);

      setState(() {
        userInfo =
            positionMap.map((item) => UserPositionModel.fromMap(item)).toList();
        userToFetch = userInfo.isNotEmpty ? userInfo.first : null;
        isLoading = false;
      });

      // Ajouter les marqueurs pour chaque passager
      _addPassengerMarkers();
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
  }

  // Fonction pour ajouter les marqueurs des passagers sur la carte
  void _addPassengerMarkers() {
    for (var user in userInfo) {
      setState(() {
        userToFetch = user;
      });
      final marker = Marker(
        markerId: MarkerId(user.id.toString()),
        position: LatLng(user.latUser ?? 0, user.lonUser ?? 0),
        infoWindow: InfoWindow(
          title: user.name ?? '',
          snippet: 'Tel: ${user.telephone ?? ''}',
        ),
        icon:
            customChauffeurIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor
                  .hueGreen, // Icône par défaut si le chargement échoue
            ), // Marqueur vert pour le passager
        onTap: () {
          _getRoute(
            passagerConnectedPosition,
            LatLng(user.latUser!, user.lonUser!),
            user, // Passer les informations du passager à la fonction
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
    UserPositionModel passager,
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
              // isSearchingBottom = false;
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

             if (routeCoords.isNotEmpty) {
              animateChauffeur(
                routeCoords,
              ); // 🔥 Lancer l'animation du chauffeur avec rotation
            }
           
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
    UserPositionModel passager,
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
                    Row(
                      children: [
                        Icon(Icons.person, size: 18),
                        SizedBox(width: 3),
                        Text(
                          "Informations du chauffeur",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                        Text("Nom: ${passager.name ?? ''}"),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.orange),
                        SizedBox(width: 5),
                        Text("Téléphone: ${passager.telephone ?? ''}"),
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

  /*
  *
  *======================================
  * Informations du lieu
  *======================================
  */
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
              height: MediaQuery.of(context).size.height * 0.50,
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
  *=============================
  * Recherche des position
  *=============================
  *
  *
  */

  Future changeMyPosition() async {
    Position? position = await ApiService.getCurrentLocation();
    if (position != null) {
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
    customPlaceIcon = await getCustomIcon("assets/images/ic_pick_48.png");
    setState(() {}); // Rafraîchir l'affichage après le chargement
  }

  /*
  *
  *=============================
  * Recherche des places
  *=============================
  *
  *
  */
  Timer? _timer;
  int? minutesRestantes;

  bool notifEnvoyee = false;

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      final dateLimite = DateTime.parse(
        widget.course.dateLimiteCourse.toString(),
      );
      final now = DateTime.now();

      setState(() {
        minutesRestantes = dateLimite.difference(now).inMinutes;

        if (minutesRestantes != null &&
            minutesRestantes! == 0 &&
            !notifEnvoyee) {
          NotificationService.showSimpleNotification(
            title: "Vos minutes sont épuisées",
            body:
                "Vos ${widget.course.timeEst ?? '0'} minutes sont écoulées. Veuillez procéder au paiement du surplus de votre course.",
          );
          notifEnvoyee = true;
        }
      });
    });
  }


  /*
  *
  *=========================
  * Taxi en mouvement
  *=========================
  *
  */
  
  //animation et rotation
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
        passagerConnectedPosition = current;
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
        Duration(milliseconds: 2000),
      ); // Pause entre chaque déplacement
    }
  }


  getPlaceByLatLon() {
     Map<String, dynamic> place = {
      "name": widget.course.nameDestination ?? '',
      "latitude": widget.course.latDestination!,
      "longitude": widget.course.lonDestination!,
      "description": widget.course.nameDestination ?? '',
    };
    final marker = Marker(
      markerId: MarkerId("place-destination"),
      position: LatLng(
        widget.course.latDestination!,
        widget.course.lonDestination!,
      ),
      infoWindow: InfoWindow(
        title: widget.course.nameDestination ?? '',
        snippet:
            "Distance: ${widget.course.distance ?? 0} Km / (${widget.course.timeEst ?? ''})",
      ),
      icon:
          customPlaceIcon ??
          BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor
                .hueGreen, // Icône par défaut si le chargement échoue
          ), // Marqueur vert pour le passager
      onTap: () {
        _getRoutePlace(
          passagerConnectedPosition,
          LatLng(widget.course.latDestination!, widget.course.lonDestination!),
          place, // Passer les informations du passager à la fonction
        );
      },
    );

    setState(() {
      markers.add(marker);
    });
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
    changeMyPosition();
    getPositionUser();

    passagerConnectedPosition = LatLng(
      -1.6708,
      29.2218,
    ); // Position par défaut du chauffeur (ex: Goma)
    _getCurrentPosition(); // Récupère la position actuelle du chauffeur

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      getPositionUser();
      _startCountdown();
    });

    getPlaceByLatLon();
   

    _loadIcons();

    // _getRoute(
    //   passagerConnectedPosition,
    //   LatLng(
    //     widget.course.latDestination!,
    //     widget.course.lonDestination!,
    //   ),
    //   userToFetch!, // Passer les informations de la places la fonction
    // );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Arrêter le timer pour éviter les fuites de mémoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      height:
          MediaQuery.of(context).size.height *
          0.90, // Augmenté à 75% pour plus de visibilité
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
          Center(
            child: Row(
              children: [
                Icon(Icons.map, size: 17),
                SizedBox(width: 3),
                Expanded(
                  child: Text(
                    "${widget.course.nameDestination ?? 'Destination'} ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // map ici

          //la carte ici
          Expanded(
            child: Stack(
              children: [
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

                  myLocationEnabled:
                      false, // Active la localisation de l'utilisateur
                  zoomControlsEnabled:
                      true, // Désactive les boutons de zoom pour éviter les conflits
                  tiltGesturesEnabled: true, // Permet l'inclinaison
                  rotateGesturesEnabled: true, // Permet la rotation
                  scrollGesturesEnabled: true, // Permet le déplacement
                ),
                // positionnement et affichage de la distance
                isNotify
                    ? Positioned(
                      top: 20, // ➜ affichage en haut de l'écran
                      left: 10,
                      right: 10,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ⏱️ Durée de la course
                              Row(
                                children: [
                                  Icon(Icons.timer, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    "Durée de la course ${(widget.course.timeEst ?? '0')}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              // 🚕 Heure d'arrivage
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_taxi,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Heure d'arrivage : ${CallApi.formatDateFrancais(widget.course.dateLimiteCourse) ?? '0'}",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),

                              // 📍 Distance
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Distance : ${(widget.course.distance ?? 0).toStringAsFixed(2)}Km",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),

                              Divider(height: 20, thickness: 1),

                              // ⏳ Temps restant
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.hourglass_bottom,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Temps restant : ",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    minutesRestantes != null
                                        ? "${minutesRestantes!.abs()} min"
                                        : "...",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          minutesRestantes != null &&
                                                  minutesRestantes! < 0
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    : SizedBox(),
                // fin affichage de la distance

                // 🔘 Les boutons avec badges
                Positioned(
                  right: 10, // Positionné à gauche
                  top:
                      MediaQuery.of(context).size.height / 2 -
                      1, // Centrage vertical approximatif
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
                                isNotify = !isNotify;
                              });
                              _startCountdown();
                            },
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.black,
                            ),
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
                                  return Transform.scale(
                                    scale: scale,
                                    child: child,
                                  );
                                },
                                onEnd: () {
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
                      SizedBox(height: 10),

                      // 📍 Bouton position actuelle
                      FloatingActionButton(
                        heroTag: "btn3",
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          _getRoute(
                            passagerConnectedPosition,
                            LatLng(
                              widget.course.latDestination!,
                              widget.course.lonDestination!,
                            ),
                            userToFetch!, // Passer les informations de la places la fonction
                          );
                          _getCurrentPosition();
                          changeMyPosition();
                          getPositionUser();
                          mapController.animateCamera(
                            CameraUpdate.newLatLng(passagerConnectedPosition),
                          );
                        },
                        child: Icon(Icons.my_location, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //fin integration map

          // fin map
        ],
      ),
    );
  }
}

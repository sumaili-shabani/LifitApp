import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/showSnackBar.dart';
import 'package:lifti_app/Controller/ApiService.dart';
import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart'
    show rootBundle; // Ajout de l'import pour rootBundle
import 'package:http/http.dart' as http;
import 'package:lifti_app/Api/ConfigurationApp.dart';
import 'dart:convert';

import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:lifti_app/Model/UserPositionModel.dart';

class PositionPassagerOnMap extends StatefulWidget {
  final CourseInfoPassagerModel course;
  final Function(CourseInfoPassagerModel) onSubmitComment; // Callback function
  const PositionPassagerOnMap({
    super.key,
    required this.course,
    required this.onSubmitComment,
  });

  @override
  State<PositionPassagerOnMap> createState() => _PositionPassagerOnMapState();
}

class _PositionPassagerOnMapState extends State<PositionPassagerOnMap> {
  static const String apikeyOpenrouteservice =
      "5b3ce3597851110001cf62484e660c3aa019470d8ac388d12b974480";
  bool isBottomSheetOpen = false;

  late GoogleMapController mapController;
  late LatLng chauffeurConnectedPosition; // Position actuelle du chauffeur
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
      chauffeurConnectedPosition = LatLng(
        position.latitude,
        position.longitude,
      ); // Met à jour la position du chauffeur
      markers.add(
        Marker(
          markerId: MarkerId('Chauffeur'),
          position: chauffeurConnectedPosition,
          infoWindow: InfoWindow(title: 'Vous etes ici !!!'),
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
          center: chauffeurConnectedPosition,
          radius: 1000, // 1 km en mètres
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.2),
        ),
      );
    });
  }

  List<UserPositionModel> userInfo = [];
  getPositionUser() async {
    int refPassager = widget.course.refPassager ?? 0;
    print("refPassager: $refPassager");

    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> positionMap = await CallApi.fetchListData(
        'get_location_user/${refPassager.toInt()}',
      );

      print(positionMap.first);

      setState(() {
        userInfo =
            positionMap.map((item) => UserPositionModel.fromMap(item)).toList();
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
      final marker = Marker(
        markerId: MarkerId("user-${user.id.toString()}"),
        position: LatLng(user.latUser!, user.lonUser!),
        infoWindow: InfoWindow(
          title: user.name ?? '',
          snippet: 'Tel: ${user.telephone ?? ''}',
        ),
        icon:
            customPassagerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor
                  .hueBlue, // Icône par défaut si le chargement échoue
            ), // Marqueur vert pour le passager
        onTap: () {
          _getRoute(
            chauffeurConnectedPosition,
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
                color: Colors.blue,
                width: 5,
              ),
            );
          });

          // Afficher le BottomSheet avec les informations du passager
          // ignore: unnecessary_null_comparison
          if (distance != null || distance != "") {
            _showPassengerInfo(
              passager,
              distance,
              duration,
              widget.course,
              routeCoords,
            );
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

  /// 🔹 **Méthode Changement de statut**
  Future<void> checkStatutCourse(
    int id,
    String statut,
    int refPassager,
    int refChauffeur,
    String url,
  ) async {
    try {
      final response = await CallApi.deleteData(
        "$url/${id.toInt()}/${statut.toString()}/${refPassager.toString()}/${refChauffeur.toString()}",
      );

      final Map<String, dynamic> responseData = response;
      String message = responseData['data'] ?? "Deleted!!!";
      showSnackBar(context, message, 'success');

      getPositionUser();
    } catch (e) {
      print('Error fetching demandes: $e');
    }
  }

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
        chauffeurConnectedPosition = current;
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

  void _showPassengerInfo(
    UserPositionModel passager,
    double distance,
    double duration,
    CourseInfoPassagerModel course,
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
                    Divider(),

                    course.status == '2' || course.status == '3'
                        ? Row(
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

                               if (course.calculate==0) {
                                  checkStatutCourse(
                                    course.id!,
                                    course.status!,
                                    course.refPassager!,
                                    course.refChauffeur!,
                                    "checkEtat_DisponibiliteLocationCourse",
                                  );
                               } else {
                                  checkStatutCourse(
                                    course.id!,
                                    course.status!,
                                    course.refPassager!,
                                    course.refChauffeur!,
                                    "checkEtat_DemandeCourse",
                                  );
                               }
                              },
                              child: Text("Accepter la demande de la course"),
                            ),
                          ],
                        )
                        : SizedBox(),

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
    customChauffeurIcon = await getCustomIcon("assets/images/taxi_icon.png");
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

  @override
  void initState() {
    super.initState();
    changeMyPosition();
    getPositionUser();

    chauffeurConnectedPosition = LatLng(
      -1.6708,
      29.2218,
    ); // Position par défaut du chauffeur (ex: Goma)
    _getCurrentPosition(); // Récupère la position actuelle du chauffeur

    _loadIcons();

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      getPositionUser();
    });

    // _getRoutePlace(
    //   chauffeurConnectedPosition,
    //   LatLng(place['latitude'], place['longitude']),
    //   place, // Passer les informations de la places la fonction
    // );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Arrêter le timer pour éviter les fuites de mémoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height:
          MediaQuery.of(context).size.height *
          0.75, // Augmenté à 75% pour plus de visibilité
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
            child: Text(
              "Positionnement actuelle",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16),

          // map ici

          //la carte ici
          Expanded(
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                  0.6, // Ajuste la hauteur selon le BottomSheet
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      chauffeurConnectedPosition, // Position initiale de la caméra (chauffeur)
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
                    true, // Active la localisation de l'utilisateur
                zoomControlsEnabled:
                    true, // Désactive les boutons de zoom pour éviter les conflits
                tiltGesturesEnabled: true, // Permet l'inclinaison
                rotateGesturesEnabled: true, // Permet la rotation
                scrollGesturesEnabled: true, // Permet le déplacement
              ),
            ),
          ),
          //fin integration map

          // fin map
        ],
      ),
    );
  }
}

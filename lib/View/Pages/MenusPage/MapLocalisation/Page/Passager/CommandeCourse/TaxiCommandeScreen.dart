import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle; // Correction ici
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';

import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/PayementCourse.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/ReservationCourse.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class TaxiCommandeScreen extends StatefulWidget {
  final List<dynamic> typeCourses;
  final Map<String, dynamic> trajectoire;
  final Map<String, dynamic> datainfotarification;
  final Map<String, dynamic> categorieVehiculeInfo;
  final int refCategorie;

  const TaxiCommandeScreen({
    super.key,
    required this.typeCourses,
    required this.trajectoire,
    required this.datainfotarification,
    required this.categorieVehiculeInfo,
    required this.refCategorie,
  });

  @override
  State<TaxiCommandeScreen> createState() => _TaxiCommandeScreenState();
}

class _TaxiCommandeScreenState extends State<TaxiCommandeScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng passengerPosition = LatLng(-1.6708, 29.2218);

  bool isLoading = true;
  bool isSearchingBottom = false;
  Set<Circle> circles = {};
  Set<Polyline> polylines = {};

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
    setState(() {});
  }

  Future<void> _getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      passengerPosition = LatLng(position.latitude, position.longitude);
      markers.add(
        Marker(
          markerId: MarkerId('Passager'),
          position: passengerPosition,
          infoWindow: InfoWindow(title: 'Vous êtes ici!'),
          icon:
              customPassagerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      circles.clear();
      circles.add(
        Circle(
          circleId: CircleId("Vous êtes ici!"),
          center: passengerPosition,
          radius: 1000,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.2),
        ),
      );
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
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

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> changeMyPosition() async {
    try {
      Position position = await _determinePosition();
      print("Nouvelle position: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Erreur lors du changement de position: $e");
    }
  }

  List<dynamic> categories = [
    {
      "id": 2,
      "refChauffeur": 30,
      "refConduite": 2,
      "refVehicule": 2,
      "idChauffeur": 27,
      "refUser": 27,
      "roleName": "Chauffeur",
      "name": "029 Tx-Toyota TX / 22GH78-33",
      "nom_organisation": "Voiture privée",
      "nom_type_organisation": "Personnel",
      "position": [-1.6734772, 29.22774],
      "coords": {"lat": -1.6734772, "lonUser": 29.22774},
      "avatar": "1741814605.jpg",
      "imgUrl": "taxi-map.png",
      "nameChauffeur": "Drey Mukuka",
      "telephoneChauffeur": "+243996618763",
      "sexeChauffeur": "M",
      "capo": 1,
      "detailCapo": "Moyen",
      "nbrPlace": 4,
      "typeCarburant": "Essence",
      "designationVehicule": "Voiture normale-Toyota TX / 22GH78-33",
      "imageVehicule": "taxi.png",
    },
  ];
  List<dynamic> filteredCategories = [];
  bool showSearchBar = false;
  TextEditingController searchController = TextEditingController();

  Future<void> fetchNotifications() async {
    int? userId =
        await CallApi.getUserId(); // Récupérer l'ID de l'utilisateur connecté
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      List<dynamic> listVehicule = await CallApi.fetchListData(
        'fetch_vehicule_map_on_line_bycatvehicule/${widget.refCategorie}',
      );

      print(listVehicule);

      setState(() {
        categories = listVehicule;
        filteredCategories = listVehicule;
        isLoading = false;
        markers =
            listVehicule.map((chauffeur) {
              return Marker(
                markerId: MarkerId(chauffeur["id"].toString()),
                position: LatLng(
                  chauffeur["coords"]["lat"],
                  chauffeur["coords"]["lonUser"],
                ),
                infoWindow: InfoWindow(title: chauffeur["name"]),
                icon:
                    customChauffeurIcon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                onTap:
                    () => _showDriverProfile(
                      widget.typeCourses,
                      widget.trajectoire,
                      widget.datainfotarification,
                      widget.categorieVehiculeInfo,
                      widget.refCategorie,
                    ),
              );
            }).toSet();
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => isLoading = false);
    }
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
                  (category) => category['name']!.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      });
    }
  }

  void _showDriverProfile(
    List<dynamic> typeCourses,
    Map<String, dynamic> trajectoire,
    Map<String, dynamic> datainfotarification,
    Map<String, dynamic> categorieVehiculeInfo,
    int refCategorie,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => ReservationTaxi(
            typeCourses: typeCourses,
            trajectoire: trajectoire,
            refCategorie: refCategorie,
            datainfotarification: datainfotarification,
            onCategorySelected: (Map<String, dynamic> selectedCourse) {
              // print("CategorySelected : $selectedCourse");
            },
          ),
    );
  }

  chargement() {
    setState(() {
      circles.clear();
      markers.clear();
      categories.clear();
      filteredCategories.clear();
    });
    _loadIcons().then((_) => fetchNotifications());
    _getCurrentPosition();

  }

  @override
  void initState() {
    super.initState();
    chargement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text("Taxis", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              chargement();
            },
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: "Recharger les taxis disposibles",
          ),
          IconButton(
            onPressed: () {
              showCourseBottomSheet(
                context,
                widget.trajectoire,
                widget.datainfotarification,
                widget.categorieVehiculeInfo,
              );
            },
            tooltip: "Payer une course",
            icon: Icon(Icons.attach_money, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              _showDriverProfile(
                widget.typeCourses,
                widget.trajectoire,
                widget.datainfotarification,
                widget.categorieVehiculeInfo,
                widget.refCategorie,
              );
            },
            icon: Icon(Icons.local_taxi, color: Colors.white),
            tooltip: "Voir les taxis disposibles",
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: passengerPosition,
          zoom: 14,
        ),
        markers: markers,
        circles: circles,
      ),
    );
  }

  // Fonction pour afficher le BottomSheet
  void showCourseBottomSheet(
    BuildContext context,
    Map<String, dynamic> trajectoire,
    Map<String, dynamic> datainfotarification,
    Map<String, dynamic> categorieVehiculeInfo,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Plein écran
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Payementcourse(
            typeCourses: widget.typeCourses,
            trajectoire: trajectoire,
            datainfotarification: datainfotarification,
            categorieVehiculeInfo: categorieVehiculeInfo,
            refCategorie: widget.refCategorie,
            onCategorySelected: (CourseInfoPassagerModel course) {
                print("idCourse: ${course.id}");
                showRatingBottomSheet(context, course);
            },
          ),
    );
  }

  //commentaire 

  void showRatingBottomSheet(BuildContext context, CourseInfoPassagerModel course) {
    double rating = 3.0; // Note par défaut
    TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.5, // 60% de l'écran
          child: Padding(
            padding: EdgeInsets.all(16),
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
                    "Évaluez votre chauffeur",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
          
                // ⭐ Système de notation
                Center(
                  child: RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder:
                        (context, _) => Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (newRating) {
                      rating = newRating;
                    },
                  ),
                ),
                SizedBox(height: 16),
          
                // ✍️ Champ de commentaire
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: "Laissez un commentaire...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
          
                // ✅ Bouton d'envoi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      String comment = commentController.text;
                      print("Note: $rating, Commentaire: $comment");
                      Navigator.pop(context); // Ferme le BottomSheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Envoyer",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

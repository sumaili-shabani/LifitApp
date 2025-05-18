import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle; // Correction ici
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:lifti_app/Api/my_api.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';

import 'package:lifti_app/Model/CourseInfoPassagerModel.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/Commentaire.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/PayementCourse.dart';
import 'package:lifti_app/View/Pages/MenusPage/MapLocalisation/Page/Passager/CommandeCourse/ReservationCourse.dart';
import 'package:lifti_app/View/Pages/MenusPage/NotificationBottom.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaxiCommandeScreen extends StatefulWidget {
  final List<dynamic> typeCourses;
  final Map<String, dynamic> trajectoire;
  final Map<String, dynamic> datainfotarification;
  final Map<String, dynamic> categorieVehiculeInfo;
  final int refCategorie;
  final bool isLocation;

  const TaxiCommandeScreen({
    super.key,
    required this.typeCourses,
    required this.trajectoire,
    required this.datainfotarification,
    required this.categorieVehiculeInfo,
    required this.refCategorie,
    required this.isLocation,
  });

  @override
  State<TaxiCommandeScreen> createState() => _TaxiCommandeScreenState();
}

class _TaxiCommandeScreenState extends State<TaxiCommandeScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng passengerPosition = LatLng(
    // -1.6708, 29.2218
    -4.325,
    15.3222
  );

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
          strokeColor: Colors.green,
          fillColor: Colors.green.withOpacity(0.2),
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
      int refTypeCourse = widget.datainfotarification['refTypeCourse'];

      String url =
          "fetch_vehicule_map_on_line_bycatvehicule/${widget.refCategorie}/$refTypeCourse";
      // print("url: $url");
      List<dynamic> listVehicule = await CallApi.fetchListData(url);

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
                      widget.isLocation,
                      chauffeur["name"],
                      chauffeur['restePlace'],



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
    bool isLocation,
    String nameVehicule,
    int restePlace,
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
            isLocation: isLocation,
            nameVehicule: nameVehicule,
            restePlace: restePlace
          ),
    );
  }

  void showNotificationInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NotificationBottom(),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text("${l10n.map_client_texte_taxis}", style: TextStyle(color: Colors.white)),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  showNotificationInfo();
                },
                icon: Icon(Icons.notification_add, color: Colors.white),
                tooltip: "${l10n.map_client_voir_notification}",
              ),
              if (2 >
                  0) // Afficher le badge seulement s'il y a des notifications
                Positioned(
                  right: 0,
                  top: 1,

                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '2+',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              chargement();
            },
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: "${l10n.map_client_recharge_notification}",
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
            tooltip: "${l10n.map_client_payer_course}",
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
                widget.isLocation,
                "",
                0
              );
            },
            icon: Icon(Icons.local_taxi, color: Colors.white),
            tooltip: "${l10n.map_client_voir_le_taxi}",
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

  void showRatingBottomSheet(
    BuildContext context,
    CourseInfoPassagerModel course,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => CommentaireCourse(
            course: course,
            onSubmitComment: (course) {
              print("idcourse: ${course.id}");

              Navigator.pop(context); // Ferme le BottomSheet
            },
          ),
    );
  }
}

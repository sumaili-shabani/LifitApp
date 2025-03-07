import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ChauffeurMapScreen extends StatefulWidget {
  const ChauffeurMapScreen({super.key});

  @override
  State<ChauffeurMapScreen> createState() => _ChauffeurMapScreenState();
}

class _ChauffeurMapScreenState extends State<ChauffeurMapScreen> {
  GoogleMapController? mapController;
  LatLng chauffeurPosition = LatLng(-1.6708, 29.2218);
  List<Marker> placeMarkers = [];
  List<dynamic> placesData = [];
  List<dynamic> filteredPlaces = [];

  // JSON contenant les lieux populaires de Goma
  String placesJson = '''
  [
    {"name": "Place de l'Indépendance", "latitude": -1.6701, "longitude": 29.2215},
    {"name": "Hôpital Heal Africa", "latitude": -1.6750, "longitude": 29.2250},
    {"name": "Université de Goma", "latitude": -1.6780, "longitude": 29.2202},
    {"name": "Aéroport de Goma", "latitude": -1.6773, "longitude": 29.2425},
    {"name": "Ndoyo", "latitude": -1.6698, "longitude": 29.2312}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  void loadPlaces() {
    setState(() {
      placesData = json.decode(placesJson);
      placeMarkers =
          placesData.map((data) {
            return Marker(
              markerId: MarkerId(data['name']),
              position: LatLng(data['latitude'], data['longitude']),
              infoWindow: InfoWindow(title: data['name']),
            );
          }).toList();
    });
  }

  void searchPlace(String query) async {
    if (query.isEmpty) {
      setState(() => filteredPlaces = []);
      return;
    }

    // Filtrer les lieux locaux
    List<dynamic> localResults =
        placesData.where((place) {
          return place['name'].toLowerCase().contains(query.toLowerCase());
        }).toList();

    if (localResults.isNotEmpty) {
      setState(() => filteredPlaces = localResults);
    } else {
      // Si aucun lieu local trouvé, appeler l'API de Google Maps
      await searchPlaceFromApi(query);
    }
  }

  Future<void> searchPlaceFromApi(String query) async {
    final String apiKey ='AIzaSyBgSz7TPCEIkEHw9CbO93tZQqFSa2pz1ZE'; // Remplacez par votre clé API
    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));

   

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

       print(data);
      if (data['results'].isNotEmpty) {
        final place = data['results'][0];
        final location = place['geometry']['location'];

        setState(() {
          filteredPlaces = [
            {
              "name": place['name'],
              "latitude": location['lat'],
              "longitude": location['lng'],
            },
          ];
        });
      }
    }
  }

  void goToPlace(LatLng location) {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
  }

  void showSearchSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Rechercher un lieu',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: searchPlace,
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: Icon(Icons.place, color: Colors.blue),
                        title: Text(place['name']),
                        onTap: () {
                          goToPlace(
                            LatLng(place['latitude'], place['longitude']),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carte du Chauffeur"),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: showSearchSheet),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: chauffeurPosition,
          zoom: 15.0,
        ),
        markers: Set.from(placeMarkers),
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}

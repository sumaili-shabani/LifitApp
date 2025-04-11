import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifti_app/Api/my_api.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:http/http.dart' as http;

class SearchLocation2 extends StatefulWidget {
  const SearchLocation2({super.key});

  @override
  State<SearchLocation2> createState() => _SearchLocation2State();
}

class _SearchLocation2State extends State<SearchLocation2> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool showDateTimePicker = false;

  String? homeLocation;
  String? workLocation;

  final List<Map<String, dynamic>> categories = [
    {
      'label': 'Restaurants',
      'icon': Icons.restaurant,
      'category_ids': [221], // OSM ID pour restaurants
    },
    {
      'label': 'Hôtels',
      'icon': Icons.hotel,
      'category_ids': [210], // OSM ID pour hôtels
    },
    {
      'label': 'Stations',
      'icon': Icons.ev_station,
      'category_ids': [230], // Stations de recharge, essence, etc.
    },
    {
      'label': 'Hôpitaux',
      'icon': Icons.local_hospital,
      'category_ids': [201], // Centres de santé
    },
    {
      'label': 'Écoles',
      'icon': Icons.school,
      'category_ids': [120], // Écoles
    },
    {
      'label': 'Parcs',
      'icon': Icons.park,
      'category_ids': [270], // Parcs et espaces verts
    },
  ];


  Future<void> fetchPOIsByCategory(
    List<int> categoryIds,
    double lat,
    double lon,
  ) async {
    String apikeyOpenrouteservice = CallApi.apikeyOpenrouteservice;

    final body = jsonEncode({
      "request": "pois",
      "geometry": {
        "geojson": {
          "type": "Point",
          "coordinates": [lon, lat],
        },
        "buffer": 500, // rayon en mètres autour du point
      },
      "filters": {"category_ids": categoryIds},
    });

    final response = await http.post(
      Uri.parse('https://api.openrouteservice.org/pois'),
      headers: {'Authorization': apikeyOpenrouteservice, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data); // à afficher sur ta carte ou dans une liste
    } else {
      print('Erreur ORS: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  /*
  *
  *===========================
  * Pour la date et l'heure
  *===========================
  */
  String get formattedDate =>
      selectedDate != null ? DateFormat.yMMMd().format(selectedDate!) : "Date";

  String get formattedTime =>
      selectedTime != null ? selectedTime!.format(context) : "Heure";

  /*
  *
  *===================================
  * Pour la recherrche de lieu
  *===================================
  *
  */

  final String apiKey =
      'pk.eyJ1Ijoicm9nZXItc3VtYWlsaSIsImEiOiJjbTk3YzRhcnIwNjE2Mm1zaWV0YXhhZzY5In0.xnIW1NSvnVPRLpKkU998VQ';
  final searchController = TextEditingController();
  List<MapBoxPlace> places = [];

  void searchPlaces(String query) async {
    var placesSearch = GeoCoding(apiKey: apiKey);

    final response = await placesSearch.getPlaces(
      query,
    ); // ApiResponse<List<MapBoxPlace>>

    if (response.success != null) {
      setState(() {
        places = response.success!;
      });
    } else {
      print('Erreur MapBox : ${response.failure?.message}');
      setState(() {
        places = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rechercher un lieu'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Lieux rapides

            // Zone de recherche + Bouton calendrier
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
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
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un lieu',
                        border: InputBorder.none,
                      ),
                      onChanged: searchPlaces,
                    ),
                  ),
                  VerticalDivider(),
                  IconButton(
                    icon: Icon(Icons.calendar_month, color: Colors.green),
                    onPressed: () {
                      setState(() => showDateTimePicker = !showDateTimePicker);
                    },
                  ),
                ],
              ),
            ),

            // Affichage des boutons date + heure si activé
            if (showDateTimePicker) ...[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectDate,
                    icon: Icon(Icons.calendar_today),
                    label: Text(formattedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _selectTime,
                    icon: Icon(Icons.access_time),
                    label: Text(formattedTime),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 5),

            // Catégories de lieux
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Chip(
                    avatar: Icon(cat['icon'], size: 20),
                    label: Text(cat['label']),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  );
                },
              ),
            ),

            //suggestion de lieu de recherche
            Expanded(
              child: ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  var place = places[index];
                  return ListTile(
                    title: Text(place.placeName ?? ''),
                    onTap: () {
                      // Supposons que 'place' soit une instance de MapBoxPlace
                      if (place.center != null) {
                        final latitude = place.center!.lat;
                        final longitude = place.center!.long;
                        print('Latitude: $latitude, Longitude: $longitude');
                      } else {
                        print(
                          'Les coordonnées ne sont pas disponibles pour ce lieu.',
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

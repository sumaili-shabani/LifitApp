import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CarteMapScreem extends StatefulWidget {
  const CarteMapScreem({super.key});

  @override
  State<CarteMapScreem> createState() => _CarteMapScreemState();
}

class _CarteMapScreemState extends State<CarteMapScreem> {
  static const String apikeyOpenrouteservice =
      "5b3ce3597851110001cf62484e660c3aa019470d8ac388d12b974480";

  LatLng? userPosition;
  Map<String, dynamic>? selectedPassenger;
  double? distanceToPassenger;
  double? estimatedTime;
  List<LatLng> routeCoordinates = [];
  bool isBottomSheetOpen = false;

  final LatLng gomaPosition = LatLng(-1.6708, 29.2218);

  final List<Map<String, dynamic>> passengers = [
    {
      "name": "Roger",
      "latitude": -1.6705,
      "longitude": 29.2220,
      "phone": "+243 970 001 111",
    },
    {
      "name": "Alex",
      "latitude": -1.6710,
      "longitude": 29.2230,
      "phone": "+243 970 002 222",
    },
    {
      "name": "Julie",
      "latitude": -1.6720,
      "longitude": 29.2240,
      "phone": "+243 970 003 333",
    },
  ];

  @override
  void initState() {
    super.initState();
    determinePosition();
  }

  Future<void> determinePosition() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      userPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> getRoute(Map<String, dynamic> passenger) async {
    if (userPosition != null) {
      LatLng passengerPosition = LatLng(
        passenger["latitude"],
        passenger["longitude"],
      );

      final response = await http.get(
        Uri.parse(
          "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apikeyOpenrouteservice&start=${userPosition!.longitude},${userPosition!.latitude}&end=${passengerPosition.longitude},${passengerPosition.latitude}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          routeCoordinates =
              data["features"][0]["geometry"]["coordinates"]
                  .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                  .toList();

          distanceToPassenger =
              Geolocator.distanceBetween(
                userPosition!.latitude,
                userPosition!.longitude,
                passengerPosition.latitude,
                passengerPosition.longitude,
              ) /
              1000;

          estimatedTime =
              data["features"][0]["properties"]["segments"][0]["duration"] / 60;

          selectedPassenger = passenger;
          isBottomSheetOpen = true;
        });

        _showBottomSheet();
      }
    }
  }

  void _showBottomSheet() {
    if (selectedPassenger != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
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
                          routeCoordinates.clear();
                        });
                      },
                    ),
                  ],
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.blue),
                  title: Text("Nom: ${selectedPassenger!["name"]}"),
                ),
                ListTile(
                  leading: Icon(Icons.phone, color: Colors.orange),
                  title: Text("Téléphone: ${selectedPassenger!["phone"]}"),
                ),
                ListTile(
                  leading: Icon(Icons.directions_car, color: Colors.red),
                  title: Text(
                    "Distance: ${distanceToPassenger!.toStringAsFixed(2)} km",
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.timer, color: Colors.purple),
                  title: Text(
                    "Temps estimé: ${estimatedTime!.toStringAsFixed(1)} min",
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Carte des passagers")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center:
                  isBottomSheetOpen
                      ? LatLng(
                        userPosition!.latitude - 0.002,
                        userPosition!.longitude,
                      )
                      : userPosition ?? gomaPosition,
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeCoordinates,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (userPosition != null)
                    Marker(
                      point: userPosition!,
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.local_taxi,
                        color: Colors.black,
                        size: 35,
                      ),
                    ),
                  ...passengers.map((passenger) {
                    LatLng passengerPosition = LatLng(
                      passenger["latitude"],
                      passenger["longitude"],
                    );
                    return Marker(
                      point: passengerPosition,
                      width: 120,
                      height: 120,
                      child: GestureDetector(
                        onTap: () => getRoute(passenger),
                        child: Icon(
                          Icons.person_pin,
                          color:
                              selectedPassenger == passenger
                                  ? Colors.red
                                  : Colors.blue,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

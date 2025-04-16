import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';

class CarteSelectionPosition extends StatefulWidget {
  const CarteSelectionPosition({super.key});

  @override
  State<CarteSelectionPosition> createState() => _CarteSelectionPositionState();
}

class _CarteSelectionPositionState extends State<CarteSelectionPosition> {
  LatLng? _selectedLatLng;
  LatLng centerGoma = LatLng(-1.6708, 29.2218);
  LatLng centerKinshasa = LatLng(-4.325, 15.3222);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text("Votre position", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            tooltip: "Sélectionner votre position",
            color: Colors.white,
            onPressed: () {
              if (_selectedLatLng != null) {
                Navigator.pop(context, _selectedLatLng);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.white),
            tooltip: "Discussion instantanée",
            onPressed: () {
              Navigator.of(
                context,
              ).push(AnimatedPageRoute(page: CorrespondentsPage()));
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: centerGoma, // Kinshasa centre
          zoom: 14,
        ),
        onTap: (LatLng latLng) {
          setState(() {
            _selectedLatLng = latLng;
          });
        },
        markers:
            _selectedLatLng != null
                ? {
                  Marker(
                    markerId: MarkerId("selected"),
                    position: _selectedLatLng!,
                  ),
                }
                : {},
      ),
    );
  }
}

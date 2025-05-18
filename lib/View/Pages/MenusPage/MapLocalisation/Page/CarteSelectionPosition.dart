import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lifti_app/Components/AnimatedPageRoute.dart';
import 'package:lifti_app/Components/CustomAppBar.dart';
import 'package:lifti_app/View/Pages/MenusPage/Chat/CorrespondentsPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true,
        title: Text("${l10n.positionnement_map_titre} ", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            tooltip: "${l10n.map_client_select_position} ",
            color: Colors.white,
            onPressed: () {
              if (_selectedLatLng != null) {
                Navigator.pop(context, _selectedLatLng);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.white),
            tooltip: "${l10n.map_client_discussion} ",
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
          target: centerKinshasa, // Kinshasa centre
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

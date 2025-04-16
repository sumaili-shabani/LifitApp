// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart' hide Location;
// import '../../core/providers/location_provider.dart';
// import '../../core/models/driver.dart';
// import '../../core/services/directions_service.dart';
// import 'package:lifti_app/core/config/api_keys.dart';

// class MapPage extends ConsumerStatefulWidget {
//   const MapPage({super.key});

//   @override
//   ConsumerState<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends ConsumerState<MapPage> {
//   final Completer<GoogleMapController> _controller = Completer();
//   final DirectionsService _directionsService = DirectionsService();
//   final TextEditingController _pickupController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   Map<PolylineId, Polyline> _polylinesMap = {};
//   BitmapDescriptor? _carIcon;
//   LatLng? _pickupLocation;
//   LatLng? _destinationLocation;
//   bool _isSearchingPickup = false;
//   bool _isSearchingDestination = false;
//   List<String> _searchSuggestions = [];
//   MapType _currentMapType = MapType.normal;
//   String? _distance;
//   String? _duration;
//   String? _durationText;
//   double _bottomSheetHeight = 0;
//   bool _showDrivers = false;
//   String? _selectedPaymentMethod;
//   bool _showDashedLine = true;
//   double? _estimatedPrice;
//   List<Driver> _nearbyDrivers = [];
//   LatLng? _origin;
//   LatLng? _destination;
//   List<LatLng> _routePoints = [];

//   static const CameraPosition _kInitialPosition = CameraPosition(
//     target: LatLng(-1.6777, 29.2285),
//     zoom: 14.0,
//   );

//   final List<Driver> _defaultDrivers = [
//     Driver(
//       id: '1',
//       name: 'Jean',
//       latitude: -1.6777,
//       longitude: 29.2285,
//       isAvailable: true,
//       carModel: 'Toyota Corolla',
//       carColor: 'Blanc',
//       plateNumber: 'ABC 123',
//       rating: 4.8,
//       distanceFromUser: 0.5,
//     ),
//     Driver(
//       id: '2',
//       name: 'Marc',
//       latitude: -1.6814, // Près du Lac Kivu
//       longitude: 29.2252,
//       isAvailable: true,
//       carModel: 'Honda Civic',
//       carColor: 'Noir',
//       plateNumber: 'XYZ 789',
//       rating: 4.5,
//       distanceFromUser: 1.2,
//     ),
//     Driver(
//       id: '3',
//       name: 'Sophie',
//       latitude: -1.6697, // Quartier Katindo
//       longitude: 29.2334,
//       isAvailable: true,
//       carModel: 'Hyundai Tucson',
//       carColor: 'Rouge',
//       plateNumber: 'DEF 456',
//       rating: 4.7,
//       distanceFromUser: 0.8,
//     ),
//     Driver(
//       id: '4',
//       name: 'Pierre',
//       latitude: -1.6744, // Près du centre-ville
//       longitude: 29.2198,
//       isAvailable: true,
//       carModel: 'Kia Sportage',
//       carColor: 'Gris',
//       plateNumber: 'GHI 012',
//       rating: 4.6,
//       distanceFromUser: 1.5,
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadMapStyle();
//     _initializeMarkers();
//     _getCurrentLocation();
//   }

//   Future<void> _loadMapStyle() async {
//     final controller = await _controller.future;
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final styleFile =
//         isDarkMode ? 'assets/map_style_dark.json' : 'assets/map_style.json';
//     final style = await rootBundle.loadString(styleFile);
//     await controller.setMapStyle(style);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadMapStyle();
//   }

//   void _initializeMarkers() {
//     for (final driver in _defaultDrivers) {
//       if (driver.isAvailable) {
//         _markers.add(
//           Marker(
//             markerId: MarkerId('driver_${driver.id}'),
//             position: LatLng(driver.latitude, driver.longitude),
//             icon: _carIcon ??
//                 BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//             onTap: () {
//               _showDriverDetails(driver);
//             },
//           ),
//         );
//       }
//     }
//   }

//   void _getCurrentLocation() async {
//     final currentLocation = ref.read(locationProvider);
//     if (currentLocation != null) {
//       final controller = await _controller.future;
//       controller.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(target: currentLocation, zoom: 15),
//         ),
//       );
//     }
//   }

//   Future<List<LatLng>> _updatePolyline() async {
//     if (_pickupLocation == null || _destinationLocation == null) {
//       debugPrint('Points de départ ou d\'arrivée non définis');
//       return [];
//     }

//     try {
//       List<LatLng> polylineCoordinates = [];
//       PolylinePoints polylinePoints = PolylinePoints();

//       final result = await polylinePoints.getRouteBetweenCoordinates(
//         ApiKeys.googleMapsKey,
//         PointLatLng(_pickupLocation!.latitude, _pickupLocation!.longitude),
//         PointLatLng(
//             _destinationLocation!.latitude, _destinationLocation!.longitude),
//         travelMode: TravelMode.driving,
//       );

//       if (result.errorMessage?.isNotEmpty ?? false) {
//         debugPrint('Erreur API Google Maps: ${result.errorMessage}');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Erreur: ${result.errorMessage}'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//         return [];
//       }

//       if (result.points.isEmpty) {
//         debugPrint('Aucun point retourné par l\'API');
//         // Utiliser une ligne droite comme fallback
//         return [
//           _pickupLocation!,
//           _destinationLocation!,
//         ];
//       }

//       polylineCoordinates = result.points
//           .map((point) => LatLng(point.latitude, point.longitude))
//           .toList();

//       return polylineCoordinates;
//     } catch (e) {
//       debugPrint('Erreur lors de la récupération de l\'itinéraire: $e');
//       // Utiliser une ligne droite comme fallback en cas d'erreur
//       return [
//         _pickupLocation!,
//         _destinationLocation!,
//       ];
//     }
//   }

//   void _genetatePolyline() async {
//     if (_pickupLocation == null || _destinationLocation == null) {
//       debugPrint('Points de départ ou d\'arrivée manquants');
//       return;
//     }

//     try {
//       final polylineCoordinates = await _updatePolyline();

//       if (mounted) {
//         setState(() {
//           // Supprimer l'ancien itinéraire s'il existe
//           // _polylines.removeWhere(
//           //     (polyline) => polyline.polylineId == const PolylineId('route'));

//           // Ajouter le nouvel itinéraire
//           _polylines.add(
//             Polyline(
//               polylineId: const PolylineId('route'),
//               points: polylineCoordinates,
//               color: Theme.of(context).colorScheme.error,
//               width: 5,
//               geodesic: true,
//             ),
//           );

//           // Ajuster la vue de la carte
//           if (polylineCoordinates.length >= 2) {
//             final bounds = LatLngBounds(
//               southwest: LatLng(
//                 math.min(_pickupLocation!.latitude,
//                         _destinationLocation!.latitude) -
//                     0.01,
//                 math.min(_pickupLocation!.longitude,
//                         _destinationLocation!.longitude) -
//                     0.01,
//               ),
//               northeast: LatLng(
//                 math.max(_pickupLocation!.latitude,
//                         _destinationLocation!.latitude) +
//                     0.01,
//                 math.max(_pickupLocation!.longitude,
//                         _destinationLocation!.longitude) +
//                     0.01,
//               ),
//             );

//             _controller.future.then((controller) {
//               controller.animateCamera(
//                 CameraUpdate.newLatLngBounds(bounds, 50),
//               );
//             });
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint('Erreur lors de la génération du trajet: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content:
//                 Text('Erreur lors de la génération du trajet: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             mapType: _currentMapType,
//             initialCameraPosition: _kInitialPosition,
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//             },
//             markers: _markers,
//             polylines: _polylines,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: false,
//             onTap: _onMapTapped,
//             padding: EdgeInsets.only(
//               bottom:
//                   _showDrivers ? MediaQuery.of(context).size.height * 0.4 : 0,
//             ),
//           ),
//           // Barre de recherche en haut
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 10,
//             left: 16,
//             right: 16,
//             child: Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   children: [
//                     _buildSearchField(
//                       controller: _pickupController,
//                       hint: 'Point de départ',
//                       icon: Icons.my_location,
//                       onTap: () => _showLocationSearch(isPickup: true),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 32),
//                       child: Divider(height: 1),
//                     ),
//                     _buildSearchField(
//                       controller: _destinationController,
//                       hint: 'Où allez-vous ?',
//                       icon: Icons.location_on,
//                       onTap: () => _showLocationSearch(isPickup: false),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Boutons de contrôle
//           Positioned(
//             bottom: 16 + _bottomSheetHeight,
//             right: 16,
//             child: Column(
//               children: [
//                 FloatingActionButton(
//                   heroTag: 'location',
//                   onPressed: _getCurrentLocation,
//                   backgroundColor: theme.colorScheme.primary,
//                   child: const Icon(Icons.my_location),
//                 ),
//                 const SizedBox(height: 8),
//                 FloatingActionButton(
//                   heroTag: 'layers',
//                   onPressed: _toggleMapType,
//                   backgroundColor: theme.colorScheme.primary,
//                   child: const Icon(Icons.layers),
//                 ),
//               ],
//             ),
//           ),
//           // Bouton de confirmation
//           if (_pickupLocation != null && _destinationLocation != null)
//             Positioned(
//               bottom: 16,
//               left: 16,
//               right: 16,
//               child: ElevatedButton(
//                 onPressed: () => setState(() => _showDrivers = true),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.primary,
//                   foregroundColor: theme.colorScheme.onPrimary,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Rechercher un chauffeur',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           if (_isSearchingPickup || _isSearchingDestination)
//             _buildSearchResults(),
//           if (_showDrivers) _buildDriversList(),
//           _buildBottomSheet(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         hintText: hint,
//         border: InputBorder.none,
//         prefixIcon: Icon(icon),
//         suffixIcon: controller.text.isNotEmpty
//             ? IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () => controller.clear(),
//               )
//             : null,
//       ),
//       onTap: onTap,
//       readOnly: true,
//     );
//   }

//   Widget _buildSearchResults() {
//     return Positioned(
//       top: MediaQuery.of(context).padding.top + 140,
//       left: 0,
//       right: 0,
//       bottom: 0,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//         ),
//         child: ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: _searchSuggestions.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               leading: const Icon(Icons.location_on),
//               title: Text(_searchSuggestions[index]),
//               onTap: () => _onLocationSelected(_searchSuggestions[index]),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildDriversList() {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.4,
//       minChildSize: 0.2,
//       maxChildSize: 0.8,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).scaffoldBackgroundColor,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   controller: scrollController,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: _nearbyDrivers.length,
//                   itemBuilder: (context, index) {
//                     final driver = _nearbyDrivers[index];
//                     return _buildDriverCard(driver);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDriverCard(Driver driver) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.grey[300],
//           child: const Icon(Icons.person, color: Colors.grey),
//           radius: 25,
//         ),
//         title: Text(
//           driver.name,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('${driver.carModel} - ${driver.carColor}'),
//             Row(
//               children: [
//                 Text('${driver.distanceFromUser.toStringAsFixed(1)} km'),
//                 const SizedBox(width: 8),
//                 Icon(Icons.star, size: 16, color: Colors.amber[700]),
//                 Text(' ${driver.rating}'),
//               ],
//             ),
//           ],
//         ),
//         trailing: ElevatedButton(
//           onPressed: () => _showPaymentMethodDialog(driver),
//           child: const Text('Choisir'),
//         ),
//       ),
//     );
//   }

//   double _calculateDistance(LatLng driverPosition) {
//     if (_pickupLocation == null) return 0;

//     return _calculateDistanceBetweenPoints(
//       _pickupLocation!.latitude,
//       _pickupLocation!.longitude,
//       driverPosition.latitude,
//       driverPosition.longitude,
//     );
//   }

//   double _calculateDistanceBetweenPoints(
//     double lat1,
//     double lon1,
//     double lat2,
//     double lon2,
//   ) {
//     const double earthRadius = 6371; // Rayon de la Terre en kilomètres

//     final dLat = _toRadians(lat2 - lat1);
//     final dLon = _toRadians(lon2 - lon1);

//     final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_toRadians(lat1)) *
//             math.cos(_toRadians(lat2)) *
//             math.sin(dLon / 2) *
//             math.sin(dLon / 2);

//     final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     final distance = earthRadius * c;

//     return distance;
//   }

//   double _toRadians(double degree) {
//     return degree * math.pi / 180;
//   }

//   void _onMapTapped(LatLng position) {
//     setState(() {
//       _pickupLocation = position;
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('pickup'),
//           position: position,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//     });
//   }

//   void _onLocationSelected(String location) async {
//     try {
//       final locations = await locationFromAddress(location);
//       if (locations.isNotEmpty) {
//         final selectedLocation = locations.first;
//         final position =
//             LatLng(selectedLocation.latitude, selectedLocation.longitude);

//         setState(() {
//           if (_isSearchingPickup) {
//             _pickupLocation = position;
//             _pickupController.text = location;
//             _markers.removeWhere((m) => m.markerId.value == 'pickup');
//             _markers.add(Marker(
//               markerId: const MarkerId('pickup'),
//               position: position,
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueGreen),
//             ));
//           } else {
//             _destinationLocation = position;
//             _destinationController.text = location;
//             _markers.removeWhere((m) => m.markerId.value == 'destination');
//             _markers.add(Marker(
//               markerId: const MarkerId('destination'),
//               position: position,
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueRed),
//             ));
//           }

//           _isSearchingPickup = false;
//           _isSearchingDestination = false;

//           if (_pickupLocation != null && _destinationLocation != null) {
//             _genetatePolyline();
//           }
//         });

//         final controller = await _controller.future;
//         controller.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
//       }
//     } catch (e) {
//       debugPrint('Erreur de géocodage: $e');
//     }
//   }

//   void _showLocationSearch({required bool isPickup}) async {
//     setState(() {
//       _isSearchingPickup = isPickup;
//       _isSearchingDestination = !isPickup;
//       _searchSuggestions = [
//         'Aéroport de Goma',
//         'Marché Central',
//         'Port de Goma',
//         'Université de Goma',
//         'Hôpital HEAL Africa',
//         'Grande Barrière',
//         'Cathédrale Notre-Dame',
//       ];
//     });
//   }

//   Future<void> _updateRoute() async {
//     if (_pickupLocation == null || _destinationLocation == null) return;

//     try {
//       final directionsService = DirectionsService();
//       final result = await directionsService.getDirections(
//         origin: LatLng(
//           _pickupLocation!.latitude,
//           _pickupLocation!.longitude,
//         ),
//         destination: LatLng(
//           _destinationLocation!.latitude,
//           _destinationLocation!.longitude,
//         ),
//       );

//       if (result != null) {
//         setState(() {
//           _polylines.clear();
//           _polylines.add(
//             Polyline(
//               polylineId: const PolylineId('route'),
//               points: result.polylinePoints,
//               color: Theme.of(context).colorScheme.primary,
//               width: 8,
//             ),
//           );

//           // Mettre à jour la distance et la durée estimée
//           _distance = result.distance;
//           _duration = result.duration;
//           _durationText = result.durationText;
//           print(result);
//           // Ajuster la caméra pour voir tout l'itinéraire
//           _controller.future.then((controller) {
//             controller.animateCamera(
//               CameraUpdate.newLatLngBounds(result.bounds, 50),
//             );
//           });
//         });
//       }
//     } catch (e) {
//       debugPrint('Erreur lors de la mise à jour de l\'itinéraire: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Impossible de mettre à jour l\'itinéraire: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _toggleMapType() {
//     setState(() {
//       _currentMapType = _currentMapType == MapType.normal
//           ? MapType.satellite
//           : _currentMapType == MapType.satellite
//               ? MapType.terrain
//               : MapType.normal;
//     });
//   }

//   void _selectDriver(Driver driver) {
//     setState(() {
//       _showDrivers = false;
//       _pickupLocation = driver.position;
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('driver'),
//           position: driver.position,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         ),
//       );
//     });
//   }

//   void _showDriverDetails(Driver driver) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: Container(
//                   width: 40,
//                   height: 40,
//                   color: Colors.grey[300],
//                   child: const Icon(Icons.person, color: Colors.grey),
//                 ),
//               ),
//               title: Text(driver.name),
//               subtitle: Row(
//                 children: [
//                   Icon(Icons.star, size: 16, color: Colors.amber[700]),
//                   Text(' ${driver.rating}'),
//                 ],
//               ),
//             ),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.car_rental),
//               title: Text('${driver.carModel} - ${driver.carColor}'),
//               subtitle: Text(driver.plateNumber),
//             ),
//             ListTile(
//               leading: const Icon(Icons.location_on),
//               title: const Text('Distance'),
//               subtitle: Text('${driver.distanceFromUser} km'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _requestRide(driver);
//               },
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size.fromHeight(50),
//               ),
//               child: const Text('Demander une course'),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   void _requestRide(Driver driver) {
//     // TODO: Implémenter la demande de course
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Demande envoyée à ${driver.name}'),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   Future<void> _showPaymentMethodDialog(Driver driver) async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Mode de paiement'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               RadioListTile<String>(
//                 title: const Row(
//                   children: [
//                     Icon(Icons.money),
//                     SizedBox(width: 8),
//                     Text('Espèces'),
//                   ],
//                 ),
//                 value: 'cash',
//                 groupValue: _selectedPaymentMethod,
//                 onChanged: (String? value) {
//                   setState(() => _selectedPaymentMethod = value);
//                 },
//               ),
//               RadioListTile<String>(
//                 title: const Row(
//                   children: [
//                     Icon(Icons.credit_card),
//                     SizedBox(width: 8),
//                     Text('Carte bancaire'),
//                   ],
//                 ),
//                 value: 'card',
//                 groupValue: _selectedPaymentMethod,
//                 onChanged: (String? value) {
//                   setState(() => _selectedPaymentMethod = value);
//                 },
//               ),
//               RadioListTile<String>(
//                 title: const Row(
//                   children: [
//                     Icon(Icons.phone_android),
//                     SizedBox(width: 8),
//                     Text('Mobile Money'),
//                   ],
//                 ),
//                 value: 'mobile',
//                 groupValue: _selectedPaymentMethod,
//                 onChanged: (String? value) {
//                   setState(() => _selectedPaymentMethod = value);
//                 },
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Annuler'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               onPressed: _selectedPaymentMethod == null
//                   ? null
//                   : () {
//                       Navigator.of(context).pop();
//                       _showDriverDetails(driver);
//                     },
//               child: const Text('Confirmer'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildBottomSheet() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       height: _bottomSheetHeight,
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const SizedBox(height: 12),
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_distance != null && _duration != null) ...[
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Distance',
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                         Text(
//                           _distance!,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleMedium
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Durée estimée',
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                         Text(
//                           _durationText ?? _duration!,
//                           style: Theme.of(context)
//                               .textTheme
//                               .titleMedium
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.primaryContainer,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       color: Theme.of(context).colorScheme.onPrimaryContainer,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Ces estimations peuvent varier en fonction du trafic',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .onPrimaryContainer,
//                             ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   void _updateBottomSheetInfo() {
//     setState(() {
//       _bottomSheetHeight = 120;
//     });
//   }

//   Future<void> _searchDrivers() async {
//     setState(() {
//       _showDrivers = true;
//     });

//     try {
//       // Simuler une liste de chauffeurs pour démonstration
//       final drivers = [
//         Driver(
//           id: '1',
//           name: 'Jean Pierre',
//           rating: 4.8,
//           distanceFromUser: 1.2,
//           carModel: 'Toyota Corolla',
//           carColor: 'Blanc',
//           plateNumber: 'ABC 123',
//           latitude: _pickupLocation!.latitude + 0.001,
//           longitude: _pickupLocation!.longitude + 0.001,
//           isAvailable: true,
//         ),
//         Driver(
//           id: '2',
//           name: 'Marie Claire',
//           rating: 4.5,
//           distanceFromUser: 2.1,
//           carModel: 'Honda Civic',
//           carColor: 'Noir',
//           plateNumber: 'XYZ 789',
//           latitude: _pickupLocation!.latitude - 0.001,
//           longitude: _pickupLocation!.longitude - 0.001,
//           isAvailable: true,
//         ),
//         Driver(
//           id: '3',
//           name: 'Patrick Lumumba',
//           rating: 4.9,
//           distanceFromUser: 0.8,
//           carModel: 'Hyundai Accent',
//           carColor: 'Gris',
//           plateNumber: 'DEF 456',
//           latitude: _pickupLocation!.latitude + 0.002,
//           longitude: _pickupLocation!.longitude - 0.002,
//           isAvailable: true,
//         ),
//       ];

//       setState(() {
//         _nearbyDrivers = drivers;
//         _markers.addAll(
//           drivers.map(
//             (driver) => Marker(
//               markerId: MarkerId('driver_${driver.id}'),
//               position: LatLng(driver.latitude, driver.longitude),
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueYellow),
//               infoWindow: InfoWindow(
//                 title: driver.name,
//                 snippet:
//                     '${driver.carModel} - ${driver.carColor}\n${driver.plateNumber}',
//               ),
//               onTap: () => _showDriverDetails(driver),
//             ),
//           ),
//         );
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Erreur lors de la recherche des chauffeurs'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Future<void> _getDirections() async {
//     if (_origin == null || _destination == null) return;

//     try {
//       final directionsService = DirectionsService();
//       final result = await directionsService.getDirections(
//         origin: _origin!,
//         destination: _destination!,
//       );

//       if (result != null) {
//         setState(() {
//           _polylines.clear();
//           _polylines.add(
//             Polyline(
//               polylineId: const PolylineId('route'),
//               points: result.polylinePoints,
//               color: Theme.of(context).colorScheme.primary,
//               width: 5,
//             ),
//           );

//           // Mettre à jour les marqueurs
//           _markers.clear();
//           _markers.addAll({
//             Marker(
//               markerId: const MarkerId('origin'),
//               position: _origin!,
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueGreen,
//               ),
//               infoWindow: InfoWindow(
//                 title: 'Point de départ',
//                 snippet: result.startAddress,
//               ),
//             ),
//             Marker(
//               markerId: const MarkerId('destination'),
//               position: _destination!,
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueRed,
//               ),
//               infoWindow: InfoWindow(
//                 title: 'Destination',
//                 snippet: result.endAddress,
//               ),
//             ),
//           });

//           // Ajuster la caméra pour voir tout l'itinéraire
//           final bounds = LatLngBounds(
//             southwest: result.bounds.southwest,
//             northeast: result.bounds.northeast,
//           );

//           _controller.future.then((controller) {
//             controller.animateCamera(
//               CameraUpdate.newLatLngBounds(bounds, 50),
//             );
//           });
//         });
//       }
//     } catch (e) {
//       debugPrint('Erreur lors de l\'obtention des directions: $e');
//       // Afficher un message d'erreur à l'utilisateur
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content:
//                 Text('Impossible d\'obtenir l\'itinéraire: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _onMapTap(LatLng position) {
//     setState(() {
//       if (_origin == null) {
//         _origin = position;
//       } else if (_destination == null) {
//         _destination = position;
//         _getDirections();
//       } else {
//         _origin = position;
//         _destination = null;
//         _polylines.clear();
//         _markers.clear();
//       }
//     });
//   }
// }
